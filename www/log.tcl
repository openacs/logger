ad_page_contract {
    Add/edit/display a log entry.
    
    @author Peter Marklund (peter@collaboraid.biz)
    @author Jade Rubick (jader@bread.com) project-manager integration
    @creation-date 2003-04-16
    @cvs-id $Id$
} {
    entry_id:integer,optional
    project_id:integer,optional
    variable_id:integer,optional
    {edit:boolean "f"}
    {return_url "."}
    {pm_project_id:integer ""}
    {pm_task_id:integer ""}
    {__refreshing_p "0"}
} -validate {
    project_id_required_in_add_mode {
        # For the sake of simplicity of the form 
        # we are requiring a project_id to be provided in add mode
        if { ![exists_and_not_null entry_id] && ![exists_and_not_null project_id] } {
            ad_complain "When adding a log entry a project_id must be provided (either entry_id or project_id must be present)."
        }
    }
}


# TODO: Make the recent entries list start on the date of the last entry

set package_id [ad_conn package_id]
set current_user_id [ad_maybe_redirect_for_registration]
set peeraddr   [ad_conn peeraddr]

if { [exists_and_not_null entry_id] } {
    set entry_exists_p [db_string entry_exists_p {}]                         
} else {
    set entry_exists_p 0
}

if { [string equal [form get_action log_entry_form] "done"] } {
    # User is done editing - redirect back to index page
    ad_returnredirect $return_url
    ad_script_abort
}

###########
#
# Get project and variable info
#
###########

# Get project and variable id
if { $entry_exists_p } {
    permission::require_permission -object_id $entry_id -privilege read

    # We have the entry_id so try to get project and variable_id from the database
    # for that entry    
    logger::entry::get -entry_id $entry_id -array entry_array
    set project_id $entry_array(project_id)
    set variable_id $entry_array(variable_id)
} 
  
# Get project_id if it's not provided
if { [exists_and_not_null entry_id] && ![exists_and_not_null project_id] } {
    logger::entry::get -entry_id $entry_id -array entry
    set project_id $entry(project_id)
}

# Default the variable we are logging in to the primary variable of the project
if { ![exists_and_not_null variable_id] } {
    set variable_id [logger::project::get_primary_variable -project_id $project_id]

    if { [empty_string_p $variable_id] } {
        ad_return_error "Project has no variable" "An administrator needs to associate a variable, such as time or expense, to this project before any logging can be done."
        ad_script_abort
    }
}

# We need project and variable names
logger::project::get -project_id $project_id -array project_array
logger::variable::get -variable_id $variable_id -array variable_array

# get the project_manager_url if this is related to project manager
set project_manager_url [logger::util::project_manager_url]

if {![empty_string_p $project_manager_url]} {
    # project manager is installed, so we set the corresponding project
    set pm_project_id [pm::project::get_project -logger_project $project_id]

    #we only call this if project_manager is installed (the url is
    #not empty)
    if { [exists_and_not_null entry_id] && [empty_string_p $pm_task_id]} {
        set pm_task_id [logger::entry::task_id -entry_id $entry_id]
    }
}

###########
#
# Build the form
#
###########

# The creator of a log entry can always edit it
if { $entry_exists_p } {
    set edit_p [expr [permission::permission_p -object_id $entry_id -privilege write] || \
                    $current_user_id == $entry_array(creation_user)]
} else {
    set edit_p 0
}

# Different page title and form mode when adding a log entry 
# versus displaying/editing one
if { [exists_and_not_null entry_id] || ${__refreshing_p} } {
    # Initial request in display or edit mode or a submit of the form
    set page_title "Edit Log Entry"

    if { [string equal $edit "t"] && $edit_p } {
        set ad_form_mode edit
    } else {
        set ad_form_mode display
    }

    if { ${__refreshing_p} } {
        set ad_form_mode edit
    }

} else {
    # Initial request in add mode
    set page_title "Add Log Entry"
    set ad_form_mode edit
}

set context [list $page_title]


# Build the log entry form elements
set actions [list]
if { $edit_p } {
    lappend actions { Edit edit }
}
lappend actions { Done done }

ad_form -name log_entry_form -cancel_url $return_url -mode $ad_form_mode \
    -actions $actions -form {
    entry_id:key(acs_object_id_seq)
}

