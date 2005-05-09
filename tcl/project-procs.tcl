ad_library {
    Procedures in the logger::project namespace. Those
    procedures operate on logger project objects.
    
    @creation-date 31 March 2003
    @author Peter Marklund (peter@collaboraid.biz)
    @cvs-id $Id$
}

namespace eval logger::project {}

ad_proc -private logger::project::insert {
    {-name:required}
    {-description ""}
    {-project_lead ""}
    {-project_id ""}
    {-package_id:required}
    {-creation_user:required}
    {-creation_ip:required}
} {
    Inserts a logger project into the database. This proc is only used internally.
    Should not be used by applications.
  
    @return The project_id of the created project.

    @author Peter Marklund
} {
    # Project lead defaults to creation user
    if { [empty_string_p $project_lead] } {
        set project_lead $creation_user
    }

    set project_id [db_exec_plsql insert_project {}]

    return $project_id
}

ad_proc -public logger::project::new {
    {-name:required}
    {-description ""}
    {-project_lead ""}
    {-project_id ""}
} {
  <p>
  Create a logger project.
  </p>
 
  <p>
    This proc requires the ad_conn proc to be initialized (uses user_id, peeraddr, and package_id). 
    The ad_conn proc is initialized
    by the request processor during an HTTP request to an OpenACS server. Invokes logger::project::insert
  </p>

  @param name          The name of the project.
  @param description   The description for the proct. Optional.
  @param project_lead  The user id of the project leader of the project. Defaults
                       to the currently logged in user.
  @param project_id    Any pre-generated id of the new package. Optional.

  @return The project_id of the created project.

  @see logger::project::insert

  @author Peter Marklund
} {
    # Use ad_conn to initialize variables
    logger::util::set_vars_from_ad_conn {package_id creation_user creation_ip}

    return [logger::project::insert \
                -name $name \
                -description $description \
                -project_lead $project_lead \
                -project_id $project_id \
                -package_id $package_id \
                -creation_user $creation_user \
                -creation_ip $creation_ip]
}

ad_proc -public logger::project::edit {
    {-project_id:required}
    {-name:required}
    {-description:required}
    {-project_lead:required}
    {-active_p:required}
} {
    Edit a Logger project. 

    @param project_id The id of the project to edit
    @param name The new name
    @param description The new description
    @param project_lead The new id of the project lead
    @param active_p The new value for active_p, must be t (true) or f (false)

    @return The return value from db_dml

    @author Peter Marklund
} {
    ad_assert_arg_value_in_list active_p {t f}

    db_dml update_project {}
}

ad_proc -public logger::project::set_active_p {
    {-project_id:required}
    {-active_p:required}
} {
    Set a Logger project active/inactive.

    @param project_id The id of the project to edit
    @param active_p The new value for active_p, must be t (true) or f (false)

    @return The return value from db_dml

    @author Lars Pind (lars@collaboraid.biz)
} {
    ad_assert_arg_value_in_list active_p {t f}

    db_dml update_project {}
}

ad_proc -public logger::project::delete {
    {-project_id:required}
} {
  Delete a logger project and all logger entries and projections
  contained within it. Also deletes all logger variables mapped to this
  project that are not mapped to other projects.

  @return The return value from db_exec_plsql

  @param project_id The id of the project to delete

  @author Peter Marklund
} {
    db_exec_plsql delete_project {}
}

ad_proc -public logger::project::get {
    {-project_id:required}
    {-array:required}
} {
    Retrieve info about the project with given id into an 
    array (using upvar) in the callers scope. The
    array will contain the keys project_id, name, description, active_p,
    and project_lead.

    @param project_id The id of the project to retrieve information about
    @param array The name of the array in the callers scope where the information will
                 be stored

    @return The return value from db_1row. Throws an error if the project doesn't exist.

    @author Peter Marklund
} {
    upvar $array project_array

    db_1row select_project {} -column_array project_array
}

ad_proc -public logger::project::map_variable {
    {-project_id:required}
    {-variable_id:required}
    {-primary_p ""}
} {
    Associate a logger variable with a logger project. Each
    variable can be associated with multiple projects.

    @param project_id The id of the project to add the variable to
    @param variable_id The id of the variable to add
    @param primary_p Is this the variable we are primarily tracking
                     in the project? Valid values are t (true) and f (false). The default will
                     be t if this is the first variable added to the project and
                     f otherwise. Note that a project must have exactly one primary variable.
                     If this is the first variable added and primary_p is provided it must
                     be set to t,  otherwise an error will be thrown.

    @return The return code from db_dml. Will throw a database 
            error if the variable and the project are already mapped.
    
    @author Peter Marklund
} {
    if { ![empty_string_p $primary_p] } {
        ad_assert_arg_value_in_list primary_p {t f}
    }

    # Check that there will be exactly one primary_p variable for the project
    set exists_primary_p [db_string count_primary_p {}]
    if { $exists_primary_p } {
        # There is already a primary_p variable so the new one can't be
        if { [string equal $primary_p "t"] } {
            error "logger::project::map_variable - invoked with primary_p argument set to t but project $project_id already has a primary_p variable"
        }

        set primary_p f
    } else {
        # There is no primary_p variable so the new one must be
        if { [string equal $primary_p "f"] } {
            error "logger::project::map_variable - invoked with primary_p argument set to f but project $project_id has no primary_p variable and must have one"
        }

        set primary_p t
    }

    db_dml insert_mapping {}
}

