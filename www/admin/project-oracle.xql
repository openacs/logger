<?xml version="1.0"?>

<queryset>
  <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

  <fullquery name="n_can_be_mapped">
    <querytext>
        select count(*)
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
        and not exists (select 1
                          from logger_project_var_map lpvm
                          where lpvm.project_id = :project_id
                            and lpvm.variable_id = lv.variable_id
                          )
        and acs_permission.permission_p(lv.variable_id, :user_id, 'read') = 't'    
    </querytext>
  </fullquery>

  <fullquery name="select_projections">
    <querytext>
        select lpe.projection_id,
               lpe.name,
               lpe.description,
               lpe.value,
               lpo.name as project_name,
               lv.name as variable_name,
               to_char(lpe.start_time, 'YYYY-MM-DD') as start_day,
               to_char(lpe.end_time, 'YYYY-MM-DD') as end_day,
               acs_permission.permission_p(lpo.project_id, :user_id, 'admin') as admin_p
        from logger_projections lpe,
             logger_projects lpo,
             logger_variables lv
        where lpe.project_id = :project_id
          and lpe.project_id = lpo.project_id
          and lpe.variable_id = lv.variable_id    
    </querytext>
  </fullquery>

</queryset>
