ad_page_contract {
    User index page for the Logger application.
    
    @author Peter marklund (peter@collaboraid.biz)
    @creation-date 2003-04-08
    @cvs-id $Id$
} {
    {selected_project_id:integer ""}
    {selected_variable_id:integer ""}
    {selected_user_id:integer ""}
    {start_date:array {}}
    {end_date:array {}}
}

set package_id [ad_conn package_id]
set current_user_id [ad_conn user_id]
set admin_p [permission::permission_p -object_id $package_id -privilege admin]

###########
#
# Date handling
#
###########

# Set default values for start and end date if the form hasn't been submitted yet
if { [array size start_date] == 0 } {
    # Default end date is now (today)
    set default_end_date_seconds [clock seconds]

    set end_date(year) [clock format $default_end_date_seconds -format "%Y"]
    set end_date(month) [clock format $default_end_date_seconds -format "%m"]
    set end_date(day) [clock format $default_end_date_seconds -format "%d"]

    # Default start date is N days back
    set number_of_days_back 31
    set seconds_per_day [expr 60*60*24]
    set default_start_date_seconds [expr $default_end_date_seconds - 31 * $seconds_per_day]

    set start_date(year) [clock format $default_start_date_seconds -format "%Y"]
    set start_date(month) [clock format $default_start_date_seconds -format "%m"]
    set start_date(day) [clock format $default_start_date_seconds -format "%d"]
}

# Get the ANSI representations of the dates
set start_date_ansi "$start_date(year)-$start_date(month)-$start_date(day)"
set end_date_ansi "$end_date(year)-$end_date(month)-$end_date(day)"

###########
#
# Project and variable default values and names
#
###########

# We need the name of the selected project in the adp
if { ![empty_string_p $selected_project_id] } {
    logger::project::get -project_id $selected_project_id -array project_array
    set selected_project_name $project_array(name)
} else {
    set selected_project_name ""
}

# Likewise, need the name of the selected user in the adp
if { ![empty_string_p $selected_user_id] } {
    set selected_user_name [person::name -person_id $selected_user_id]
}

