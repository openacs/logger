<?xml version="1.0"?>

<queryset>

  <fullquery name="logger::ui::variable_options.variable_options">
    <querytext>
        select lv.name,
               lv.variable_id
        from   logger_variables lv,
               logger_project_var_map lpvm
        where  lpvm.variable_id = lv.variable_id
        and    lpvm.project_id = :project_id
    </querytext>
  </fullquery>


</queryset>
