<?xml version="1.0"?>

<queryset>
<rdbms><type>oracle</type><version>8.1.6</version></rdbms>

  <fullquery name="select_entries">
    <querytext>
	select le.entry_id as id,
           acs_permission.permission_p(le.entry_id, :user_id, 'delete') as delete_p,
           le.time_stamp,
           lv.name as variable_name,
           le.value,
           lv.unit,
           le.description,
           lp.name as project_name,
           submitter.first_names || ' ' || submitter.last_name as user_name
        from logger_entries le,
           logger_variables lv,
           logger_projects lp,
           acs_objects ao,
           cc_users submitter
        where le.variable_id = lv.variable_id
           and le.project_id = lp.project_id
      	   and ao.object_id = le.entry_id
           and ao.creation_user = submitter.user_id
    [ad_decode $where_clauses "" "" "and [join $where_clauses "\n    and "]"]
        order by le.time_stamp desc, ao.creation_date desc
    </querytext>
  </fullquery>

</queryset>
