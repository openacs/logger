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

</queryset>
