<?xml version="1.0"?>

<queryset>

  <fullquery name="project_exists_p">
    <querytext>
        select count(*)
        from logger_projects
        where project_id = :project_id
    </querytext>
  </fullquery>

  <fullquery name="variables_in_project">
    <querytext>
        select lv.variable_id,
               lv.name,
               lpvm.primary_p,
               lv.type,
               lv.unit
          from logger_project_var_map lpvm,
               logger_variables lv
          where lpvm.variable_id = lv.variable_id
            and lpvm.project_id = :project_id
    </querytext>
  </fullquery>

</queryset>
