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

template::list::create \
    -name "variables" \
    -pass_properties { project_id } \
    -no_data "No variables not already part of this project" \
    -actions [list "Create new variable" [export_vars -base variable { project_id }] {}] \
    -elements {
        name {
            label "Variable Name"
        }
        unit {
            label "Unit"
        }
        type {
            label "Additive"
            display_template {
                <if @variables.type@ eq additive>Yes</if><else>No</else>
            }
        }
        add {
            sub_class narrow
            label "Add"
            display_template "Add"
            link_url_eval {[export_vars -base map-variable-to-project-2 { project_id variable_id }]}
        }
    }
