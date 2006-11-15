<?xml version="1.0"?>

<queryset>
  <rdbms><type>postgresql</type><version>7.2</version></rdbms>

  <fullquery name="logger::variable::new.insert_variable">
    <querytext>
        select logger_variable__new (
                :variable_id,
                :name,
                :unit,
                :type,
                :creation_user,
                :creation_ip,
                :package_id               
              );
    </querytext>
  </fullquery>

  <fullquery name="logger::variable::delete.delete_variable">
    <querytext>
          select logger_variable__del(:variable_id);
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
      limit 1
    </querytext>
  </fullquery>

  <fullquery name="logger::variable::get_default_variable_id.select_first_variable_id">
    <querytext>
        select variable_id 
        from   logger_variables 
        order  by variable_id 
        limit  1  
    </querytext>
  </fullquery>

</queryset>
