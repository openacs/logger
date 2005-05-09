ad_page_contract {
    Delete a log entry
    
    @author Peter marklund (peter@collaboraid.biz)
    @creation-date 2003-04-24
    @cvs-id $Id$
} {
    entry_id:integer,multiple
    {confirm_p:boolean 0}
    {return_url "."}
}

if { !$confirm_p } {
    set num_entries [llength $entry_id]

    if { $num_entries == 0 } {
        ad_returnredirect $return_url
        return
    }

    set page_title "Delete Log [ad_decode $num_entries 1 "Entry" "Entries"]"
    set context [list $page_title]
    set yes_url "log-delete?[export_vars { entry_id:multiple { confirm_p 1 } return_url}]"
    set no_url "."

    return
}

foreach entry_id $entry_id {
    permission::require_permission -object_id $entry_id -privilege write
    logger::entry::delete -entry_id $entry_id
}
    
ad_returnredirect -message "[_ logger.Entry_deleted]" $return_url

# should update project-manager if appropriate

ad_script_abort
