ad_page_contract {
    User index page for the Logger application.
    
    @author Peter marklund (peter@collaboraid.biz)
    @creation-date 2003-04-08
    @cvs-id $Id$
} {
    project_id:optional,integer
}

set package_id [ad_conn package_id]
set admin_p [permission::permission_p -object_id $package_id -privilege admin]

set where_clauses [list]
if { [exists_and_not_null project_id] } {
    lappend where_clauses "lp.project_id = :project_id"
}

db_multirow measurements select_measurements "
    select lm.measurement_id as id,
           lm.time_stamp,
           lv.name as variable_name,
           lm.value,
           lv.unit,
           lm.description
    from logger_measurements lm, 
         logger_variables lv,
         logger_projects lp
    where lm.variable_id = lv.variable_id
      and lm.project_id = lp.project_id
      and exists (select 1
                  from logger_project_pkg_map
                  where project_id = lp.project_id
                    and package_id = :package_id)
    [ad_decode $where_clauses "" "" "and [join $where_clauses "\n    and"]"]
    order by lm.time_stamp desc
"

db_multirow -extend url projects select_projects {
    select lp.project_id,
           lp.name
    from logger_projects lp,
         logger_project_pkg_map lppm
    where lp.project_id = lppm.project_id
      and lppm.package_id = :package_id
    order by lp.name
} {
    set url "index?[export_vars project_id]"
}
