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

  <fullquery name="logger::project::add_variable.insert_mapping">
    <querytext>
        insert into logger_project_var_map (project_id, variable_id, primary_p)
                values (:project_id, :variable_id, :primary_p)
    </querytext>
  </fullquery>

  <fullquery name="logger::project::add_variable.count_primary_p">
    <querytext>
        select count(*)
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

</queryset>
