ad_page_contract {
    Add/edit/display a variable for this Logger application instance.
    
    @author Peter marklund (peter@collaboraid.biz)
    @creation-date 2003-04-15
    @cvs-id $Id$
} {
    variable_id:optional
}

set package_id [ad_conn package_id]

if { [string equal [form get_action variable_form] "done"] } {
    # User is done editing - redirect back to index page
    ad_returnredirect .
    ad_script_abort
}

if { [exists_and_not_null variable_id] } {
    # Initial request in display or edit mode or a submit of the form
    set page_title "One variable"
    set ad_form_mode display
} else {
    # Initial request in add mode
    set page_title "Add a variable"
    set ad_form_mode edit
}

set context [list $page_title]

set actions_list [list [list Edit "formbuilder::edit"] [list Done done]]
ad_form -name variable_form -cancel_url index -mode $ad_form_mode -actions $actions_list -form {
    variable_id:key(acs_object_id_seq)

    {name:text
      {html {size 50}}
    }

    {unit:text
      {html {size 50}}
    }

    {type:text(radio)
        {options {{Additive additive} {Non-Additive non-additive}}}
    }

} -select_query {
  select name,
         unit,
         type
  from logger_variables
  where variable_id = :variable_id    

} -validate {
    {
        name
        { ![empty_string_p [string trim $name]] }
        { A name with only spaces is not allowed }
    }

} -new_data {
    logger::variable::new -variable_id $variable_id \
                         -name $name \
                         -unit $unit \
                         -type $type
} -edit_data {
    logger::variable::edit -variable_id $variable_id \
                         -name $name \
                         -unit $unit \
                         -type $type              
} -after_submit {
          
    ad_returnredirect "[ad_conn url]?variable_id=$variable_id"
    ad_script_abort
}
