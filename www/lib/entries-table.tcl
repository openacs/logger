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

db_1row select_variable_info {
    select name,
           unit
    from   logger_variables
    where  variable_id = :selected_variable_id
} -column_array variable

if { [exists_and_not_null selected_variable_id] } {
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

set value_total "0"

db_multirow -extend { edit_url delete_url delete_onclick user_chunk selected_p } entries select_entries "
    select le.entry_id as id,
           acs_permission.permission_p(le.entry_id, :user_id, 'delete') as delete_p,
           le.time_stamp,
           to_char(le.time_stamp, 'fmMMfm-fmDDfm-YYYY') as time_stamp_pretty,
           le.value,
           le.description,
           lp.name as project_name,
           submitter.user_id,
           submitter.first_names || ' ' || submitter.last_name as user_name
    from logger_entries le,
         logger_projects lp,
         acs_objects ao,
         cc_users submitter
    where le.project_id = lp.project_id
      and ao.object_id = le.entry_id
      and ao.creation_user = submitter.user_id
    [ad_decode $where_clauses "" "" "and [join $where_clauses "\n    and "]"]
    order by le.time_stamp desc, ao.creation_date desc
" {
    set description_max_length 50
    if { [string length $description] > $description_max_length } {
        set description "[string range $description 0 [expr $description_max_length - 4]]..."
    }

    set project_name_max_length 20
    if { [string length $project_name] > $project_name_max_length } {
        set project_name "[string range $project_name 0 [expr $project_name_max_length - 4]]..."
    }

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
}
