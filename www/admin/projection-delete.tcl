ad_page_contract {
    Delete a logger projection

    @author Peter Marklund
    @creation-date 2003-04-15
    @cvs-id $Id$

} {
    projection_id:integer
}

set user_id [ad_conn user_id]

# Assert that the user has admin on the project of the projection
logger::projection::get -projection_id $projection_id -array projection_array
permission::require_permission -object_id $projection_array(project_id) -party_id $user_id -privilege admin

logger::projection::delete -projection_id $projection_id

ad_returnredirect index
