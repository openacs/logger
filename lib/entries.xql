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
      select lp.name as label, e.project_id, e.count from 
             (select project_id, count(*) as count
                from logger_entries
               where variable_id = :variable_id
               group by project_id ) e
             join logger_projects lp on (e.project_id = lp.project_id) 
             join logger_project_pkg_map lppm on (e.project_id = lppm.project_id) 
       where lppm.package_id = :package_id
       order by lp.name
    </querytext>
  </fullquery>

  <fullquery name="select_variables">
    <querytext>
    	    select distinct lv.name || ' (' || lv.unit || ')' as name,
                   lv.variable_id
    	    from   logger_variables lv,
    	           logger_project_var_map lpvm,
                   logger_project_pkg_map lppm
            where  lppm.package_id = :package_id
            and    lpvm.project_id = lppm.project_id
            and    lv.variable_id = lpvm.variable_id
    </querytext>
  </fullquery>

  <fullquery name="select_projections">
    <querytext>
        select p.projection_id, 
               p.name,
               to_char(p.start_time, 'YYYY-MM-DD') as start_date_ansi,
               to_char(p.end_time, 'YYYY-MM-DD') as end_date_ansi
        from   logger_projections p
        where  p.project_id = :project_id
        order  by p.start_time, p.end_time, lower(p.name)
    </querytext>
  </fullquery>

</queryset>
