ad_page_contract {
    User index page for the Logger application.
    
    @author Peter marklund (peter@collaboraid.biz)
    @creation-date 2003-04-08
    @cvs-id $Id$
} {
    {selected_project_id:integer ""}
    {selected_variable_id:integer ""}
    {selected_projection_id:integer ""}
    {selected_user_id:integer ""}
    {selected_start_date ""}
    {selected_end_date ""}
}

set package_id [ad_conn package_id]
set current_user_id [ad_conn user_id]
set admin_p [permission::permission_p -object_id $package_id -privilege admin]

set filter_var_list {
    selected_project_id
    selected_variable_id
    selected_projection_id
    selected_user_id
    selected_start_date
    selected_end_date
}


###########
#
# Initialize project, variable, projection, and user names
#
###########

# We need the name of the selected project in the adp
if { ![empty_string_p $selected_project_id] } {
    logger::project::get -project_id $selected_project_id -array project_array
    set selected_project_name $project_array(name)
} else {
    set selected_project_name ""
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

if { ![empty_string_p $selected_projection_id] } {
    # Projection selected - use the date range of that projection

    logger::projection::get -projection_id $selected_projection_id -array projection_array

    set selected_projection_name $projection_array(name)
    set selected_projection_value $projection_array(value)
} else {
    set selected_projection_name ""
    set selected_projection_value ""
}

# Need the name of the selected user in the adp
if { ![empty_string_p $selected_user_id] } {
    set selected_user_name [person::name -person_id $selected_user_id]
}

###########
#
# Date Filter
#
###########

# Create the form
set export_var_list {selected_project_id selected_variable_id selected_projection_id selected_user_id}
ad_form -name time_filter -export $export_var_list -method GET -form {
    {start_date:text
        {label "From"}
        {html { style "font-size: 100%;" size 10 } }
    }
    {end_date:text
        {label "To"}
        {html { style "font-size: 100%;" size 10 } }
    }
    {go:text(submit)
        {label "Go"}
        {html {style {font-size: 100%;}}}
    }
} -on_request {
    set start_date $selected_start_date
    set end_date $selected_end_date
} -on_submit {
    if { ![catch { 
        set start_seconds [clock scan $start_date] 
        set end_seconds [clock scan $end_date] 
    }] } {
        if { $start_seconds < $end_seconds } {
            set selected_start_date [clock format $start_seconds -format "%Y-%m-%d"]
            set selected_end_date [clock format $end_seconds -format "%Y-%m-%d"]
        } else {
            set selected_start_date [clock format $end_seconds -format "%Y-%m-%d"]
            set selected_end_date [clock format $start_seconds -format "%Y-%m-%d"]
        }
    }
    # Redirect so we get the dates in pretty mode
    ad_returnredirect ".?[export_vars $filter_var_list]"
    ad_script_abort
}




###########
#
# Select projects
#
###########

if { [exists_and_not_null selected_project_id] } {
    set all_projects_url ".?[export_vars -exclude { selected_project_id } $filter_var_list]"
} else {
    set all_projects_url {}
}

set no_project_p 1

db_multirow -extend { filter_name url entry_add_url selected_p clear_url } filters select_projects {
    select lp.project_id as unique_id,
           lp.name
    from logger_projects lp,
         logger_project_pkg_map lppm
    where lp.project_id = lppm.project_id
      and lppm.package_id = :package_id
    order by lp.name
} {
    set filter_name "Projects"

    set url ".?[export_vars -override { { selected_project_id $unique_id } } $filter_var_list]"
    set entry_add_url "log?[export_vars { { project_id $unique_id } {variable_id $selected_variable_id}}]"
    set selected_p [string equal $selected_project_id $unique_id]

    set project_name_max_length 30
    if { [string length $name] > $project_name_max_length } {
        set name "[string range $name 0 [expr $project_name_max_length - 4]]..."
    }

    set clear_url $all_projects_url

    set no_project_p 0
}

if { $no_project_p } {
    ad_return_template "no-projects"
    return
}



###########
#
# Select variables
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

db_multirow -append -extend { filter_name url entry_add_url selected_p clear_url } filters select_variables "
    select lv.variable_id as unique_id,
           lv.name || ' (' || lv.unit || ')' as name
    from logger_variables lv,
         logger_projects lp,
         logger_project_var_map lpvm
    where lp.project_id = lpvm.project_id
      and lv.variable_id = lpvm.variable_id
    [ad_decode $where_clauses "" "" "and [join $where_clauses "\n    and "]"]
    group by lv.variable_id, lv.name, lv.unit
" {
    set filter_name "Variables"
    set url ".?[export_vars -override { {selected_variable_id $unique_id} } $filter_var_list]"
    if { ![empty_string_p $selected_project_id] } {
        # A project is selected - enable logging
        set entry_add_url "log?[export_vars { { variable_id $unique_id } {project_id $selected_project_id}}]"
    } else {
        # No project selected - we wont enable those url:s
        set entry_add_url ""
    }
    set selected_p [string equal $selected_variable_id $unique_id]
    set clear_url {}
}

