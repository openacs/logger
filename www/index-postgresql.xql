<?xml version="1.0"?>

<queryset>
  <rdbms><type>postgresql</type><version>7.2</version></rdbms>

  <fullquery name="select_entries">
    <querytext>
	    select le.entry_id,
	           acs_permission__permission_p(le.entry_id, :current_user_id, 'delete') as delete_p,
	           acs_permission__permission_p(le.entry_id, :current_user_id, 'write') as edit_p,
	           le.time_stamp,
	           to_char(le.time_stamp, 'fmDyfm fmMMfm-fmDDfm-YYYY') as time_stamp_pretty,
	           to_char(le.time_stamp, 'IW-YYYY') as time_stamp_week,
	           le.value,
	           le.description,
                   lp.project_id,               
	           lp.name as project_name,
	           submitter.user_id,
	           submitter.first_names || ' ' || submitter.last_name as user_name
	    from   logger_entries le,
	           logger_projects lp,
    	           logger_project_pkg_map lppm,
	           acs_objects ao,
	           cc_users submitter
	    where  le.project_id = lp.project_id
	    and    ao.object_id = le.entry_id 
	    and    ao.creation_user = submitter.user_id
            and    lp.project_id = lppm.project_id	
            and    lppm.package_id = :package_id
            [list::filter_where_clauses -and -name "entries"]
	    [list::orderby_clause -orderby -name "entries"]
    </querytext>
  </fullquery>

</queryset>
