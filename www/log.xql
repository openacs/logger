<?xml version="1.0"?>

<queryset>

  <fullquery name="entry_exists_p">
    <querytext>
        select count(*)
        from logger_entries
        where entry_id = :entry_id
    </querytext>
  </fullquery>

  <fullquery name="select_logger_entries">
    <querytext>
	    select project_id,
	           variable_id,
	           value,
	           to_char(time_stamp, 'YYYY-MM-DD') as time_stamp,
	           description
	    from logger_entries
	    where entry_id = :entry_id
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
	      and lp.project_id = :project_id
	    group by lv.variable_id, lv.name, lv.unit
    </querytext>
  </fullquery>

</queryset>
