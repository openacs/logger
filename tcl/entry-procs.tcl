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
    {-party_id ""}
    {-task_item_id ""}
    {-project_item_id ""}
    {-update_status:boolean}
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
    @param party_id       The party that is entering the 
    logged entry. Defaults to ad_conn user_id if nothing is passed in

    @param task_item_id If passed in, the project-manager task
    to log time against

    @param project_item_id If passed in, the project-manager project

    @param update_status_p If set, updates the project manager project
    status, using pm::project::compute_status

    @see pm::project::compute_status

    @return The entry_id of the created project.

    @author Peter Marklund
} {
    logger::util::set_vars_from_ad_conn {creation_user creation_ip}

    if {[exists_and_not_null party_id]} {
        set creation_user $party_id
    }
    
    set entry_id [db_exec_plsql insert_entry {}]

    # The creator can admin his own entry
    permission::grant -party_id $creation_user -object_id $entry_id -privilege admin

    # if we have a task_id, then we need to note that this
    # entry is logged to a particular task.
    if {[exists_and_not_null task_item_id]} {
        db_dml delete_logger_map {
            DELETE FROM
            pm_task_logger_proj_map
            WHERE
            logger_entry = :entry_id
        }

        db_dml add_logger_map "
                INSERT INTO
                pm_task_logger_proj_map
                (task_item_id,
                 logger_entry)
                VALUES
                (:task_item_id,
                 :entry_id)
             "
        
        pm::task::update_hours \
            -task_item_id $task_item_id \
            -update_tasks_p t

        if { $update_status_p } {
            pm::project::compute_status $project_item_id
        }
    }


    return $entry_id
}

ad_proc -public logger::entry::edit {
    {-entry_id:required}
    {-value:required}
    {-time_stamp:required}
    {-description ""}
    {-task_item_id ""}
    {-project_item_id ""}
    {-update_status:boolean}
} {
    Edit a entry.

    @param entry_id The id of the entry to edit
    @param value          The new value of the entry
    @param time_stamp     The new time stamp of the entry
    @param description    The new description of the entry
    @param task_item_id If passed in, the project-manager task
    to log time against

    @param project_item_id If passed in, the project-manager project

    @param update_status If set, updates the project manager project
    status, using pm::project::compute_status

    @see pm::project::compute_status

    @return The return value from db_dml

    @author Peter Marklund
} {
    db_dml update_entry {}

    # all ignored if project-manager isn't installed and linked

    if {[logger::util::project_manager_linked_p]} {

        # delete any linked in tasks (an entry could be linked to a
        # task, and the user could decide to log against the project only)
        db_dml delete_logger_map {
            DELETE FROM
            pm_task_logger_proj_map
            WHERE
            logger_entry = :entry_id
        }

        # if we have a task_id, then we need to note that this
        # entry is logged to a particular task.
        if {[exists_and_not_null task_item_id]} {
            
            db_dml add_logger_map "
                INSERT INTO
                pm_task_logger_proj_map
                (task_item_id,
                 logger_entry)
                VALUES
                (:task_item_id,
                 :entry_id)
             "
            
            pm::task::update_hours \
                -task_item_id $task_item_id \
                -update_tasks_p t
            
        }

        if { $update_status_p } {
            pm::project::compute_status $project_item_id
        }

    }
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
    value, time_stamp, description, creation_user, and creation_date.

    @param entry_id The id of the entry to retrieve information about
    @param array The name of the array in the callers scope where the information will
                 be stored

    @return The return value from db_1row. Throws an error if the entry doesn't exist.

    @author Peter Marklund
} {
    upvar $array entry_array

    db_1row select_entry {} -column_array entry_array
}


ad_proc -public logger::entry::task_id {
    -entry_id:required
} {
    Returns the task_id corresponding to an entry if one exists
    
    This should only be called if project manager is installed.

    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-05-28
    
    @param entry_id

    @return empty string if no task corresponds to this entry
    
    @error 
} {
    return [db_string task_id { } -default ""]
}


ad_proc -public logger::entry::pm_before_change {
    {-task_item_id:required}
} {
    Stores the state of the task before the hour are logged and the 
    percent complete changed. 
    
    @author  (jader-ibr@bread.com)
    @creation-date 2004-11-17
    
    @param task_item_id

    @return 
    
    @error 
} {

    pm::task::get \
        -tasks_item_id                   [list $task_item_id] \
        -one_line_array                  old_one_line \
        -description_array               old_description \
        -description_mime_type_array     old_description_mime_type \
        -estimated_hours_work_array      old_estimated_hours_work \
        -estimated_hours_work_min_array  old_estimated_hours_work_min \
        -estimated_hours_work_max_array  old_estimated_hours_work_max \
        -dependency_array                old_dependency \
        -percent_complete_array          old_percent_complete \
        -end_date_day_array              old_end_date_day \
        -end_date_month_array            old_end_date_month \
        -end_date_year_array             old_end_date_year \
        -project_item_id_array           old_project_item_id \
	-priority_array                  old_priority_array \
        -set_client_properties_p         t
}


ad_proc -public logger::entry::pm_after_change {
    {-task_item_id:required}
    {-new_percent_complete:required}
    {-old_percent_complete:required}
} {
    Updates total percent complete for project manager,
    adds a comment on the changes made, and if the change opens
    or closes the task, sends out an email notification.
    
    @author  (jader-ibr@bread.com)
    @creation-date 2004-11-17
    
    @param task_item_id

    @param new_percent_complete

    @param old_percent_complete

    @return 
    
    @error 
} {

    set user_id [ad_conn user_id]
    set peeraddr [ad_conn peeraddr]

    pm::task::update_percent \
        -task_item_id $task_item_id \
        -percent_complete $new_percent_complete
    
    # figure out what changed and notify everyone
    
    set task_item_id_array(1) $task_item_id
    set number   1
    set comments(1) ""
    set comments_mime_type(1) "text/html"
    
    pm::task::what_changed \
        -task_item_id_array          task_item_id_array \
        -number                      $number \
        -comments_array              comments \
        -comments_mime_type_array    comments_mime_type
    
    if {[string length $comments(1)] > 0} {
        
        # add comment to task
        pm::util::general_comment_add \
            -object_id $task_item_id \
            -title [pm::task::name -task_item_id $task_item_id] \
            -comment $comments(1) \
            -mime_type $comments_mime_type(1) \
            -user_id $user_id \
            -peeraddr $peeraddr \
            -type "task" \
            -send_email_p f
        
        # if the old_percent was >= 100 and now less, or
        # the old_percent was < 100 and is now more, then
        # we need to send out an email to notify everyone
        
        if { \
                 $old_percent_complete >= 100 && \
                 $new_percent_complete <  100 || \
                 $old_percent_complete <  100 && \
                 $new_percent_complete >= 100} {
            
            # send email notification
            pm::task::email_alert \
                -task_item_id $task_item_id \
                -edit_p t \
                -comment $comments(1) \
                -comment_mime_type $comments_mime_type(1)
        }
    }
}