ad_proc -public logger::project::unmap_variable {
    {-project_id:required}
    {-variable_id:required}
} {
    Disable logging in a certain variable for a project. Unmapping a primary
    variable is not a permissible operation and this proc will throw an error
    in that case.

    @param project_id The id of the project we are mapping the variable with
    @param variable_id The id of the variable to map

    @return The return value of db_dml

    @author Peter Marklund
} {
    # Check that this is not an attempt to delete the primary variable
    set primary_variable_id [logger::project::get_primary_variable -project_id $project_id]
    if { [string equal $primary_variable_id $variable_id] } {
        error "logger::project::unmap_variable - Cannot unmap variable $variable_id as it is primary to project $project_id"
    }

    db_dml delete_mapping {}
}

ad_proc -public logger::project::set_primary_variable {
    {-project_id:required}
    {-variable_id:required}
} {
    Change primary variable of a project. Every project has one primary variable
    (if it has any at all) and this is by default the first variable associated
    with the project. The administrator of the project is offered the possibility
    of changing primary variable through this proc.

    @param project_id The id of the project to change primary variable for
    @param variable_id The id of the variable that is to be the new
                       primary variable of the project.

    @return The return value of db_dml

    @author Peter Marklund
} {
    db_dml clear_old {}

    db_dml update_new {}
}

ad_proc -public logger::project::get_variables {
    {-project_id:required}
} {
    Return a list of id:s for the variables in the given project.

    @param project_id The id of the project to return variables for.

    @return A list of variable_id:s

    @author Peter Marklund
} {
    return [db_list select_variables {}]
}

ad_proc -public logger::project::get_primary_variable {
    {-project_id:required}
} {
    Return the id of the variable primarily logged in for a certain project.

    @param project_id The id of the project to return the primary variable for.

    @return The id of the primary variable. Returns the empty string if the
            project has no primary variable.

    @author Peter Marklund
} {
    return [db_string select_primary_variable {} -default ""]
}

ad_proc -private logger::project::users_get_options {} {
    Get the list of users to display in a drop-down to pick project lead.
} {
    set package_id [ad_conn package_id]
    set user_id [ad_conn user_id]

    set users_list [db_list_of_lists select_project_leads {}]

    lappend users_list { "[_ logger.Search]..." ":search:"}
    
    return $users_list
}

ad_proc -public logger::project::get_current_projection {
    -project_id:required
    -variable_id:required
} {
    Gets the active projection for the given project and variable, if any. Returns empty string if none.
} {
    return [db_string select_current_projection {} -default {}]
}

ad_proc -public logger::project::remap_variables {
    -project_id:required
    -new_variable_list:required
} {
    When given a list of variable IDs, sets the variables to be 
    equal to the new variable list. 

    Note this proc does not honor the default variables very much,
    and will remap them. Feel free to improve this if it affects 
    you.
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-05-20
    
    @param project_id the logger project ID

    @param new_variable_list a list of variable IDs

    @return 
    
    @error 
} {

    set current_variables_list [logger::project::get_variables -project_id $project_id]

    set primary_variable [logger::project::get_primary_variable -project_id $project_id]
    set default_variable [logger::variable::get_default_variable_id]
    
    foreach new_id $new_variable_list {

        # we only add it if it isn't already there
        if {[lsearch $current_variables_list $new_id] < 0} {
            logger::project::map_variable \
                -project_id $project_id \
                -variable_id $new_id
        }
    }

    # if one of the new variables is the default variable, set it
    # as the default variable for *that project*
    if {[lsearch $new_variable_list $default_variable] >= 0} {

        logger::project::set_primary_variable \
            -project_id $project_id \
            -variable_id $default_variable

    } else {

        logger::project::set_primary_variable \
            -project_id $project_id \
            -variable_id "[lindex $new_variable_list 0]"
    }

    foreach old_id $current_variables_list {
        
        # we only remove it if it isn't in the new list
        if {[lsearch $new_variable_list $old_id] < 0} {

            logger::project::unmap_variable \
                -project_id $project_id \
                -variable_id $old_id
        }

    }

    return 1
}
