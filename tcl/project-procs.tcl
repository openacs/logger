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
    {-project_id ""}
    {-package_id ""}
    {-description ""}
    {-project_lead ""}
    {-creation_user ""}
    {-creation_ip ""}
} {
  <p>
  Create a logger project.
  </p>
 
  <p>
  I've tried to design this proc so that it can be used also
  if there is no HTTP (ad_conn) connection, for example during a data import.
  </p>

  @param name          The name of the project.
  @param project_id    Any pre-generated id of the new package. Optional.
  @param package_id    The id of the Logger package in which the project is created. Defaults
                       to ad_conn package_id. Also used as context_id.
  @param description   The description for the proct. Optional.
  @param project_lead  The user id of the project leader of the project. Defaults
                       to the currently logged in user.
  @param creation_user The user creating the project. Defaults to ad_conn user_id.
  @param creation_ip   The ip of the user creating the project. Defaults to ad_conn peeraddr
  
  @return The project_id of the created project.

  @author Peter Marklund
} {
    # Use ad_conn to setup default values and check that required values are provided
    # if there is no ad_conn
    # The lists are on the array format 
    # var_name1 ad_conn_arg_name1 var_name2 ad_conn_arg_name2 ...
    set required_ad_conn_vars [list package_id package_id creation_user user_id]
    set optional_ad_conn_vars [list creation_ip peeraddr]
    if { [ad_conn isconnected] } {
        # HTTP connection available

        # ad_conn provides default values for us
        foreach {var_name ad_conn_name} [concat $required_ad_conn_vars $optional_ad_conn_vars] {
            if { [empty_string_p [set $var_name]] } {
                set $var_name [ad_conn $ad_conn_name]

                # If we are using ad_conn package_id
                # we might as well use ad_conn to check that its a logger package
                if { [string equal $var_name package_id] } {
                    if { ![string equal [ad_conn package_key] logger] } {
                        error "logger::project::new Defaulting package_id to the current package with key [ad_conn package_key] but package must be a logger package"
                    }
                }
            }
        }


    } else {
        # No HTTP connection

        # Default optional ad_conn vars to the empty string
        foreach {var_name ad_conn_name} $optional_ad_conn_vars {
            set $var_name ""
        }

        # Assert that required ad_conn variables are provided
        foreach var_name $required_ad_conn_vars {
            if { [empty_string_p [set $var_name]] } {
                error "logger::project::new - the $var_name argument was not provided and there is no ad_conn (HTTP) connection so a default value cannot be set"
            }
        }
    }

    # Project lead defaults to creation user
    if { [empty_string_p $project_lead] } {
        set project_lead $creation_user
    }

    set project_id [db_exec_plsql insert_project {}]

    return $project_id
}

ad_proc -public logger::project::delete {
    {-project_id:required}
} {
  Delete a logger project and all logger measurements and projections
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
