<?xml version="1.0"?>

<queryset>
  <rdbms><type>postgresql</type><version>7.1</version></rdbms>

  <fullquery name="select_projects">
    <querytext>
       select lp.project_id,
              lp.name,
              lp.description,
              lp.active_p,
              lp.project_lead as project_lead_id,
              cc_users.first_names || ' ' || cc_users.last_name as project_lead_name,
              acs_permission__permission_p(lp.project_id, :user_id, 'admin') as admin_p
       from logger_project_pkg_map lppm,
            logger_projects lp,
            cc_users
       where lppm.project_id = lp.project_id
         and lppm.package_id = :package_id
         and cc_users.user_id = lp.project_lead
       order by name
    </querytext>
  </fullquery>

</queryset>