###########
#
# Select users
#
###########

if { [exists_and_not_null selected_user_id] } {
    set all_users_url ".?[export_vars -exclude { selected_user_id } $filter_var_list]"
} else {
    set all_users_url {}
}

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

db_multirow -append -extend { filter_name url entry_add_url selected_p clear_url } filters select_users "
    select submitter.user_id as unique_id,
           submitter.first_names || ' ' || submitter.last_name as name
    from   cc_users submitter,
           logger_entries le,
           acs_objects ao
    where  ao.object_id = le.entry_id
    and    submitter.user_id = ao.creation_user
    and    ([ad_decode $where_clauses "" "" "[join $where_clauses "\n    and "]"]
            or submitter.user_id = :current_user_id
           )
    group  by submitter.user_id, submitter.first_names, submitter.last_name
" {
    set filter_name "Users"
    set url ".?[export_vars -override { {selected_user_id $unique_id} } $filter_var_list]"
    set entry_add_url {}
    set selected_p [string equal $selected_user_id $unique_id]
    set clear_url $all_users_url
}

###########
#
# Select projections
#
###########

# Only makes sense to show projections for a selected project and variable
if { ![empty_string_p $selected_project_id] && ![empty_string_p $selected_variable_id] } {
    db_multirow -extend { url } projections select_projections {
        select lpe.projection_id,
               lpe.name
        from logger_projections lpe
        where lpe.project_id = :selected_project_id
          and lpe.variable_id = :selected_variable_id
    } {
        set url ".?[export_vars {{selected_projection_id $projection_id} {selected_user_id $selected_user_id} {selected_project_id $selected_project_id} {selected_variable_id $selected_variable_id}}]"        
    }
}

#####
#
# Date filters
#
#####

if { [exists_and_not_null selected_start_date] || [exists_and_not_null selected_end_date] } {
    set date_clear_url ".?[export_vars -exclude { selected_start_date selected_end_date } $filter_var_list]"
} else {
    set date_clear_url {}
}

set custom_p [expr ![empty_string_p $date_clear_url]]

set filter_name "Date"

foreach type { this_week last_week past_7 this_month last_month past_30 } {
    switch $type {
        this_week {
            set name "This week"
            set new_start_date [clock format [clock scan "-[clock format [clock seconds] -format %w] days"] -format "%Y-%m-%d"]
            set new_end_date [clock format [clock scan "[expr 6-[clock format [clock seconds] -format %w]] days"] -format "%Y-%m-%d"]
        }
        last_week {
            set name "Last week"
            set new_start_date [clock format [clock scan "[expr -7-[clock format [clock seconds] -format %w]] days"] -format "%Y-%m-%d"]
            set new_end_date [clock format [clock scan "[expr -1-[clock format [clock seconds] -format %w]] days"] -format "%Y-%m-%d"]
        }
        past_7 {
            set name "Past 7 days"
            set new_start_date [clock format [clock scan "-1 week 1 day"] -format "%Y-%m-%d"]
            set new_end_date [clock format [clock seconds] -format "%Y-%m-%d"]
        }
        this_month {
            set name "This month"
            set new_start_date [clock format [clock scan "[expr 1-[clock format [clock seconds] -format %d]] days"] -format "%Y-%m-%d"]
            set new_end_date [clock format [clock scan "1 month -1 day" -base [clock scan $new_start_date]] -format  "%Y-%m-%d"]
        } 
        last_month {
            set name "Last month"
            set new_start_date [clock format [clock scan "-1 month [expr 1-[clock format [clock seconds] -format %d]] days"] -format "%Y-%m-%d"]
            set new_end_date [clock format [clock scan "1 month -1 day" -base [clock scan $new_start_date]] -format  "%Y-%m-%d"]
        } 
        past_30 {
            set name "Past 30 days"
            set new_start_date [clock format [clock scan "-1 month 1 day"] -format "%Y-%m-%d"]
            set new_end_date [clock format [clock seconds] -format "%Y-%m-%d"]
        }
    }

    set url ".?[export_vars -override { { selected_start_date $new_start_date } { selected_end_date $new_end_date }} $filter_var_list]"

    set selected_p [expr [string equal $selected_start_date $new_start_date] && [string equal $selected_end_date $new_end_date]]

    # if selected_p is set, we'll clear custom_p
    set custom_p [expr $custom_p && !$selected_p]

    # unique_id name filter_name url entry_add_url selected_p clear_url
    multirow append filters "" $name $filter_name $url "" $selected_p $date_clear_url
}

# Custom
if { $custom_p } {
    multirow append filters "" "Custom range" $filter_name "" "" $custom_p $date_clear_url
}



