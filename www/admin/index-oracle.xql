<?xml version="1.0"?>

<queryset>
  <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

  <fullquery name="select_projects">
    <querytext>
       select lp.project_id,
              lp.name,
              lp.description,
              lp.active_p,
              lp.project_lead as project_lead_id,
              cc_users.first_names || ' ' || cc_users.last_name as project_lead_name,
              acs_permission.permission_p(lp.project_id, :user_id, 'admin') as admin_p
       from logger_project_pkg_map lppm,
            logger_projects lp,
            cc_users
       where lppm.project_id = lp.project_id
         and lppm.package_id = :package_id
         and cc_users.user_id = lp.project_lead
       order by name
    </querytext>
  </fullquery>

  <fullquery name="select_variables">
    <querytext>
        select lv.variable_id,
             lv.name,
             lv.unit,
             lv.type,
             acs_permission.permission_p(lv.variable_id, :user_id, 'admin') as admin_p
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
        order  by lv.name
    </querytext>
  </fullquery>

  <fullquery name="select_mappable_projects">
    <querytext>
        select p.project_id,
               p.name
        from   logger_projects p
        where  not exists (select 1
                           from   logger_project_pkg_map ppm
                           where  ppm.project_id = p.project_id
                           and    ppm.package_id = :package_id)
        and    acs_permission.permission_p(p.project_id, :user_id, 'read') = 't'
        order  by p.name
    </querytext>
  </fullquery>
    
</queryset>
