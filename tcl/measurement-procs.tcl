ad_library {
    Procedures in the logger::measurement namespace. Those procedures
    operate on logger measurement objects.
    
    @creation-date 4:th of April 2003
    @author Peter Marklund (peter@collaboraid.biz)
    @cvs-id $Id$
}

namespace eval logger::measurement {}

ad_proc -public logger::measurement::new {
    {-measurement_id ""}
    {-project_id:required}
    {-variable_id:required}
    {-value:required}
    {-time_stamp:required}
    {-description ""}
} {
    <p>
      Create a logger measurement.
    </p>

    <p>
      This proc requires there to be an HTTP connection as the creation_user and creation_ip
      variables are taken from ad_conn.
    </p>

    @param measurement_id An optional pre-generated id of the measurement
    @param project_id     The id of the project the measurement is for
    @param variable_id    The id of the variable the measurement is for
    @param value          The value of the measurment
    @param time_stamp     The point in time the measurment is tied to. Must be on ANSI format.
                          Can be a date or a date and a time.
    @param description    A short (less than 4000 chars) text describing the measurement.

    @return The measurement_id of the created project.

    @author Peter Marklund
} {
    set creation_ip [ad_conn peeraddr]
    set creation_user [ad_conn user_id]

    set measurement_id [db_exec_plsql insert_measurement {}]

    return $measurement_id
}

ad_proc -public logger::measurement::edit {
    {-measurement_id:required}
    {-value:required}
    {-time_stamp:required}
    {-description ""}    
} {
    Edit a measurement.

    @param measurement_id The id of the measurement to edit
    @param value          The new value of the measurement
    @param time_stamp     The new time stamp of the measurement
    @param description    The new description of the measurement

    @return The return value from db_dml

    @author Peter Marklund
} {
    db_dml update_measurement {}
}

ad_proc -public logger::measurement::delete {
    {-measurement_id:required}
} {
    Delete the measurement with given id.

    @param measurement_id The id of the measurement to delete

    @return The return value from db_exec_plsql

    @author Peter Marklund
} {
    db_exec_plsql delete_measurement {}
}

ad_proc -public logger::measurement::get {
    {-measurement_id:required}
    {-array:required}
} {
    Retrieve info about the measurement with given id into an 
    array (using upvar) in the callers scope. The
    array will contain the keys measruement_id, project_id, variable_id,
    value, time_stamp, description.

    @param measurement_id The id of the measurement to retrieve information about
    @param array The name of the array in the callers scope where the information will
                 be stored

    @return The return value from db_1row. Throws an error if the measurement doesn't exist.

    @author Peter Marklund
} {
    upvar $array measurement_array

    db_1row select_measurement {} -column_array measurement_array
}
