ad_page_contract {
    Add/edit/display a log entry.
    
    @author Peter Marklund (peter@collaboraid.biz)
    @creation-date 2003-04-16
    @cvs-id $Id$
} {
    entry_id:integer,optional
    project_id:integer,optional
    variable_id:integer,optional
    {edit:boolean "f"}
    {return_url "."}
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
if { [exists_and_not_null entry_id] } {
    # Initial request in display or edit mode or a submit of the form
    set page_title "Edit Log Entry"
    if { [string equal $edit "t"] && $edit_p } {
        set ad_form_mode edit
    } else {
        set ad_form_mode display
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
        {label Project}
        {value $project_array(name)}
    }
}

if { $entry_exists_p } {
    set category_trees [category_tree::get_mapped_trees $entry_array(project_id)]
} else {
    set category_trees [category_tree::get_mapped_trees $project_id]
}
foreach elm $category_trees {
    foreach { tree_id name dummy } $elm {}
    ad_form -extend -name log_entry_form -form \
        [list [list category_id_${tree_id}:integer(category) \
                   {label $name} \
                   {html {single single}} \
                   {category_tree_id $tree_id} \
                   {category_object_id {[value_if_exists entry_id]}}]]
}   

# Add form elements common to all modes
# The form builder date datatype doesn't take ANSI format date strings
# but wants dates in list format
ad_form -extend -name log_entry_form -form {
    {value:float
        {label $variable_array(name)}
        {after_html $variable_array(unit)}
	{html {size 9 maxlength 9}}
    }
    {description:text,optional
        {label Description} 
        {html {size 50}}
    }
    {time_stamp:date(date),to_sql(ansi),from_sql(ansi)
        {label Date}
    }
} 

###########
#
# Execute the form
#
###########

ad_form -extend -name log_entry_form -select_query_name select_logger_entries -validate {
    {value 
        { [regexp {^([0-9]{1,6}|[0-9]{0,6}\.[0-9]{0,2})$} $value] }
        {The value may not contain more than two decimals and must be between 0 and 999999.99}
    }
} -new_request {
    # Get the date of the last entry
    set time_stamp [ad_get_client_property logger time_stamp]
    if { [empty_string_p $time_stamp] } {
        set time_stamp [clock format [clock seconds] -format "%Y-%m-%d"]
    }
    set time_stamp [template::util::date::acquire ansi $time_stamp]
} -on_submit {
    # Collect categories from all the category widgets
    set category_ids [list]
    foreach elm $category_trees {
        foreach { tree_id name dummy } $elm {}
        set category_ids [concat $category_ids [set category_id_${tree_id}]]
    }
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
            logger::entry::new \
                -entry_id $entry_id \
                -project_id $project_id \
                -variable_id $variable_id \
                -value $value \
                -time_stamp $time_stamp \
                -description $description
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
            $category_ids
    }
    
    # Remember this date, as the next entry is likely to be for the same date
    ad_set_client_property logger time_stamp $time_stamp

    # Present the user with an add form again for quick logging
    ad_returnredirect [export_vars -base [ad_conn url] { project_id variable_id }]
    ad_script_abort

} -edit_data {
    db_transaction {
        logger::entry::edit \
            -entry_id $entry_id \
            -value $value \
            -time_stamp $time_stamp \
            -description $description
        
        category::map_object \
            -remove_old \
            -object_id $entry_id \
            $category_ids
    }

} -after_submit {

    ad_returnredirect $return_url
    ad_script_abort
}

###########
#
# Log history
#
###########

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
    set log_history_n_days 31
    set seconds_per_day [expr 60*60*24]
    set start_date_seconds [expr $end_date_seconds - $log_history_n_days * $seconds_per_day]
    set start_date_ansi [clock format $start_date_seconds \
                            -format $ansi_format_string]
}

set add_entry_url [export_vars -base log { project_id variable_id }]

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
    set url [export_vars -base log -override { {variable_id $unique_id} } { project_id }]
    set selected_p [string equal $variable_id $unique_id]
}