# On various occasions we need to know if we are dealing with a submit with the
# form or an initial request (could also be with error message after unaccepted submit)
set submit_p [form is_valid log_entry_form]

ad_form -extend -name log_entry_form -export { project_id variable_id return_url } -form {
    {project:text(inform)
        {section "Project"}
        {label Project}
        {value $project_array(name)}
    }
}

if { [exists_and_not_null entry_id] && [logger::util::project_manager_linked_p] && [info exists entry_array]} {
    set the_project_id $entry_array(project_id)
} else {
    set the_project_id $project_id
}

if { [llength [category_tree::get_mapped_trees $project_id]] > 0 } {
    set focus "log_entry_form.category_id"
} else {
    set focus "log_entry_form.value"
}

category::ad_form::add_widgets \
    -container_object_id $the_project_id \
    -categorized_object_id [value_if_exists entry_id] \
    -form_name log_entry_form


# we want to give the option of choosing task if you have chosen a
# project. When a new task is chosen, we want to change the
# information shown about that task

if {[logger::util::project_manager_linked_p]} {

    set task_options [list]

    if {[exists_and_not_null pm_task_id]} {

        set task_options [pm::task::options_list \
                              -project_item_id $pm_project_id \
                              -dependency_task_ids [list $pm_task_id]]
    } else {

        set task_options [pm::task::options_list \
                              -project_item_id $pm_project_id]

    }
}

# Add form elements common to all modes
# The form builder date datatype doesn't take ANSI format date strings
# but wants dates in list format
ad_form -extend -name log_entry_form -form {
    {value:float
        {label $variable_array(name)}
        {after_html $variable_array(unit)}
	{html {size 7 maxlength 7}}
    }
    {description:text,optional
        {label Description} 
        {html {size 50}}
    }
    {time_stamp:date(date),to_sql(ansi),from_sql(ansi)
        {label Date}
    }
} 

# Additions to form if project-manager is involved.
if {[exists_and_not_null pm_project_id]} {

    # do I really need this both here and in the -on_refresh block? -jr

    if {[exists_and_not_null pm_task_id]} {
        db_1row get_task_values { }

        set my_task_id $pm_task_id
    } else {

        set my_task_id ""

    }


    ad_form -extend -name log_entry_form -form {
        
        {pm_project_id:text(hidden)
            {value $pm_project_id}
        }
        {pm_task_id:integer(select),optional
            {section "Task"}
            {label "Subject"}
            {options {$task_options}}
            {html {onChange "document.log_entry_form.__refreshing_p.value='1';submit()"}}
            {value $my_task_id}
            {help}
            {help_text "If you change this, please wait for the page to refresh"}
        }
        {status_description:text(inform)
            {label "Status"}
        }
    } 

    if {[exists_and_not_null pm_task_id]} {
        set display_hours [pm::task::hours_remaining \
                               -estimated_hours_work $estimated_hours_work \
                               -estimated_hours_work_min $estimated_hours_work_min \
                               -estimated_hours_work_max $estimated_hours_work_max \
                               -percent_complete $percent_complete \
                              ]
        
        set total_hours_work [pm::task::estimated_hours_work \
                                  -estimated_hours_work $estimated_hours_work \
                                  -estimated_hours_work_min $estimated_hours_work_min \
                                  -estimated_hours_work_max $estimated_hours_work_max \
                                 ]
    } else {
        set display_hours 0
        set total_hours_work 0
        set percent_complete 0
    }

    ad_form -extend -name log_entry_form -form {
        
        {remaining_work:text(inform)
            {label "Remaining work"}
            {value $display_hours}
            {after_html "hours"}
        }

        {total_hours_work:text(inform)
            {label "Total work"}
            {value $total_hours_work}
            {after_html "hours"}
        }
    } 

    ad_form -extend -name log_entry_form -form {

        {percent_complete:float
            {label "Complete"}
            {value $percent_complete}
            {after_html "%"}
            {html {size 5 maxlength 5}}
            {help}
            {help_text "Set to 100% to close the task, less to open it"}
        }
        
    } 

}


# set the headers so you can get back to project manager.

if { [exists_and_not_null pm_task_id] } {

    set context [list [list "${project_manager_url}task-one?task_id=$pm_task_id" "$task_title"] $page_title]

} elseif { [exists_and_not_null pm_project_id] } {

    set context [list [list "${project_manager_url}one?project_item_id=$pm_project_id" "$project_array(name)"] $page_title]

}

