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
} {
    Create a new variable to use for logger measurements. The
    variable can be tied to logger projects through the
    logger::project::add_variable proc.

    @param variable_id Any pre-generated id of the variable. Optional.
    @param name The name of the new variable. Required.
    @param unit The unit of the variable, for example hours, minutes, or 
                a currency code such as USD or EUR.
    @param type Must be either additive (default) or non-additive.

    @return The id of the created variable.

    @author Peter Marklund
} {
    ad_assert_arg_value_in_list type {additive non-additive}

    # Default variable_id to next id in a sequence
    if { [empty_string_p $variable_id] } {
        set variable_id [db_nextval logger_variables_seq]
    }

    set package_id [ad_conn package_id]

    db_dml insert_variable {}

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
    db_dml delete_variable {}
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
