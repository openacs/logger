
ad_page_contract {
    When the user clicks the Add Entry link in the navbar
    he/she is taken to this page for selecting a project
    before coming to the log page.

    @author Peter Marklund (peter@collaboraid.biz)
    @creation-date 2003-05-09
    @cvs-id $Id$
} 

ad_maybe_redirect_for_registration

set page_title "Select Project to log entries in"
set context [list $page_title]

ad_form -name project_form -form {
    {project_id:integer(select)
        {label Project}
        {options {[logger::ui::project_options]}}
    }
} -on_submit {
    
    ad_returnredirect "log?[export_vars { project_id }]"
    ad_script_abort
}
