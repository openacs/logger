<?xml version="1.0"?>

<queryset>

  <fullquery name="logger::variable::edit.update_variable">
    <querytext>
      update logger_variables
             set name = :name,
                 unit = :unit,
                 type = :type
        where variable_id = :variable_id
    </querytext>
  </fullquery>

  <fullquery name="logger::variable::get.select_variable">
    <querytext>
        select variable_id,
               name,
               unit,
               type
        from logger_variables
        where variable_id = :variable_id
    </querytext>
  </fullquery>

  <fullquery name="logger::variable::get_default_variable_id.select_first_project_primary_variable">
    <querytext>
            select vm.variable_id
            from   logger_project_var_map vm,
                   logger_project_pkg_map pm,
                   logger_projects p
            where  vm.primary_p = 't'
            and    vm.project_id = pm.project_id
            and    pm.package_id = :package_id
            and    p.project_id = pm.project_id
            and    p.active_p = 't'
            order  by lower(p.name)
    </querytext>
  </fullquery>


</queryset>
