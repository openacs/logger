<?xml version="1.0"?>

<queryset>

  <fullquery name="last_logged_variable_id">
    <querytext>
        select variable_id
        from logger_entries le,
             acs_objects ao
        where ao.creation_date = (select max(ao.creation_date)
                               from logger_entries le,
                                    acs_objects ao
                               where ao.object_id = le.entry_id
                               [ad_decode $project_clause "" "" "and $project_clause"]
                              )
          and ao.object_id = le.entry_id
        [ad_decode $project_clause "" "" "and $project_clause"]
    </querytext>
  </fullquery>

  <fullquery name="select_projects">
    <querytext>
	    select lp.project_id as unique_id,
	           lp.name
	    from logger_projects lp,
	         logger_project_pkg_map lppm
	    where lp.project_id = lppm.project_id	
		  and lppm.package_id = :package_id
	    order by lp.name
    </querytext>
  </fullquery>

  <fullquery name="select_variables">
    <querytext>
	    select lv.variable_id as unique_id,
	           lv.name || ' (' || lv.unit || ')' as name
	    from logger_variables lv,
	         logger_projects lp,
	         logger_project_var_map lpvm
	    where lp.project_id = lpvm.project_id
	      and lv.variable_id = lpvm.variable_id
	    [ad_decode $where_clauses "" "" "and [join $where_clauses "\n    and "]"]
	    group by lv.variable_id, lv.name, lv.unit
    </querytext>
  </fullquery>

  <fullquery name="select_users">
    <querytext>
	    select submitter.user_id as unique_id,
	           submitter.first_names || ' ' || submitter.last_name as name
	    from   cc_users submitter,
	           logger_entries le,
	           acs_objects ao
	    where  ao.object_id = le.entry_id
	    and    submitter.user_id = ao.creation_user
	    and    ([ad_decode $where_clauses "" "" "[join $where_clauses "\n    and "]"]
	            or submitter.user_id = :current_user_id
	           )
	    group  by submitter.user_id, submitter.first_names, submitter.last_name
    </querytext>
  </fullquery>

  <fullquery name="select_projections">
    <querytext>
        select lpe.projection_id as unique_id,
               lpe.name,
               to_char(lpe.start_time, 'YYYY-MM-DD') as start_date,
               to_char(lpe.end_time, 'YYYY-MM-DD') as end_date
        from logger_projections lpe
        where lpe.project_id = :selected_project_id
          and lpe.variable_id = :selected_variable_id
    </querytext>
  </fullquery>

</queryset>
