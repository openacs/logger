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

  <fullquery name="logger::ui::variable_options_all.variable_options_all">
    <querytext>
      SELECT 
      lv.name || ' (in ' || lv.unit || ')',
      lv.variable_id
      FROM 
      logger_variables lv
      ORDER BY
      lv.name, lv.unit
    </querytext>
  </fullquery>

  <fullquery name="logger::ui::project_options.project_options">
    <querytext>
        select lp.name, 
               lp.project_id
        from   logger_projects lp,
               logger_project_pkg_map lppm
        where  lp.project_id = lppm.project_id
        and    lppm.package_id = :package_id
        and    lp.active_p = 't'
        order  by name
    </querytext>
  </fullquery>

</queryset>
