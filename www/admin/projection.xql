<?xml version="1.0"?>

<queryset>

  <fullquery name="select_project_info">
    <querytext>
        select p.project_id,
               p.name as project_name
        from   logger_projects p,
               logger_projections pn
        where  p.project_id = pn.project_id
        and    pn.projection_id = :projection_id
    </querytext>
  </fullquery>


  <fullquery name="select_projections">
    <querytext>
	  select lpe.name,
        	 lpe.description,
       		 lpe.project_id,
	         lpe.variable_id,
         	 lpe.value,
         	 to_char(lpe.start_time, 'YYYY MM DD') as start_day,
          	 to_char(lpe.end_time, 'YYYY MM DD') as end_day,
	         lpo.name as project
	  from logger_projections lpe,
	         logger_projects lpo
	  where lpe.projection_id = :projection_id
		 and lpe.project_id = lpo.project_id
    </querytext>
  </fullquery>

</queryset>
