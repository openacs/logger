<?xml version="1.0"?>

<queryset>
  <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

  <fullquery name="logger::package::variables_multirow.select_variables">
    <querytext>
      select lv.variable_id,
             lv.name,
             lv.unit,
             lv.type
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
      and acs_permission.permission_p(lv.variable_id, :user_id, 'read') = 't'
         $extra_where_clause
    </querytext>
  </fullquery>
 
</queryset>
