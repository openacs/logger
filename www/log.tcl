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

if { [string equal [form get_action log_entry_form] "done"] } {
    # User is done editing - redirect back to index page
    ad_returnredirect .
    ad_script_abort
}

# Different page title and form mode when adding a log entry 
# versus displaying/editing one
if { [exists_and_not_null entry_id] } {
    # Initial request in display or edit mode or a submit of the form
    set page_title "One Log Entry"
    set ad_form_mode display
} else {
    # Initial request in add mode
    set page_title "Add a Log Entry"
    set ad_form_mode edit
}

set context [list $page_title]

# Build the log entry form elements
ad_form -name log_entry_form -cancel_url index -mode $ad_form_mode \
    -actions { { Edit formbuilder::edit } { Done done } } -form {
    entry_id:key(acs_object_id_seq)
}

# On various occasions we need to know if we are dealing with a submit with the
# form or an initial request (could also be with error message after unaccepted submit)
set submit_p [form is_valid log_entry_form]

# Add project and variable elements to the form
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
# The form builder date datatype doesn't understand standard ANSI format date strings
regsub -all -- {-} [dt_systime] { } default_date
ad_form -extend -name log_entry_form -form {
    {value:float
        {label $variable_array(name)}
        {after_html $variable_array(unit)}
    }

    {time_stamp:date
        {label Date}
        {value $default_date}
    }

    {description:text,optional
        {label Description} 
        {html {size 50}}
    }
} 

# Execute the form
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
} -edit_data {
    set time_stamp_ansi "[lindex $time_stamp 0]-[lindex $time_stamp 1]-[lindex $time_stamp 2]"
    logger::entry::edit -entry_id $entry_id \
                              -value $value \
                              -time_stamp $time_stamp_ansi \
                              -description $description
} -on_submit {

    ns_log Notice "pm debug on_submit" 

} -after_submit {

    ns_log Notice "pm debug after_submit"

    ad_returnredirect "[ad_conn url]?entry_id=$entry_id"
    ad_script_abort
}
