<?xml version="1.0"?>

<queryset>

  <fullquery name="logger::package::projects_only_in_package.select_projects">
    <querytext>
      select project_id
      from logger_projects
      where exists (select 1
                    from logger_project_pkg_map
                    where package_id = :package_id
                    and project_id = logger_projects.project_id)
      and not exists (select 1 
                      from logger_project_pkg_map
                      where package_id <> :package_id
                      and project_id = logger_projects.project_id)
    </querytext>
  </fullquery>

  <fullquery name="logger::package::all_projects_in_package.select_projects">
    <querytext>
      select project_id
      from logger_project_pkg_map
      where package_id = :package_id      
    </querytext>
  </fullquery>

  <fullquery name="logger::package::variables_multirow.select_variables">
    <querytext>
      select lv.variable_id,
             lv.name,
             lv.unit,
             lv.type
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
         $extra_where_clause
    </querytext>
  </fullquery>

</queryset>
