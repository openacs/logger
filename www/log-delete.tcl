ad_page_contract {
    Delete a log entry
    
    @author Peter marklund (peter@collaboraid.biz)
    @creation-date 2003-04-24
    @cvs-id $Id$
} {
    entry_id:integer
}

permission::require_permission -object_id $entry_id -privilege delete

logger::entry::delete -entry_id $entry_id

ad_returnredirect .
