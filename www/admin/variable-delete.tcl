ad_page_contract {
    Delete a logger variable

    @author Peter Marklund
    @creation-date 2003-04-15
    @cvs-id $Id$

} {
    variable_id:integer
}

set user_id [ad_conn user_id]

permission::require_permission -object_id $variable_id -party_id $user_id -privilege admin

# Check that there are no log entries for this variable
set n_log_entries [db_string n_log_entries {}]

if { $n_log_entries > 0 } {
    ad_return_complaint 1 "Variable is in use: you cannot delete this variable as it is being used by log entries"
    ad_script_abort
}

logger::variable::delete -variable_id $variable_id

ad_returnredirect index
