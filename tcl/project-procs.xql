<?xml version="1.0"?>

<queryset>

  <fullquery name="logger::project::get.select_project">
    <querytext>
        select project_id,
               name,
               description,
               active_p,
               project_lead
        from logger_projects
       where project_id = :project_id
    </querytext>
  </fullquery>

  <fullquery name="logger::project::map_variable.insert_mapping">
    <querytext>
        insert into logger_project_var_map (project_id, variable_id, primary_p)
                values (:project_id, :variable_id, :primary_p)
    </querytext>
  </fullquery>

  <fullquery name="logger::project::unmap_variable.delete_mapping">
    <querytext>
        delete from logger_project_var_map
               where project_id = :project_id
                 and variable_id = :variable_id
    </querytext>
  </fullquery>

  <fullquery name="logger::project::set_primary_variable.clear_old">
    <querytext>
      update logger_project_var_map
                set primary_p = 'f'
      where project_id = :project_id
    </querytext>
  </fullquery>

  <fullquery name="logger::project::set_primary_variable.update_new">
    <querytext>
      update logger_project_var_map
                set primary_p = 't'
      where project_id = :project_id
        and variable_id = :variable_id
    </querytext>
  </fullquery>

  <fullquery name="logger::project::map_variable.count_primary_p">
    <querytext>
        select count(*)
        from logger_project_var_map
        where project_id = :project_id
        and primary_p = 't'    
    </querytext>
  </fullquery>

  <fullquery name="logger::project::get_primary_variable.select_primary_variable">
    <querytext>
        select variable_id
        from logger_project_var_map
        where project_id = :project_id
        and primary_p = 't'
    </querytext>
  </fullquery>
    
  <fullquery name="logger::project::get_variables.select_variables">
    <querytext>
      select variable_id
      from logger_project_var_map
      where project_id = :project_id
    </querytext>
  </fullquery>

  <fullquery name="logger::project::edit.update_project">
    <querytext>
        update logger_projects
                set name = :name,
                    description = :description, 
                    project_lead = :project_lead,
                    active_p = :active_p
        where project_id = :project_id
    </querytext>
  </fullquery>

  <fullquery name="logger::project::set_active_p.update_project">
    <querytext>
        update logger_projects
        set    active_p = :active_p
        where  project_id = :project_id
    </querytext>
  </fullquery>

  <fullquery name="logger::project::users_get_options.select_project_leads">
    <querytext>
        select uouter.first_names || ' ' || uouter.last_name, uouter.user_id
        from   cc_users uouter
        where  uouter.user_id in (select distinct u.user_id
                                  from   cc_users u
                                  where  u.user_id in (select p.project_lead
                                                       from   logger_projects p,
                                                              logger_project_pkg_map ppm
                                                       where  ppm.project_id = p.project_id
                                                       and    ppm.package_id = :package_id)
                                  or     u.user_id = :user_id)
        order  by lower(uouter.first_names), lower(uouter.last_name)
    </querytext>
  </fullquery>

</queryset>
