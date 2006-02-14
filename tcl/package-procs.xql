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

  <fullquery name="logger::package::select_users_not_cached.select_users">
    <querytext>
select submitter.first_names || ' ' || submitter.last_name as label, e.user_id from persons submitter join
       (select distinct creation_user as user_id
          from acs_objects ao join 
               (select entry_id 
                  from logger_entries le join logger_project_pkg_map ppm on (le.project_id = ppm.project_id) 
         where ppm.package_id = :package_id) x on (ao.object_id = x.entry_id)) e on (e.user_id = submitter.person_id)
  order by submitter.first_names, submitter.last_name
    </querytext>
  </fullquery>
</queryset>
