ad_page_contract {
    List variables variables for inclusion in a project.
    
    @author Peter marklund (peter@collaboraid.biz)
    @creation-date 2003-04-15
    @cvs-id $Id$
} {
    project_id:integer
}

logger::project::get -project_id $project_id -array project

set page_title "[_ logger.lt_Add_a_variable_to_pro]"
set context [list [list [export_vars -base project { project_id }] $project(name)] $page_title]

# List all variables not already mapped to the project
logger::package::variables_multirow -not_in_project_id $project_id

template::list::create \
    -name "[_ logger.variables]" \
    -pass_properties { project_id } \
    -no_data "[_ logger.lt_No_variables_not_alre]" \
    -actions [list "[_ logger.Create_new_variable]" [export_vars -base variable { project_id }] {}] \
    -elements {
        name {
            label "[_ logger.Variable_Name]"
        }
        unit {
            label "[_ logger.Unit]"
        }
        type {
            label "[_ logger.Additive]"
            display_template {
                <if @variables.type@ eq additive>Yes</if><else>No</else>
            }
        }
        add {
            sub_class narrow
            label "[_ logger.Add]"
            display_template "[_ logger.lt_Add_variablesname_to_]"
            link_url_eval {[export_vars -base map-variable-to-project-2 { project_id variable_id }]}
        }
    }
