ad_library {
    Procedures in the logger::projection namespace. Those procedures
    operate on logger projection objects.
    
    @creation-date 5:th of April 2003
    @author Peter Marklund (peter@collaboraid.biz)
    @cvs-id $Id$
}

namespace eval logger::projection {}

ad_proc -public logger::projection::new {
    {-projection_id ""}
    {-project_id:required}
    {-variable_id:required}
    {-start_time:required}
    {-end_time:required}
    {-value:required}
    {-name:required}
    {-description ""}
} {
    Create a new projection for a certain variable and project.

    @param projection_id An optional pre-generated id for the projection.
    @param project_id    The id of the project the projection is for
    @param variable_id   The id of the variable the projection is for
    @param start_time    Marks the start of the time range the projection is for.
                         Must be on ANSI day format "YYYY-MM-DD".
    @param end_time      Marks the end of the time range the projection is for.
                         Must be on ANSI day format "YYYY-MM-DD".
    @param value         The anticipated or targeted value (a sum for 
                         additive variables, an average for non-additive 
                         variables).
    @param name          Used when listing or displaying the projection in the UI.
    @param description   Describes the projection. Optional.
    
    @return The id of the created projection. Will throw an error if a projection_id
            is provided and a projection with that id already exists in the database.

    @author Peter Marklund
} {
    # Default projection_id to next id in a sequence
    if { [empty_string_p $projection_id] } {
        set projection_id [db_nextval logger_projections_seq]
    }

    db_dml insert_projection {}

    return $projection_id
}

ad_proc -public logger::projection::edit {
    {-projection_id ""}
    {-variable_id:required}
    {-start_time:required}
    {-end_time:required}
    {-value:required}
    {-name:required}
    {-description:required}
} {
    Edit a projection. The parameters are explained in the 
    logger::projection::new proc.

    @return The return value of db_dml

    @author Peter Marklund
} {
    db_dml update_projection {}
}

ad_proc -public logger::projection::delete {
    {-projection_id:required}
} {
    Delete a projection with a certain id

    @param projection_id The id of the projection to delete

    @return The return value from db_dml

    @author Peter Marklund
} {
    db_dml delete_projection {}
}

ad_proc -public logger::projection::get {
    {-projection_id:required}
    {-array:required}
} {
    Retrieve attributes of the projection with given id into an 
    array (using upvar) in the callers scope. The
    array will contain the keys projection_id, project_id, variable_id, start_time,
    end_time, value, name, and description.

    @param projection_id The id of the projection to retrieve information about
    @param array The name of the array in the callers scope where the information will
                 be stored

    @return The return value from db_1row. Throws an error if the projection doesn't exist.

    @author Peter Marklund
} {
    upvar $array projection_array

    db_1row select_projection {} -column_array projection_array    
}
