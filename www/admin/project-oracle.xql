<?xml version="1.0"?>

<queryset>
  <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

  <fullquery name="select_projections">
    <querytext>
        select lpe.projection_id,
               lpe.name,
               lpe.description,
               lpe.value,
               lpo.name as project_name,
               lv.name as variable_name,
               to_char(lpe.start_time, 'YYYY-MM-DD') as start_date_ansi,
               to_char(lpe.end_time, 'YYYY-MM-DD') as end_date_ansi,
               acs_permission.permission_p(lpo.project_id, :user_id, 'admin') as admin_p
        from logger_projections lpe,
             logger_projects lpo,
             logger_variables lv
        where lpe.project_id = :project_id
          and lpe.project_id = lpo.project_id
          and lpe.variable_id = lv.variable_id    
        order by lpe.start_time, lpe.end_time, lower(lv.name), lower(lpe.name)
    </querytext>
  </fullquery>

</queryset>
