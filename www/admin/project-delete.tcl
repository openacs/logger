ad_page_contract {
    Delete a logger project

    @author Peter Marklund
    @creation-date 2003-04-15
    @cvs-id $Id$

} {
    project_id:integer
}

set user_id [ad_conn user_id]

permission::require_permission -object_id $project_id -party_id $user_id -privilege admin

logger::project::delete -project_id $project_id

ad_returnredirect index
