ad_page_contract {
    User index page for the Logger application.
    
    @author Peter marklund (peter@collaboraid.biz)
    @creation-date 2003-04-08
    @cvs-id $Id$
} {
    project_id:optional,integer
    variable_id:optional,integer
}

set package_id [ad_conn package_id]
set user_id [ad_conn user_id]
set admin_p [permission::permission_p -object_id $package_id -privilege admin]

# Default variable_id to the id of the variable the user last logged in
# At any one time exactly one variable is selected on this page
if { ![exists_and_not_null variable_id] } {
    set variable_id [db_string last_logged_variable_id {
        select variable_id
        from logger_entries le
        where le.time_stamp = (select max(time_stamp)
                             from logger_entries)
    } -default ""]
}

# Need the selected variable id in the adp as variable_id will be set to some other value
# in the multiple loop
set selected_variable_id $variable_id
logger::variable::get -variable_id $variable_id -array variable_array
set selected_variable_name $variable_array(name)

# Likewise need the selected project id in the adp
if { [exists_and_not_null project_id] } {
    set selected_project_id $project_id
    logger::project::get -project_id $project_id -array project_array
    set selected_project_name $project_array(name)
} else {
    set selected_project_id ""
}

###########
#
# Log entries
#
###########

set where_clauses [list]
if { [exists_and_not_null project_id] } {
    # Only selected project
    lappend where_clauses "lp.project_id = :project_id"
} else {
    # All projects mapped to the package
    lappend where_clauses \
        "exists (select 1
                 from logger_project_pkg_map
                 where project_id = lp.project_id
                 and package_id = :package_id
                )"
}

if { [exists_and_not_null variable_id] } {
    lappend where_clauses "lm.variable_id = :variable_id"
}

db_multirow -extend action_links entries select_entries "
    select lm.entry_id as id,
           acs_permission.permission_p(lm.entry_id, :user_id, 'write') as write_p,
           acs_permission.permission_p(lm.entry_id, :user_id, 'delete') as delete_p,
           lm.time_stamp,
           lv.name as variable_name,
           lm.value,
           lv.unit,
           lm.description,
           lp.name as project_name
    from logger_entries lm,
         logger_variables lv,
         logger_projects lp
    where lm.variable_id = lv.variable_id
      and lm.project_id = lp.project_id
    [ad_decode $where_clauses "" "" "and [join $where_clauses "\n    and "]"]
    order by lm.time_stamp desc
" {
    set description_max_length 50
    if { [string length $description] > $description_max_length } {
        set description "[string range $description 0 [expr $description_max_length - 4]]..."
    }

    set action_links_list [list]
    if { $write_p } {
        lappend action_links_list "<a href=\"log?entry_id=$id\">edit</a>"
    }
    if { $delete_p } {
        set onclick_script "return confirm('Are you sure you want to delete log entry with $value $unit $variable_name on $time_stamp?');"
        lappend action_links_list "<a href=\"log-delete?entry_id=$id\" onclick=\"$onclick_script\">delete</a>"
    }
    set action_links "\[ [join $action_links_list " | "] \]"
}

###########
#
# Projects
#
###########

set all_projects_url "index?[export_vars {{variable_id $selected_variable_id}}]"

db_multirow -extend { url log_url } projects select_projects {
    select lp.project_id,
           lp.name
    from logger_projects lp,
         logger_project_pkg_map lppm
    where lp.project_id = lppm.project_id
      and lppm.package_id = :package_id
    order by lp.name
} {
    set url "index?[export_vars project_id]"
    set log_url "log?[export_vars { project_id {variable_id $selected_variable_id}}]"
}

###########
#
# Variables
#
###########

set where_clauses [list]
if { [exists_and_not_null project_id] } {
    lappend where_clauses "lp.project_id = :project_id"
} else {
    lappend where_clauses \
        "exists (select 1
                 from logger_project_pkg_map
                 where project_id = lp.project_id
                 and package_id = :package_id
                 )"
}

db_multirow -extend { url log_url } variables select_variables "
    select lv.variable_id,
           lv.name,
           lv.unit
    from logger_variables lv,
         logger_projects lp,
         logger_project_var_map lpvm
    where lp.project_id = lpvm.project_id
      and lv.variable_id = lpvm.variable_id
    [ad_decode $where_clauses "" "" "and [join $where_clauses "\n    and "]"]
" {
    set url "index?[export_vars {variable_id project_id}]"
    if { [exists_and_not_null selected_project_id] } {
        # A project is selected - enable logging
        set log_url "log?[export_vars { variable_id {project_id $selected_project_id}}]"
    } else {
        # No project selected - we wont enable those url:s
        set log_url ""
    }
}
