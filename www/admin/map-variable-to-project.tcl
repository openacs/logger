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
logger::package::variables_multirow $project_id

db_multirow variables variables_to_map {
    select variable_id,
           name,
           unit,
           type
      from logger_variables lv
      where not exists (select 1
                        from logger_project_var_map
                        where project_id = :project_id
                        and variable_id = lv.variable_id
                       )            
}
