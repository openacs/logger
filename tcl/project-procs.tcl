ad_library {
    Procedures in the logger::project namespace. Those
    procedures operate on logger project objects.
    
    @creation-date 31 March 2003
    @author Peter Marklund (peter@collaboraid.biz)
    @cvs-id $Id$
}

namespace eval logger::project {}

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
    by the request processor during an HTTP request to an OpenACS server.
  </p>

  @param name          The name of the project.
  @param description   The description for the proct. Optional.
  @param project_lead  The user id of the project leader of the project. Defaults
                       to the currently logged in user.
  @param project_id    Any pre-generated id of the new package. Optional.

  @return The project_id of the created project.

  @author Peter Marklund
} {
    # Use ad_conn to initialize variables
    logger::util::set_vars_from_ad_conn {package_id creation_user creation_ip}

    # Project lead defaults to creation user
    if { [empty_string_p $project_lead] } {
        set project_lead $creation_user
    }

    # Insert the project
    set project_id [db_exec_plsql insert_project {}]

    return $project_id
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

ad_proc -public logger::project::add_variable {
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
            error "logger::project::add_variable - invoked with primary_p argument set to t but project $project_id already has a primary_p variable"
        }

        set primary_p f
    } else {
        # There is no primary_p variable so the new one must be
        if { [string equal $primary_p "f"] } {
            error "logger::project::add_variable - invoked with primary_p argument set to f but project $project_id has no primary_p variable and must have one"
        }

        set primary_p t
    }

    db_dml insert_mapping {}
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