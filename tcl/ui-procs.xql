<?xml version="1.0"?>

<queryset>

  <fullquery name="logger::ui::variable_options.variable_options">
    <querytext>
        select lv.variable_id,
               lv.name
        from logger_variables lv
        where exists (select 1
                      from logger_project_var_map lpvm
                      where lpvm.project_id = :project_id
                        and lpvm.variable_id = lv.variable_id
                      )
    </querytext>
  </fullquery>


</queryset>
