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

    {project_lead:search
        {result_datatype integer}
        {label {Project Lead}}
        {options [logger::project::users_get_options]}
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
      
    ad_returnredirect "[ad_conn url]?project_id=$project_id"
    ad_script_abort
}

if { $project_exists_p } {
    # We are in edit or display mode

    ###########
    #
    # Variables
    #
    ###########

    db_multirow variables variables_in_project {} 

    set n_can_be_mapped [db_string n_can_be_mapped {}]

    ###########
    #
    # Projections
    #
    ###########

    db_multirow projections select_projections {}   
}
