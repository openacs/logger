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

if { ![info exists selected_variable_unit] } {
    set selected_variable_unit ""
}

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

set value_total "0"

db_multirow -extend action_links entries select_entries "
    select le.entry_id as id,
           acs_permission.permission_p(le.entry_id, :user_id, 'delete') as delete_p,
           le.time_stamp,
           lv.name as variable_name,
           le.value,
           lv.unit,
           le.description,
           lp.name as project_name,
           submitter.first_names || ' ' || submitter.last_name as user_name
    from logger_entries le,
         logger_variables lv,
         logger_projects lp,
         acs_objects ao,
         cc_users submitter
    where le.variable_id = lv.variable_id
      and le.project_id = lp.project_id
      and ao.object_id = le.entry_id
      and ao.creation_user = submitter.user_id
    [ad_decode $where_clauses "" "" "and [join $where_clauses "\n    and "]"]
    order by le.time_stamp desc, ao.creation_date desc
" {
    set description_max_length 50
    if { [string length $description] > $description_max_length } {
        set description "[string range $description 0 [expr $description_max_length - 4]]..."
    }

    set action_links_list [list]
    lappend action_links_list "<a href=\"log?entry_id=$id\">display</a>"
    if { $delete_p } {
        set onclick_script "return confirm('Are you sure you want to delete log entry with $value $unit $variable_name on $time_stamp?');"
        lappend action_links_list "<a href=\"log-delete?entry_id=$id\" onclick=\"$onclick_script\">delete</a>"
    }
    if { [llength $action_links_list] > 0 } {
        set action_links "\[ [join $action_links_list " | "] \]"
    } else {
        set action_links ""
    }

    set value_total [expr $value_total + $value]
}
