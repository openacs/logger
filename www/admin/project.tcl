ad_page_contract {
    Add/edit/display a project for this Logger application instance.
    
    @author Peter marklund (peter@collaboraid.biz)
    @creation-date 2003-04-08
    @cvs-id $Id$
} {
    project_id:integer,optional
}

set package_id [ad_conn package_id]
set user_id [ad_conn user_id]

switch -- [form get_action project_form] {
    "done" {
        # User is done editing - redirect back to index page
        ad_returnredirect .
        ad_script_abort
    }
    "formbuilder:edit" {
        set edit_mode_p 1
    }
    default {
        set edit_mode_p 0
    }
}

if { [exists_and_not_null project_id] } {
    # Initial request in display or edit mode or a submit of the form
    set page_title "One Project"
    set ad_form_mode display
    set project_exists_p [db_string project_exists_p {}]                         
} else {
    # Initial request in add mode
    set page_title "Add a Project"
    set ad_form_mode edit
    set project_exists_p 0
}

set context [list $page_title]

set actions_list [list [list Edit "formbuilder:edit"] [list Done done]]
ad_form -name project_form \
        -cancel_url index \
        -mode $ad_form_mode \
        -actions $actions_list \
        -form {

    project_id:key(acs_object_id_seq)

    {name:text
        {html {size 50}}
        {label "Name"}
    }

    {description:text(textarea),optional
	{html {cols 60 rows 13}} 
        {label "Description"}
    }

    {project_lead:search,optional
        {result_datatype integer}
        {label {Project Lead}}
        {options {[concat [logger::project::users_get_options]]}}
        {search_query {[db_map dbqd.acs-tcl.tcl.community-core-procs.user_search]}}
    }
}

if { ![ad_form_new_p -key project_id] } {
    ad_form -extend -name project_form -form {
        {active_p:text(radio)
            {label "Active"}
            {options {{Yes t} {No f}}}
        }
    }
}

ad_form -extend -name project_form -select_query {
    select name,
           description,
           project_lead,
           active_p
    from   logger_projects
    where  project_id = :project_id
} -new_request {
    set project_lead [ad_conn user_id]
} -validate {
    {
        name
        { ![empty_string_p [string trim $name]] }
        { A name with only spaces is not allowed }
    }

} -new_data {

    logger::project::new \
        -project_id $project_id \
        -name $name \
        -description $description \
        -project_lead $project_lead

} -edit_data {

    # The edit proc requires all attributes to be provided
    # so use the old values for project_lead and active_p

    logger::project::edit \
        -project_id $project_id \
        -name $name \
        -description $description \
        -project_lead $project_lead \
        -active_p $active_p

} -after_submit {
    if { [ad_form_new_p -key project_id] } {
        set message "Project \"$name\" has been created."
    } else {
        set message "Project \"$name\" has been modified."
    }

    ad_returnredirect -message $message [export_vars -base [ad_conn url] { project_id }]
    ad_script_abort
}


if { $project_exists_p } {
    # We are in edit or display mode

    ###########
    #
    # Variables
    #
    ###########

    db_multirow -extend { display_url set_primary_url unmap_url } variables variables_in_project {} {
        set display_url [export_vars -base variable { variable_id }]
        set set_primary_url [export_vars -base set-primary-variable { variable_id project_id }]
        set unmap_url [export_vars -base unmap-variable-from-project { variable_id project_id }]
    }

    ###########
    #
    # Projections
    #
    ###########

    db_multirow -extend { display_url start_date_pretty end_date_pretty value_pretty delete_url } projections select_projections {} {
        set display_url [export_vars -base projection { projection_id }]
        set start_date_pretty [lc_time_fmt $start_date_ansi "%x"]
        set end_date_pretty [lc_time_fmt $end_date_ansi "%x"]
        set value_pretty [lc_numeric $value]
        set delete_url [export_vars -base projection-delete { projection_id }]
    }
}

set add_variable_url [export_vars -base map-variable-to-project { project_id }]

template::list::create \
    -name variables \
    -actions [list "Add variable" [export_vars -base map-variable-to-project { project_id }] {}] \
    -elements {
        name {
            label "Variable Name"
            link_url_col display_url
        }
        unit {
            label "Unit"
        }
        type {
            label "Additive"
            display_template {
                <if @variables.type@ eq additive>Yes</if><else>No</else>
            }
            html { align center }
        }
        primary_p {
            label "Primary"
            display_template {
                <if @variables.primary_p@ true><b>*</b></if>
                <else><a href="@variables.set_primary_url@">set</a></else>
            }
            html { align center }
        }
        unmap {
            label Unmap
            link_url_col unmap_url
            display_template {<if @variables.primary_p@ false>Unmap</if>}
        }
    }


template::list::create \
    -name "projections" \
    -actions [list "Create new projection" [export_vars -base projection { project_id }] {}] \
    -elements {
        name {
            label "Projection Name"
            link_url_col display_url
        }
        start_date_pretty {
            label "Start"
        }
        end_date_pretty {
            label "End"
        }
        variable_name {
            label "Variable"
        }
        value_pretty {
            label "Value"
            html { align right }
        }
        delete {
            sub_class narrow
            display_template {
                <a href="@projections.delete_url@" title="Delete this projection"
                onclick="return confirm('Are you sure you want to delete the projection @projections.name@?');"><img src="/resources/acs-subsite/Delete16.gif" height="16" width="16" alt="Delete" border="0"></a>
                </if>
            }            
            html { align center }
        }
    }


if { [info exists project_id] } {
    set category_map_url [export_vars -base "[site_node::get_package_url -package_key categories]cadmin/one-object" { { object_id $project_id } }]
}
