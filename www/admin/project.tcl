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

if { [string equal [form get_action project_form] "done"] } {
    # User is done editing - redirect back to index page
    ad_returnredirect .
    ad_script_abort
}

if { [exists_and_not_null project_id] } {
    # Initial request in display or edit mode or a submit of the form
    set page_title "One Project"
    set ad_form_mode display
    set project_exists_p [db_string project_exists_p {
        select count(*)
        from logger_projects
        where project_id = :project_id
    }]                         
} else {
    # Initial request in add mode
    set page_title "Add a Project"
    set ad_form_mode edit
    set project_exists_p 0
}

set context [list $page_title]

set actions_list [list [list Edit "formbuilder::edit"] [list Done done]]
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

if { $project_exists_p } {
    # We are in edit or display mode
    # Display the variables linked to this project
    set variables_list [list]
    set variables_text ""
    db_foreach variables_in_project {
        select lv.variable_id,
               lv.name,
               lpvm.primary_p
          from logger_project_var_map lpvm,
               logger_variables lv
          where lpvm.variable_id = lv.variable_id
            and lpvm.project_id = :project_id
    } {
        set variable_link "<a href=\"variable?variable_id=$variable_id\">$name</a>"
        if { [string equal $primary_p "f"] } {
            append variable_link " &nbsp; \[ <a href=\"unmap-variable-from-project?[export_vars {project_id variable_id}]\">unmap</a> | <a href=\"set-primary-variable?[export_vars {project_id variable_id}]\">make primary</a> \]"
        } else {
            append variable_link " (primary)"
        }

        lappend variables_list $variable_link
    } 

    if { [llength $variables_list] != 0 } {
        set variables_text "<ul><li><p>[join $variables_list "</p></li><li><p>"]</p></li></ul>"
    } else {
        set variables_text "<span class=\"no_items_text\">no variables</span>"
    }
    set n_can_be_mapped [db_string n_can_be_mapped {
        select count(*)
        from logger_variables lv
        where (exists (select 1
                    from logger_project_var_map lpvm,
                         logger_project_pkg_map lppm
                    where lv.variable_id = lpvm.variable_id
                      and lpvm.project_id = lppm.project_id
                      and lppm.package_id = :package_id
                   )
         or lv.package_id = :package_id
         or lv.package_id is null)
        and not exists (select 1
                          from logger_project_var_map lpvm
                          where lpvm.project_id = :project_id
                            and lpvm.variable_id = lv.variable_id
                          )
        and acs_permission.permission_p(lv.variable_id, :user_id, 'read') = 't'
    }]

    if { $n_can_be_mapped > 0 } {
        append variables_text "<p> \[<a href=\"map-variable-to-project?project_id=$project_id\">add variable</a>\] </p>"
    }


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
