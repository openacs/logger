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
        select submitter.first_names || ' ' || submitter.last_name as label,
               submitter.person_id as user_id
        from   acs_objects ao,
               logger_entries le,
               persons submitter
        where  ao.object_id = le.entry_id
        and    submitter.person_id = ao.creation_user
        and    exists (select 1
                      from   logger_project_pkg_map
                      where  project_id = le.project_id
                      and    package_id = :package_id)
        group  by submitter.person_id, submitter.first_names,
                  submitter.last_name
        order by submitter.first_names, submitter.last_name
    </querytext>
  </fullquery>
</queryset>
