ad_library {
    Procedures in the logger::entry namespace. Those procedures
    operate on logger entry objects.
    
    @creation-date 4:th of April 2003
    @author Peter Marklund (peter@collaboraid.biz)
    @cvs-id $Id$
}

namespace eval logger::entry {}

ad_proc -public logger::entry::new {
    {-entry_id ""}
    {-project_id:required}
    {-variable_id:required}
    {-value:required}
    {-time_stamp:required}
    {-description ""}
} {
    <p>
      Create a logger entry.
    </p>

    <p>
      This proc requires there to be an HTTP connection as the creation_user and creation_ip
      variables are taken from ad_conn.
    </p>

    @param entry_id An optional pre-generated id of the entry
    @param project_id     The id of the project the entry is for
    @param variable_id    The id of the variable the entry is for
    @param value          The value of the measurment
    @param time_stamp     The point in time the measurment is tied to. Must be on ANSI format.
                          Can be a date or a date and a time.
    @param description    A short (less than 4000 chars) text describing the entry.

    @return The entry_id of the created project.

    @author Peter Marklund
} {
    logger::util::set_vars_from_ad_conn {creation_user creation_ip}
    
    set entry_id [db_exec_plsql insert_entry {}]

    return $entry_id
}

ad_proc -public logger::entry::edit {
    {-entry_id:required}
    {-value:required}
    {-time_stamp:required}
    {-description ""}    
} {
    Edit a entry.

    @param entry_id The id of the entry to edit
    @param value          The new value of the entry
    @param time_stamp     The new time stamp of the entry
    @param description    The new description of the entry

    @return The return value from db_dml

    @author Peter Marklund
} {
    db_dml update_entry {}
}

ad_proc -public logger::entry::delete {
    {-entry_id:required}
} {
    Delete the entry with given id.

    @param entry_id The id of the entry to delete

    @return The return value from db_exec_plsql

    @author Peter Marklund
} {
    db_exec_plsql delete_entry {}
}

ad_proc -public logger::entry::get {
    {-entry_id:required}
    {-array:required}
} {
    Retrieve info about the entry with given id into an 
    array (using upvar) in the callers scope. The
    array will contain the keys measruement_id, project_id, variable_id,
    value, time_stamp, description.

    @param entry_id The id of the entry to retrieve information about
    @param array The name of the array in the callers scope where the information will
                 be stored

    @return The return value from db_1row. Throws an error if the entry doesn't exist.

    @author Peter Marklund
} {
    upvar $array entry_array

    db_1row select_entry {} -column_array entry_array
}
