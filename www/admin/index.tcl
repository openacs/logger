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
    -no_data "No projects in this instance of logger." \
    -actions {
        "Create new project" project {}
    } \
    -elements {
        edit {
            link_url_col edit_url
            display_template {
                <img src="/resources/acs-subsite/Edit16.gif" height="16" width="16" alt="Edit" border="0">
            }
            sub_class narrow
            html { align center }
        }
        name {
            label "Project Name"
            link_url_col display_url
        }
        active_p {
            label "Active"
            display_template {
                <if @projects.active_p@ eq t>Yes (<a href="@projects.make_inactive_url@" title="Make this project inactive">toggle</a>)</if><else>No (<a href="@projects.make_active_url@" title="Make this project active">toggle</a>)</else> 
            }
            html { align center }
        }
        project_lead {
            label "Project Lead"
            display_template {@projects.project_lead_chunk;noquote@}
        }
        permissions {
            label "Permissions"
            link_url_col permissions_url
            display_template {<if @projects.admin_p@ true>Permissions</if>}
            sub_class narrow
            html { align center }
        }
        unlink {
            label "Unlink"
            link_url_col unmap_url
            display_template {Unlink}
            sub_class narrow
            html { align center }
        }
        delete {
            sub_class narrow
            display_template {
                <if @projects.admin_p@>
                <a href="@projects.delete_url@" title="Delete this project"
                onclick="return confirm('Are you sure you want to delete project @projects.name@?');"><img src="/shared/images/Delete16.gif" height="16" width="16" alt="Delete" border="0"></a>
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
            label "Project Name"
        }
        link {
            label "Link in"
            link_url_col map_url
            html { align center }
            display_template "Link to instance"
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
        "Create new variable" variable {}
    } \
    -elements {
        edit {
            link_url_col edit_url
            display_template {
                <img src="/resources/acs-subsite/Edit16.gif" height="16" width="16" alt="Edit" border="0">
            }
            sub_class narrow
            html { align center }
        }
        name {
            label "Variable Name"
            link_url_col edit_url
        }
        unit {
            label "Unit"
        }
        type {
            label "Additive"
            display_template {
                <if @variables.type@ eq additive>Yes</if><else>No</else>
            }
        }
        permissions {
            label "Permissions"
            link_url_col permissions_url
            display_template {<if @variables.admin_p@ true>Permissions</if>}
            sub_class narrow
            html { align center }
        }
        delete {
            sub_class narrow
            display_template {
                <if @variables.admin_p@>
                <a href="@variables.delete_url@" title="Delete this variable"
                onclick="return confirm('Are you sure you want to delete variable @variables.name@?');"><img src="/resources/acs-subsite/Delete16.gif" height="16" width="16" alt="Delete" border="0"></a>
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
