ad_library {
    Procedures in the logger::variable namespace. Those procedures
    operate on logger variable objects.
    
    @creation-date 4:th of April 2003
    @author Peter Marklund (peter@collaboraid.biz)
    @cvs-id $Id$
}

namespace eval logger::variable {}

ad_proc -public logger::variable::new {
    {-variable_id ""}
    {-name:required}
    {-unit:required}
    {-type "additive"}
    {-pre_installed_p 0}
} {
    Create a new variable to use for logger entries. The
    variable can be tied to logger projects through the
    logger::project::map_variable proc.

    @param variable_id Any pre-generated id of the variable. Optional.
    @param name The name of the new variable. Required.
    @param unit The unit of the variable, for example hours, minutes, or 
                a currency code such as USD or EUR.
    @param type Must be either additive (default) or non-additive.
    @param pre_installed_p Indicates whether this is a variable that is comes pre-installed
                           with the logger application (1) or not (0). Default is 0.

    @return The id of the created variable.

    @author Peter Marklund
} {
    ad_assert_arg_value_in_list type {additive non-additive}
    
    set name [lang::util::convert_to_i18n -package_key "logger" -prefix "name" -text $name]
    set unit [lang::util::convert_to_i18n -package_key "logger" -prefix "unit" -text $unit]

    # Use ad_conn to initialize variables    
    logger::util::set_vars_from_ad_conn {package_id creation_user creation_ip}

    if { $pre_installed_p } {
        # Pre-installed vars are not associated with any particular package
        set package_id [db_null]
    }

    set variable_id [db_exec_plsql insert_variable {}]

    if { $pre_installed_p } {
        # Registered users should have read privilege on pre-installed variables
        permission::grant \
            -party_id [acs_magic_object registered_users] \
            -object_id $variable_id \
            -privilege read
    } 

    return $variable_id
}

ad_proc -public logger::variable::edit {
    {-variable_id:required}
    {-name:required}
    {-unit:required}
    {-type:required}
} {
    Edit a logger variable.

    @param variable_id The id of the project to edit
    @param name The new name of the variable
    @param unit The new unit of the variable
    @param type The new type of the variable (additive or non-additive)

    @return The return value from db_dml

    @author Peter Marklund
} {
    ad_assert_arg_value_in_list type {additive non-additive}
    
    set package_id [ad_conn package_id]

    db_dml update_variable {}
}

ad_proc -public logger::variable::delete {
    {-variable_id:required}
} {
    Delete the variable with given id.

    @param variable_id The id of the variable to delete.

    @return The return value of db_dml

    @author Peter Marklund
} {
    db_exec_plsql delete_variable {}
}

ad_proc -public logger::variable::get {
    {-variable_id:required}
    {-array:required}
} {
    Retrieve attributes of the variable with given id into an 
    array (using upvar) in the callers scope. The
    array will contain the keys variable_id, name, unit, and type.

    @param variable_id The id of the variable to retrieve information about
    @param array The name of the array in the callers scope where the information will
                 be stored

    @return The return value from db_1row. Throws an error if the variable doesn't exist.

    @author Peter Marklund
} {
    upvar $array variable_array

    db_1row select_variable {} -column_array variable_array
}

ad_proc -public logger::variable::get_default_variable_id {
    {-package_id {}}
} {
    Get the ID of the default (first) variable.
} {
    if { [empty_string_p $package_id] && [ad_conn isconnected] } {
        set package_id [ad_conn package_id]
    }
    if { ![empty_string_p $package_id] } {
        # Get the default variable of the first active project in the given package
        set primary_variables [db_list select_first_project_primary_variable {}]
        
        # Just the first
        set variable_id [lindex $primary_variables 0]
    }

    if { [empty_string_p $variable_id] } {
        # Just get the first ever variable, most likely "Time"
        set variable_id [db_string select_first_variable_id {} -default {}]
    }

    return $variable_id
}
