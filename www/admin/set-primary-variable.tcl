ad_page_contract {
    Set primary variable of a logger project.
    
    @author Peter marklund (peter@collaboraid.biz)
    @creation-date 2003-05-01
    @cvs-id $Id$
} {
    project_id:integer
    variable_id:integer
}

logger::project::set_primary_variable -project_id $project_id -variable_id $variable_id

ad_returnredirect "project?project_id=$project_id"
