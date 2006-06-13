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
                   $task_select
                   lp.project_id,               
                   lp.name as project_name,
                   submitter.person_id as user_id,
                   submitter.first_names || ' ' || submitter.last_name as user_name
            from   logger_entries le
                   $task_left_join
                   logger_projects lp,
                   acs_objects ao,
                   persons submitter
            where  le.project_id = lp.project_id
            and    ao.object_id = le.entry_id 
            and    ao.creation_user = submitter.person_id
            [list::filter_where_clauses -and -name "entries"]
            [list::orderby_clause -orderby -name "entries"]
    </querytext>
  </fullquery>

  <fullquery name="select_entries2">
    <querytext>
    select le.entry_id,
           le.time_stamp,
           to_char(le.time_stamp, 'YYYY-MM-DD HH24:MI:SS') as time_stamp_ansi,
           to_char(le.time_stamp, 'IW-YYYY') as time_stamp_week,
           le.value,
           le.description,
           lp.project_id,
           lp.name as project_name,
           $task_select
	   $category_select
           submitter.person_id as user_id,
           submitter.first_names || ' ' || submitter.last_name as user_name
    from   logger_entries le 
	   $category_left_join
           $task_left_join
           logger_projects lp,
           acs_objects ao,
           persons submitter
    where  le.project_id = lp.project_id
    and    ao.object_id = le.entry_id 
    and    ao.creation_user = submitter.person_id
    [list::filter_where_clauses -and -name "entries"]
    [list::orderby_clause -orderby -name "entries"]
    </querytext>
  </fullquery>

</queryset>