# Find a suitable default variable_id
# No more than one variable will be selected on this page
# Under unusual circumstances no variable will be selected
# (variable_id will be the empty string)
if { [empty_string_p $selected_variable_id] } {
    # No variable selected

    # First default to the variable the user last logged hours in
    # Use any selected project and all projects otherwise
    if { ![empty_string_p $selected_project_id] } {
        set project_clause "le.project_id = :selected_project_id"
    } else {
        set project_clause ""
    }
    set selected_variable_id [db_string last_logged_variable_id "
        select variable_id
        from logger_entries le,
             acs_objects ao
        where ao.creation_date = (select max(ao.creation_date)
                               from logger_entries le,
                                    acs_objects ao
                               where ao.object_id = le.entry_id
                               [ad_decode $project_clause "" "" "and $project_clause"]
                              )
          and ao.object_id = le.entry_id
        [ad_decode $project_clause "" "" "and $project_clause"]
    " -default ""]

    if { [empty_string_p $selected_variable_id] } {
        # The user has not logger hours yet

        if { ![empty_string_p $selected_project_id] } {
            # A project is selected - use the primary variable
            set selected_variable_id [logger::project::get_primary_variable -project_id $selected_project_id]
        } else {
            # No project is selected and the user has never logged hours before
            # Should we use time in this unusual case? For now we don't select any variable
            set selected_variable_id ""
        }
    }
}

# Need the name of the selected variable in the adp
if { ![empty_string_p $selected_variable_id] } {
    logger::variable::get -variable_id $selected_variable_id -array variable_array
    set selected_variable_name $variable_array(name)
    set selected_variable_unit $variable_array(unit)
} else {
    set selected_variable_name ""
    set selected_variable_unit ""
}

###########
#
# Time Filter
#
###########

# Create the form
template::form create time_filter -method GET
# Export the other filter variables
template::element create time_filter selected_project_id \
    -widget hidden \
    -value $selected_project_id
template::element create time_filter selected_variable_id \
    -widget hidden \
    -value $selected_variable_id
template::element create time_filter selected_user_id \
    -widget hidden \
    -value $selected_user_id
template::element create time_filter start_date \
    -label "Start day:" \
    -widget date \
    -datatype date
template::element create time_filter end_date \
    -label "End day:" \
    -widget date \
    -datatype date

# Set the values of the start and end date in the form
element set_properties time_filter start_date \
    -value [eval template::util::date::create $start_date(year) $start_date(month) $start_date(day)]
element set_properties time_filter end_date \
    -value [eval template::util::date::create $end_date(year) $end_date(month) $end_date(day)]

###########
#
# Log entries
#
###########

# We let start date be beginning of day but end date be end of day so that if
# both are the same day you get the entries during that day
set end_date_seconds [clock scan "$end_date(year)-$end_date(month)-$end_date(day)"]
set end_date_plus_one_seconds [expr $end_date_seconds + 60*60*24]
set end_date_plus_one_ansi [clock format $end_date_plus_one_seconds -format "%Y-%m-%d"]

# template lib/entries-table is included - see adp


###########
#
# Projects
#
###########

set all_projects_url "index?[export_vars {{selected_variable_id $selected_variable_id} {selected_user_id $selected_user_id}}]"

db_multirow -extend { url log_url } projects select_projects {
    select lp.project_id,
           lp.name
    from logger_projects lp,
         logger_project_pkg_map lppm
    where lp.project_id = lppm.project_id
      and lppm.package_id = :package_id
    order by lp.name
} {
    # We always show the current user in the user filter so if we are showing "my entries" carry over the selected_user_id
    # when selecting a project
    set url_export_list {{selected_project_id $project_id}}
    if { [string equal $selected_user_id $current_user_id] } {
        lappend url_export_list selected_user_id
    }
    set url "index?[export_vars $url_export_list]"
    set log_url "log?[export_vars { project_id {variable_id $selected_variable_id}}]"
}

###########
#
# Variables
#
###########

set where_clauses [list]
if { ![empty_string_p $selected_project_id] } {
    lappend where_clauses "lp.project_id = :selected_project_id"
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
    group by lv.variable_id, lv.name, lv.unit
" {
    set url "index?[export_vars {{selected_variable_id $variable_id} {selected_project_id $selected_project_id} {selected_user_id $selected_user_id}}]"
    if { ![empty_string_p $selected_project_id] } {
        # A project is selected - enable logging
        set log_url "log?[export_vars { variable_id {project_id $selected_project_id}}]"
    } else {
        # No project selected - we wont enable those url:s
        set log_url ""
    }
}

###########
#
# Users
#
###########

set all_users_url "index?[export_vars {{selected_variable_id $selected_variable_id} {selected_project_id $selected_project_id}}]"

set where_clauses [list]
if { ![empty_string_p $selected_project_id] } {
    # Select all users who have logged in selected project
    lappend where_clauses "le.project_id = :selected_project_id"
} else {
    # Select all users who have logged in any project mapped to
    # this package
    lappend where_clauses \
        "exists (select 1
                 from logger_project_pkg_map
                 where project_id = le.project_id
                 and package_id = :package_id
                 )"
} 

db_multirow -extend { url } users select_users "
    select submitter.user_id as user_id,
           submitter.first_names as first_names,
           submitter.last_name as last_name
    from cc_users submitter,
         logger_entries le,
         acs_objects ao
    where ao.object_id = le.entry_id
      and submitter.user_id = ao.creation_user
      and ([ad_decode $where_clauses "" "" "[join $where_clauses "\n    and "]"]
           or submitter.user_id = :current_user_id
          )
    group by submitter.user_id, submitter.first_names, submitter.last_name
" {
    set url "index?[export_vars {{selected_user_id $user_id} {selected_project_id $selected_project_id} {selected_variable_id $selected_variable_id}}]"
}