###########
#
# Execute the form
#
###########

ad_form -extend -name log_entry_form -select_query_name select_logger_entries -validate {
    {value 
        { [regexp {^-?([0-9]{1,6}|[0-9]{0,6}\.[0-9]{0,2})$} $value] }
        {The value may not contain more than two decimals and must be between -999999.99 and 999999.99}
    }
} -new_request {
    # Get the date of the last entry
    set time_stamp [ad_get_client_property logger time_stamp]
    if { [empty_string_p $time_stamp] } {
        set time_stamp [clock format [clock seconds] -format "%Y-%m-%d"]
    }
    set time_stamp [template::util::date::acquire ansi $time_stamp]
} -new_data {
    
    # jarkko: check to see if user has already added this entry and has come
    # back with her back button. If the entry exists, we edit it

    db_transaction {
        set exists_p [db_string check_if_exists {
            select 1
            from   logger_entries
            where  entry_id = :entry_id
        } -default "0"]
        
        if { !$exists_p } {

            # we want to keep track of what has changed if we are
            # logging against project manager
            if {[exists_and_not_null pm_task_id]} {

                set old_percent_complete $percent_complete
                logger::entry::pm_before_change \
                    -task_item_id $pm_task_id

            }

            logger::entry::new \
                -entry_id $entry_id \
                -project_id $project_id \
                -variable_id $variable_id \
                -value $value \
                -time_stamp $time_stamp \
                -description $description \
                -task_item_id $pm_task_id \
                -project_item_id $pm_project_id

            if {[exists_and_not_null pm_task_id]} {

                logger::entry::pm_after_change \
                    -task_item_id $pm_task_id \
                    -new_percent_complete $percent_complete \
                    -old_percent_complete $old_percent_complete

            }

        } else {

            # we want to keep track of what has changed if we are
            # logging against project manager
            if {[exists_and_not_null pm_task_id]} {
                
                set old_percent_complete $percent_complete
                logger::entry::pm_before_change \
                    -task_item_id $pm_task_id

            }

            logger::entry::edit \
                -entry_id $entry_id \
                -value $value \
                -time_stamp $time_stamp \
                -description "$description" \
                -task_item_id "$pm_task_id" \
                -project_item_id "$pm_project_id"

            if {[exists_and_not_null pm_task_id]} {

                pm::task::pm_after_change \
                    -task_item_id $pm_task_id \
                    -new_percent_complete $percent_complete \
                    -old_percent_complete $old_percent_complete

            }
            
        }
        
        category::map_object \
            -remove_old \
            -object_id $entry_id \
            [category::ad_form::get_categories \
                 -container_object_id $the_project_id]
    }
    
    # Remember this date, as the next entry is likely to be for the same date
    ad_set_client_property logger time_stamp $time_stamp

    # Present the user with an add form again for quick logging
    ad_returnredirect -message "Log entry for $value $variable_array(unit) with description \"$description\" added." [export_vars -base [ad_conn url] { project_id variable_id pm_project_id pm_task_id}]
    ad_script_abort

} -edit_data {
    db_transaction {

        if {[info exists pm_task_id] && [info exists pm_project_id]} {

            if {[exists_and_not_null pm_task_id]} {

                set old_percent_complete $percent_complete
                logger::entry::pm_before_change \
                    -task_item_id $pm_task_id

            }


            logger::entry::edit \
                -entry_id $entry_id \
                -value $value \
                -time_stamp $time_stamp \
                -description $description \
                -task_item_id "$pm_task_id" \
                -project_item_id "$pm_project_id"

            if {[exists_and_not_null pm_task_id]} {

                logger::entry::pm_after_change \
                    -task_item_id $pm_task_id \
                    -new_percent_complete $percent_complete \
                    -old_percent_complete $old_percent_complete

            }

        } else {
            logger::entry::edit \
                -entry_id $entry_id \
                -value $value \
                -time_stamp $time_stamp \
                -description $description 
        }
        
        category::map_object \
            -remove_old \
            -object_id $entry_id \
            [category::ad_form::get_categories \
                 -container_object_id $the_project_id]
    }

    if {[logger::util::project_manager_linked_p]} {
        set this_task_id [db_string task_entry_p "select task_item_id from pm_task_logger_proj_map where logger_entry = :entry_id" -default "-1"]
    } else {
        set this_task_id -1
    }

    if {![string equal $this_task_id -1] && [exists_and_not_null percent_complete]} {

        pm::task::update_hours \
            -task_item_id $this_task_id \
            -update_tasks_p t

    }

} -after_submit {

    ad_returnredirect -message "Log entry modified." $return_url

    if {![string equal $pm_task_id -1]} {
        pm::project::compute_status $pm_project_id
    }

    ad_script_abort
} -on_refresh {
    
    if {[exists_and_not_null pm_task_id]} {
        db_1row get_task_values { }
    } else {
        set my_task_id ""
    }

    foreach element [list percent_complete status_description] {
        template::element set_value log_entry_form $element [set $element]
    }

    if {[exists_and_not_null pm_task_id]} {
        set display_hours [pm::task::hours_remaining \
                               -estimated_hours_work $estimated_hours_work \
                               -estimated_hours_work_min $estimated_hours_work_min \
                               -estimated_hours_work_max $estimated_hours_work_max \
                               -percent_complete $percent_complete \
                              ]
        
        set total_hours_work [pm::task::estimated_hours_work \
                                  -estimated_hours_work $estimated_hours_work \
                                  -estimated_hours_work_min $estimated_hours_work_min \
                                  -estimated_hours_work_max $estimated_hours_work_max \
                                 ]
    } else {
        set display_hours 0
        set total_hours_work 0
        set percent_complete 0
    }

    template::element set_value log_entry_form remaining_work $display_hours
    template::element set_value log_entry_form total_hours_work $total_hours_work

}


