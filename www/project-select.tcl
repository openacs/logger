
ad_page_contract {
    When the user clicks the Add Entry link in the navbar
    he/she is taken to this page for selecting a project
    before coming to the log page.

    @author Peter Marklund (peter@collaboraid.biz)
    @creation-date 2003-05-09
    @cvs-id $Id$
} 

auth::require_login

set page_title "Select Project to log entries in"
set context [list $page_title]

set project_options [logger::ui::project_options]

if { [llength $project_options] == 1 } {
    set project_id [lindex [lindex $project_options 0] 1]
    ad_returnredirect [export_vars -base log { project_id }]
    ad_script_abort
}

ad_form -name project_form -edit_buttons { { "Next" ok } } -form {
    {project_id:integer(select)
        {label Project}
        {options {$project_options}}
    }
} -on_submit {
    
    ad_returnredirect "log?[export_vars { project_id }]"
    ad_script_abort
}
