ad_page_contract {
    Add/edit/display a project for this Logger application instance.
    
    @author Peter marklund (peter@collaboraid.biz)
    @creation-date 2003-04-08
    @cvs-id $Id$
} {
    project_id:integer,optional
}

set package_id [ad_conn package_id]

if { ![empty_string_p [ns_set iget [rp_getform] formbutton:done_button]] } {        
    # User is done editing - redirect back to index page
    ad_returnredirect index
    ad_script_abort
}

if { [exists_and_not_null project_id] } {
    # Initial request in display or edit mode or a submit of the form
    set page_title "One Project"
    set ad_form_mode display
} else {
    # Initial request in add mode
    set page_title "Add a Project"
    set ad_form_mode edit
}

set context [list $page_title]

set actions_list [list [list Edit "formbuilder::edit"] [list Done done_button]]
ad_form -name project_form \
        -cancel_url index \
        -mode $ad_form_mode \
        -actions $actions_list \
        -form {

    project_id:key(acs_object_id_seq)

    {name:text
      {html {size 50}}
    }

    {description:text(textarea),optional
	{html {cols 60 rows 13}} 
    }
}

if { [exists_and_not_null project_id] } {
    # We are in edit or display mode
    # Display the variables linked to this project
    set variables_list [list]
    set variables_text ""
    db_foreach variables_in_project {
        select lv.variable_id,
               lv.name
          from logger_project_var_map lpvm,
               logger_variables lv
          where lpvm.variable_id = lv.variable_id
            and lpvm.project_id = :project_id
    } {
        lappend variables_list "<a href=\"variable?variable_id=$variable_id\">$name</a>"
    } 

    if { [llength $variables_list] != 0 } {
        set variables_text [join $variables_list ", "]
    } else {
        set variables_text "<span class=\"no_items_text\">no variables</span>"
    }
    append variables_text "&nbsp; \[<a href=\"map-variable-to-project?project_id=$project_id\">add variable</a>\]"


     ad_form -extend -name project_form -form {
         {variables:text(inform)
 	      {label Variables}
             {value $variables_text}
         }
    }
   
} else {
    # We are in add mode
}

# Finalize the form with the execution blocks
ad_form -extend -name project_form -select_query {
            select name,
               description
        from logger_projects
       where project_id = :project_id
} -validate {
    {
        name
        { ![empty_string_p [string trim $name]] }
        { A name with only spaces is not allowed }
    }

} -new_data {

    logger::project::new -project_id $project_id \
                         -name $name \
                         -description $description \
} -edit_data {

    # The edit proc requires all attributes to be provided
    # so use the old values for project_lead and active_p
    logger::project::get -project_id $project_id -array old_project
    logger::project::edit -project_id $project_id \
                          -name $name \
                          -description $description \
                          -project_lead $old_project(project_lead) \
                          -active_p $old_project(active_p)
} -after_submit {
      
    ad_returnredirect "[ad_conn url]?project_id=$project_id"

    ad_script_abort
}
