ad_page_contract {
    Add/edit/display a projection.
    
    @author Peter marklund (peter@collaboraid.biz)
    @creation-date 2003-04-15
    @cvs-id $Id$
} {
    projection_id:integer,optional
    {project_id:integer ""}
}

set package_id [ad_conn package_id]

if { [string equal [form get_action projection_form] "done"] } {
    # User is done editing - redirect back to index page
    ad_returnredirect "project?[export_vars {project_id}]"
    ad_script_abort
}

# Get the name of the project
if { ![empty_string_p $project_id] } {
    logger::project::get -project_id $project_id -array project_array
    set project_name $project_array(name)
} elseif { ![empty_string_p $projection_id] } {
    db_1row select_project_info {}
    # project_id, project_name
} else {
    set project_name ""
}

if { [exists_and_not_null projection_id] } {
    # Initial request in display or edit mode or a submit of the form
    set page_title "One projection"
    set ad_form_mode display
} else {
    # Initial request in add mode
    set page_title "Add a projection"
    set ad_form_mode edit
}

set context [list $page_title]

# Initialize dates
# Start day is today and end day one month forward
set start_day_seconds [clock seconds]
set start_day [clock format $start_day_seconds -format "%Y %m %d"]
set end_day_seconds [expr $start_day_seconds + 60*60*24*31]
set end_day [clock format $end_day_seconds -format "%Y %m %d"]

set actions_list [list [list Edit "formbuilder::edit"] [list Done done]]
ad_form -name projection_form -cancel_url index -mode $ad_form_mode -actions $actions_list -form {
    projection_id:key(logger_projections_seq)

    {project:text
        {label Project}
        {value $project_name}
        {mode display}
    }

    {variable_id:integer(select)
        {label Variable}
        {options {[logger::ui::variable_options -project_id $project_id]}}
    }

    {value:text
      {label Value}
      {html {size 50}}
    }

    {start_day:date
        {label {Start day}}        
        {value $start_day}
    }

    {end_day:date
        {label {End day}}
        {value $end_day}
    }

    {name:text
      {label Name}
      {html {size 50}}
    }

    {description:text(textarea),optional
        {label Description}
	{html {cols 60 rows 13}} 
    }

    {project_id:integer(hidden)
        {value $project_id}
    }
} -select_query_name select_projections -validate {
    {
        name
        { ![empty_string_p [string trim $name]] }
        { A name with only spaces is not allowed }
    }

} -new_data {
    set start_day_ansi "[lindex $start_day 0]-[lindex $start_day 1]-[lindex $start_day 2]"
    set end_day_ansi "[lindex $end_day 0]-[lindex $end_day 1]-[lindex $end_day 2]"

    logger::projection::new \
        -projection_id $projection_id \
        -project_id $project_id \
        -variable_id $variable_id \
        -start_time $start_day_ansi \
        -end_time $end_day_ansi \
        -value $value \
        -name $name \
        -description $description
} -edit_data {
    set start_day_ansi "[lindex $start_day 0]-[lindex $start_day 1]-[lindex $start_day 2]"
    set end_day_ansi "[lindex $end_day 0]-[lindex $end_day 1]-[lindex $end_day 2]"

    logger::projection::edit \
        -projection_id $projection_id \
        -variable_id $variable_id \
        -start_time $start_day_ansi \
        -end_time $end_day_ansi \
        -value $value \
        -name $name \
        -description $description
} -after_submit {
          
    ad_returnredirect "[ad_conn url]?[export_vars {projection_id project_id}]"
    ad_script_abort
}
