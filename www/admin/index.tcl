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

db_multirow -extend { 
    edit_url display_url permissions_url delete_url unmap_url project_lead_chunk
    make_active_url make_inactive_url
} projects select_projects {} {
    set description [string_truncate -len 50 -- $description]

    set edit_url "project?[export_vars { project_id {formbutton\:formbuilder\:\:edit Edit} {form\:id project_form} {form\:mode display}}]"
    set display_url "project?[export_vars { project_id }]"
    set unmap_url "project-instance-map?[export_vars { project_id {unmap "t"} }]"
    set permissions_url "${permissions_uri}?[export_vars {{object_id $project_id} application_url}]"
    set delete_url "project-delete?[export_vars { project_id }]"
    set make_active_url "project-make-active?[export_vars { project_id }]"
    set make_inactive_url "project-make-inactive?[export_vars { project_id }]"
    set project_lead_chunk [ad_present_user $project_lead_id $project_lead_name]
}

#####
#
# Mappable projects
#
#####

if { $user_id != 0 } {
    db_multirow -extend { map_url } mappable_projects select_mappable_projects {} {
        set map_url "project-instance-map?[export_vars { project_id }]"
    }
} else {
    # Create empty multirow
    multirow create mappable_projects project_id name
}

###########
#
# Variables
#
###########

db_multirow -extend { edit_url delete_url permissions_url } variables select_variables {} {
    set edit_url "variable?[export_vars { variable_id {formbutton\:formbuilder\:\:edit Edit} {form\:id variable_form} {form\:mode display}}]"
    set delete_url "variable-delete?[export_vars { variable_id }]"
    set permissions_url "${permissions_uri}?[export_vars {{object_id $variable_id} application_url}]"
}

set package_permissions_url "${permissions_uri}?[export_vars {{object_id $package_id} application_url}]"

ad_return_template
