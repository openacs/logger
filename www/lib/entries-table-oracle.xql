<?xml version="1.0"?>

<queryset>
  <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

  <fullquery name="select_entries">
    <querytext>
	    select le.entry_id as id,
	           acs_permission.permission_p(le.entry_id, :current_user_id, 'delete') as delete_p,
	           acs_permission.permission_p(le.entry_id, :current_user_id, 'edit') as edit_p,
	           le.time_stamp,
	           to_char(le.time_stamp, 'fmMMfm-fmDDfm-YYYY') as time_stamp_pretty,
	           le.value,
	           le.description,
	           lp.name as project_name,
	           submitter.user_id,
	           submitter.first_names || ' ' || submitter.last_name as user_name
	    from logger_entries le,
	         logger_projects lp,
	         acs_objects ao,
	         cc_users submitter
	    where le.project_id = lp.project_id
	      and ao.object_id = le.entry_id
	      and ao.creation_user = submitter.user_id
	    [ad_decode $where_clauses "" "" "and [join $where_clauses "\n    and "]"]
	    order by le.time_stamp desc, ao.creation_date desc
    </querytext>
  </fullquery>

</queryset>
