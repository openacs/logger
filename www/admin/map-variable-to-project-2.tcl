ad_page_contract {
    Add a variable to a logger project.
    
    @author Peter marklund (peter@collaboraid.biz)
    @creation-date 2003-04-16
    @cvs-id $Id$
} {
    project_id:integer
    variable_id:integer
}

logger::project::map_variable -project_id $project_id -variable_id $variable_id

logger::variable::get -variable_id $variable_id -array variable
logger::project::get -project_id $project_id -array project

ad_returnredirect -message "Variable \"$variable(name)\" has been added to \"$project(name)\"." [export_vars -base "project" { project_id }]
