# Displays list of log entries
#
# Expects:
#   selected_project_id
#   selected_variable_id
#   selected_user_id
#   selected_entry_id
#   start_date_ansi
#   end_date_ansi 
#   projection_value

set user_id [ad_conn user_id]
set package_id [ad_conn package_id]

set where_clauses [list]
if { [exists_and_not_null selected_project_id] } {
    # Only selected project
    lappend where_clauses "lp.project_id = :selected_project_id"
} else {
    # All projects mapped to the package
    lappend where_clauses \
        "exists (select 1
                 from logger_project_pkg_map
                 where project_id = lp.project_id
                 and package_id = :package_id
                )"
}

if { [exists_and_not_null selected_variable_id] } {
    db_1row select_variable_info {} -column_array variable

    lappend where_clauses "le.variable_id = :selected_variable_id"
}

if { [exists_and_not_null selected_user_id] } {
    lappend where_clauses "submitter.user_id = :selected_user_id"
}

if { [exists_and_not_null start_date_ansi] } {
    lappend where_clauses "le.time_stamp >= to_date(:start_date_ansi,'YYYY-MM-DD')"
}

if { [exists_and_not_null end_date_ansi] } {
    lappend where_clauses "le.time_stamp <= to_date(:end_date_ansi,'YYYY-MM-DD')"
}

if { ![exists_and_not_null selected_entry_id] } {
    set selected_entry_id {}
}

set value_total 0
set value_count 0

db_multirow -extend { edit_url delete_url delete_onclick user_chunk selected_p } entries select_entries {} {
    set description [string_truncate -len 50 $description]
    set project_name [string_truncate -len 20 $project_name]
    set selected_p [string equal $id $selected_entry_id]
    set action_links_list [list]
    set edit_url "log?[export_vars { { entry_id $id } }]"
    if { $delete_p } {
        set delete_onclick "return confirm('Are you sure you want to delete log entry with $value $variable(unit) $variable(name) on $time_stamp?');"
        set delete_url "log-delete?[export_vars { { entry_id $id } }]"
    } else {
        set delete_url ""
    }
    
    set user_chunk [ad_present_user $user_id $user_name]

    set value_total [expr $value_total + $value]
    incr value_count
}

if { $value_count > 0 } {
    set value_average [expr round(100 * $value_total / $value_count) / 100.0] }  {
    set value_average "n/a"
}

