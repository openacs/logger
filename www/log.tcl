ad_page_contract {
    Add/edit/display a log entry.
    
    @author Peter marklund (peter@collaboraid.biz)
    @creation-date 2003-04-16
    @cvs-id $Id$
} {
    entry_id:integer,optional
    project_id:integer,optional
    variable_id:integer,optional
} -validate {
    project_id_required_in_add_mode {
        # For the sake of simplicity of the form 
        # we are requiring a project_id to be provided in add mode
        if { ![exists_and_not_null entry_id] && ![exists_and_not_null project_id] } {
            ad_complain "When adding a log entry a project_id must be provided (either entry_id or project_id must be present)."
        }
    }
}

set package_id [ad_conn package_id]
set current_user_id [ad_conn user_id]

if { [exists_and_not_null entry_id] } {
    set entry_exists_p [db_string entry_exists_p {
        select count(*)
        from logger_entries
        where entry_id = :entry_id
    }]                         
} else {
    set entry_exists_p 0
}

if { [string equal [form get_action log_entry_form] "done"] } {
    # User is done editing - redirect back to index page
    ad_returnredirect .
    ad_script_abort
}

# Different page title and form mode when adding a log entry 
# versus displaying/editing one
if { [exists_and_not_null entry_id] } {
    # Initial request in display or edit mode or a submit of the form
    set page_title "Edit Log Entry"
    set ad_form_mode edit
} else {
    # Initial request in add mode
    set page_title "Add Log Entry"
    set ad_form_mode edit
}

set context [list $page_title]

# Build the log entry form elements
set actions [list]
if { $entry_exists_p && [permission::permission_p -object_id $entry_id -privilege write] } {
    lappend actions { Edit formbuilder::edit }
}
lappend actions { Done done }

ad_form -name log_entry_form -cancel_url index -mode $ad_form_mode \
    -actions $actions -form {
    entry_id:key(acs_object_id_seq)
}

# On various occasions we need to know if we are dealing with a submit with the
# form or an initial request (could also be with error message after unaccepted submit)
set submit_p [form is_valid log_entry_form]


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
if { ![exists_and_not_null project_id] } {
    logger::entry::get -entry_id $entry_id -array entry
    set project_id $entry(project_id)
}

# Default the variable we are logging in to the primary variable of the project
if { ![exists_and_not_null variable_id] } {
    set variable_id [logger::project::get_primary_variable -project_id $project_id]
}

# We need project and variable names
logger::project::get -project_id $project_id -array project_array
logger::variable::get -variable_id $variable_id -array variable_array

###########
#
# Build the form
#
###########

ad_form -extend -name log_entry_form -form {
    {project:text(inform)
        {label Project}
        {value $project_array(name)}
    }

    {project_id:integer(hidden)
        {value $project_id}
    }

    {variable_id:integer(hidden)
        {value $variable_id}
    }
}    

# Add form elements common to all modes
# The form builder date datatype doesn't take ANSI format date strings
# but wants dates in list format
set default_date [clock format [clock seconds] -format "%Y %m %d"]
ad_form -extend -name log_entry_form -form {
    {value:float
        {label $variable_array(name)}
        {after_html $variable_array(unit)}
	{html {size 10}}
    }

    {description:text,optional
        {label Description} 
        {html {size 50}}
    }

    {time_stamp:date
        {label Date}
        {value $default_date}
    }
} 

###########
#
# Execute the form
#
###########

ad_form -extend -name log_entry_form -select_query {
    select project_id,
           variable_id,
           value,
           to_char(time_stamp, 'YYYY MM DD') as time_stamp,
           description
    from logger_entries
    where entry_id = :entry_id
} -validate {
    {value 
        { [regexp {^([^.]+|[^.]*\.[0-9]{0,2})$} $value] }
        {The value may not contain more than two decimals}
    }
} -new_data {
    set time_stamp_ansi "[lindex $time_stamp 0]-[lindex $time_stamp 1]-[lindex $time_stamp 2]"
    logger::entry::new -entry_id $entry_id \
                             -project_id $project_id \
                             -variable_id $variable_id \
                             -value $value \
                             -time_stamp $time_stamp_ansi \
                             -description $description

    # Present the user with an add form again for quick logging
    ad_returnredirect "[ad_conn url]?[export_vars {project_id variable_id}]"
    ad_script_abort

} -edit_data {
    set time_stamp_ansi "[lindex $time_stamp 0]-[lindex $time_stamp 1]-[lindex $time_stamp 2]"
    logger::entry::edit -entry_id $entry_id \
                              -value $value \
                              -time_stamp $time_stamp_ansi \
                              -description $description
} -after_submit {

    ad_returnredirect "[ad_conn url]?entry_id=$entry_id"
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

set log_history_n_days 31
set seconds_per_day [expr 60*60*24]
set start_date_seconds [expr [clock seconds] - $log_history_n_days * $seconds_per_day]
set start_date_ansi [clock format $start_date_seconds \
                        -format "%Y-%m-%d"]


set add_entry_url "log?[export_vars { project_id variable_id }]"

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

db_multirow -extend { url selected_p } variables select_variables {
    select lv.variable_id as unique_id,
           lv.name || ' (' || lv.unit || ')' as name
    from logger_variables lv,
         logger_projects lp,
         logger_project_var_map lpvm
    where lp.project_id = lpvm.project_id
      and lv.variable_id = lpvm.variable_id
      and lp.project_id = :project_id
    group by lv.variable_id, lv.name, lv.unit
} {
    set url "log?[export_vars -override { {variable_id $unique_id} } { project_id }]"
    set selected_p [string equal $variable_id $unique_id]
}


