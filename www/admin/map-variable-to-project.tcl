ad_page_contract {
    List variables variables for inclusion in a project.
    
    @author Peter marklund (peter@collaboraid.biz)
    @creation-date 2003-04-15
    @cvs-id $Id$
} {
    project_id:integer
}

logger::project::get -project_id $project_id -array project

set page_title "Add a variable to project \"$project(name)\""
set context [list $page_title]

# List all variables not already mapped to the project
logger::package::variables_multirow -not_in_project_id $project_id
