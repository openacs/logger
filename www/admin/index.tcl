ad_page_contract {
    Administration index page for the Logger application.
    
    @author Peter marklund (peter@collaboraid.biz)
    @creation-date 2003-04-08
    @cvs-id $Id$
}

set package_id [ad_conn package_id]
set user_id [ad_conn user_id]
set page_title "Logger Administration"

set home_url [ad_parameter -package_id [ad_acs_kernel_id] HomeURL]

set application_url [ad_conn url]
set permissions_uri "/permissions/one"

###########
#
# Projects
#
###########

db_multirow -extend { permissions_url } projects select_projects {} {
    set description [string_truncate -len 50 $description]
    set permissions_url "${permissions_uri}?[export_vars {{object_id $project_id} application_url}]"
}

###########
#
# Variables
#
###########

db_multirow -extend { permissions_url } variables select_variables {
      select lv.variable_id,
             lv.name,
             lv.unit,
             lv.type,
             acs_permission.permission_p(lv.variable_id, :user_id, 'admin') as admin_p
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
} {
    set permissions_url "${permissions_uri}?[export_vars {{object_id $variable_id} application_url}]"
}

set package_permissions_url "${permissions_uri}?[export_vars {{object_id $package_id} application_url}]"

ad_return_template
