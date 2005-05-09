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


template::list::create \
    -name projects \
    -no_data "[_ logger.lt_No_projects_in_this_i]" \
    -actions {
        "[_ logger.Create_new_project]" project {}
    } \
    -elements {
        edit {
            link_url_col edit_url
            display_template {
                <img src="/resources/acs-subsite/Edit16.gif" height="16" width="16" alt="[_ logger.Edit]" border="0">
            }
            sub_class narrow
            html { align center }
        }
        name {
            label "[_ logger.Project_Name]"
            link_url_col display_url
        }
        active_p {
            label "[_ logger.Active]"
            display_template {
                <if @projects.active_p@ eq t>Yes (<a href="@projects.make_inactive_url@" title="[_ logger.lt_Make_this_project_ina]">toggle</a>)</if><else>No (<a href="@projects.make_active_url@" title="[_ logger.lt_Make_this_project_act]">toggle</a>)</else> 
            }
            html { align center }
        }
        project_lead {
            label "[_ logger.Project_Lead]"
            display_template {@projects.project_lead_chunk;noquote@}
        }
        permissions {
            label "[_ logger.Permissions]"
            link_url_col permissions_url
            display_template {<if @projects.admin_p@ true>Permissions</if>}
            sub_class narrow
            html { align center }
        }
        unlink {
            label "[_ logger.Unlink]"
            link_url_col unmap_url
            display_template {Unlink}
            sub_class narrow
            html { align center }
        }
        delete {
            sub_class narrow
            display_template {
                <if @projects.admin_p@>
                <a href="@projects.delete_url@" title="[_ logger.Delete_this_project]"
                onclick="return confirm('[_ logger.lt_Are_you_sure_you_want_2]');"><img src="/shared/images/Delete16.gif" height="16" width="16" alt="Delete" border="0"></a>
                </if>
            }            
            html { align center }
        }
    }

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

template::list::create \
    -name "mappable_projects" \
    -elements {
        name {
            label "[_ logger.Project_Name]"
        }
        link {
            label "[_ logger.Link_in]"
            link_url_col map_url
            html { align center }
            display_template "[_ logger.Link_to_instance]"
        }
    }

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

template::list::create \
    -name variables \
    -actions {
        "[_ logger.Create_new_variable]" variable {}
    } \
    -elements {
        edit {
            link_url_col edit_url
            display_template {
                <img src="/resources/acs-subsite/Edit16.gif" height="16" width="16" alt="[_ logger.Edit]" border="0">
            }
            sub_class narrow
            html { align center }
        }
        name {
            label "[_ logger.Variable_Name]"
            link_url_col edit_url
        }
        unit {
            label "[_ logger.Unit]"
        }
        type {
            label "[_ logger.Additive]"
            display_template {
                <if @variables.type@ eq additive>Yes</if><else>No</else>
            }
        }
        permissions {
            label "[_ logger.Permissions]"
            link_url_col permissions_url
            display_template {<if @variables.admin_p@ true>Permissions</if>}
            sub_class narrow
            html { align center }
        }
        delete {
            sub_class narrow
            display_template {
                <if @variables.admin_p@>
                <a href="@variables.delete_url@" title="[_ logger.Delete_this_variable]"
                onclick="return confirm('[_ logger.lt_Are_you_sure_you_want_3]');"><img src="/resources/acs-subsite/Delete16.gif" height="16" width="16" alt="Delete" border="0"></a>
                </if>
            }            
            html { align center }
        }
    }

db_multirow -extend { edit_url delete_url permissions_url } variables select_variables {} {
    set edit_url "variable?[export_vars { variable_id {formbutton\:formbuilder\:\:edit Edit} {form\:id variable_form} {form\:mode display}}]"
    set delete_url "variable-delete?[export_vars { variable_id }]"
    set permissions_url "${permissions_uri}?[export_vars {{object_id $variable_id} application_url}]"
}

set package_permissions_url "${permissions_uri}?[export_vars {{object_id $package_id} application_url}]"