###########
#
# Log history
#
###########

# only show tasks is project-manager is installed
if {[logger::util::project_manager_linked_p]} {
    set show_tasks_p t
} else {
    set show_tasks_p f
}

# Show the log history if the user is looking at /editing his own entry or if
# the user is adding a new entry
if { $entry_exists_p && [string equal $current_user_id $entry_array(creation_user)] } {
    set entry_edited_by_owner_p 1
} else {
    set entry_edited_by_owner_p 0
}

set show_log_history_p [expr $entry_edited_by_owner_p || ! $entry_exists_p]

if { $show_log_history_p } {
    # Show N number of days previous to the last logged entry by the user
    set ansi_format_string "%Y-%m-%d"
    set last_logged_date [db_string last_logged_date {
        select to_char(le.time_stamp, 'YYYY-MM-DD')
        from logger_entries le,
             acs_objects ao 
        where le.entry_id = ao.object_id
          and le.variable_id = :variable_id
          and le.project_id = :project_id
          and ao.creation_user = :current_user_id
          and ao.creation_date = (select max(ao.creation_date)
                              from logger_entries le,
                                   acs_objects ao
                              where le.entry_id = ao.object_id
                                and le.variable_id = :variable_id
                                and le.project_id = :project_id
                                and ao.creation_user = :current_user_id
                             )
    } -default ""]

    if { ![empty_string_p $last_logged_date] } {
        set end_date_ansi $last_logged_date
        set end_date_seconds [clock scan $end_date_ansi]
    } else {
        # Default end date to now
        set end_date_seconds [clock seconds]
        set end_date_ansi [clock format $end_date_seconds -format $ansi_format_string]
    }
    set log_history_n_days 7
    set seconds_per_day [expr 60*60*24]
    set start_date_seconds [expr $end_date_seconds - $log_history_n_days * $seconds_per_day]
    set start_date_ansi [clock format $start_date_seconds \
                            -format $ansi_format_string]
}

set add_entry_url [export_vars -base log { project_id variable_id pm_project_id pm_task_id}]

# because we're using /lib/entries, this is not implemented right
# now. The /lib/entries section should be updated to highlight the
# current entry_id.

if { [info exists entry_id] } {
    set entry_id_or_blank $entry_id 
} else {
    set entry_id_or_blank {}
}


#####
#
# Change variable
#
#####

db_multirow -extend { url selected_p } variables select_variables {} {
    set url [export_vars -base log -override { {variable_id $unique_id} } { project_id pm_project_id pm_task_id }]
    set selected_p [string equal $variable_id $unique_id]
}

