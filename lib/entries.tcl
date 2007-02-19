# Expected variables:
# -------------------
# filters_p   Boolean that indicates if you wan to show the filters or not, default true.
#
# Optional variables:
# -------------------
#
# show_orderby_p        The calling include may not want to show links to sort
# start_date            in ansi format
# end_date              in ansi format
# format                Format of the list, default normal
# url                   of logger (if called by another package) /url/to/logger/
# add_link              If you want to override the add link (for example, to go
#                       directly to the correct project)
# project_manager_url   If passed in, the /url/to/project-manager/  that is used to 
#                       display the link to the task and project page.
# entry_id              (not sure if this works), should highlight entries.
# return_url            used for delete links
# show_tasks_p          Used to specified if you want to show the task name in the list
# groupby               To group the results of the list in the provided value.
# pm_project_id 
# variable_id
#
# Filters:
# -------
# project_status        Used for adding in a status for projects, active or not
# pm_task_id            Used for showing logs for specific task_id
# description_f         Used to filter according description
# user_id               Used to show entries of an specific user_id
# project_id            Used to filter entries for this project_id
# project_ids           Used to filter entries for this list of project_ids
# time_stamp            To filter according the date time entry uses start_date and end_date variables

set required_param_list [list]
set optional_param_list [list filters_p show_orderby_p start_date end_date url add_link project_manager_url \
			     entry_id return_url pm_project_id show_tasks_p variable_id]
set optional_unset_list [list description_f project_status pm_task_id groupby user_id time_stamp \
			     start_date end_date project_id project_ids]

foreach required_param $required_param_list {
    if {![info exists $required_param]} {
        return -code error "$required_param is a required parameter."
    }
}

foreach optional_param $optional_param_list {
    if {![info exists $optional_param]} {
        set $optional_param {}
    }
}

foreach optional_unset $optional_unset_list {
    if {[info exists $optional_unset]} {
        if {[empty_string_p [set $optional_unset]] || [set $optional_unset] == 0} {
            unset $optional_unset
        }
    }
}

if { ![exists_and_not_null filters_p] } {
    set filters_p 1
}

set dotlrn_installed_p [apm_package_installed_p dotlrn]

if { ![exists_and_not_null format] } {
    set format "normal"
}

if { ![exists_and_not_null show_tasks_p]} {
    set show_tasks_p 0
}

if { ![info exists project_manager_url]} {
    set project_manager_url ""
}

# Debugging:
# ns_log notice "project: $project_id variable_id: $variable_id filters_p: $filters_p pm_project_id: $pm_project_id pm_task_id: $pm_task_id start_date:$start_date end_date: $end_date show_orderby: $show_orderby_p entry_id: $entry_id show_tasks_p: $show_tasks_p"


# Usage:
# ------
# This can be used as an include for the main index page of logger,
# and it can be also used in includes from other apps, like
# project-manager. The most important distinction is whether or not
# filter options are going to be shown. If they are, then a lot more
# computation has to be done. 

# Because this can be called from other packages as well, the URLs we
# compute have to be fully qualified.

if {[info exists url]} {
    set base_url $url
} else {
    set base_url [ad_conn package_url]
}

# Testing:
# --------
# use cases to test for:
# using logger with and without project-manager
# when using project-manager, both integrated and not integrated with PM
# using logger with categories and without

set package_id [ad_conn package_id]

set current_user_id [ad_conn user_id]
set admin_p [permission::permission_p -object_id $package_id -privilege admin]

if { [empty_string_p $variable_id] } {
    ad_return_template "no-projects"
    return
}

# Get variable info
logger::variable::get -variable_id $variable_id -array variable

# These are used to construct the values for the date filter
set weekdayno [clock format [clock seconds] -format %w]
set monthdayno [string trimleft [clock format [clock seconds] -format %d] 0]

# -----------------------
# PREPARATION FOR FILTERS
# -----------------------

# 1. get category-trees mapped to projects in this logger

# the logger::package::all_projects_in_package proc may be able to be
# optimized in some way? If you have thousands of projects, it tends
# to be a bit slow. Perhaps limit the results to only open projects?

if {![exists_and_not_null project_ids]} {
    if {[exists_and_not_null project_id] && [string is false $filters_p]} {
	set project_ids [list $project_id]
    }  else {
	set project_ids [logger::package::all_projects_in_package -package_id [ad_conn package_id]]
    }
} else {
    
    # We cant search for projects and one single project at the same time
    if {[exists_and_not_null project_id]} {
	unset project_id
    }
}

array set tree_id_array [list]

set elm_forest [category_tree::get_mapped_trees_from_object_list $project_ids]

foreach elm $elm_forest {
    set tree_id_array([lindex $elm 0]) .
}

set tree_ids [array names tree_id_array]

if {$tree_ids eq ""} {
    set category_select ""
    set category_left_join ""
} else {
    set category_select "c.category_id,c.tree_id,"
    set category_left_join "LEFT OUTER JOIN category_object_map_tree c ON (c.object_id = le.entry_id)"
}


# Projections
set projection_values [list]
if { [exists_and_not_null project_id] } {
    db_foreach select_projections {} -column_array row {
        lappend projection_values \
            [list $row(name) [list [list projection_id $row(projection_id)] \
                                  [list time_stamp:multiple [list $row(start_date_ansi) $row(end_date_ansi)]]]]
    }
}

# Projects

# we don't need to show all the project options if this is being
# displayed in an include, and we're not showing the filters. 
if {[string is true $filters_p]} {
    set project_where ""

    if {[exists_and_not_null project_status]} {
        append project_where " and lp.active_p = :project_status "
    }

    set project_status_values [list [list "[_ logger.Open]" "t"] [list "[_ logger.Closed]" "f"]]
} else {
    set project_where "and lp.project_id in ([join $project_ids ","])"

    set project_status_values [list]
}

set project_values [db_list_of_lists select_projects {}]

if { ([exists_and_not_null start_date] || [exists_and_not_null end_date]) && ![exists_and_not_null time_stamp] } {
    # HACK: The filter is called 'time_stamp', but the variables passed are called start_date/end_date.
    set time_stamp "foo"
}

#----------------------------------------------------------------------
# Define list elements
#----------------------------------------------------------------------

set elements {
    edit {
        label {}
        display_template {
           <if @entries.edit_p@ true>
            <a href="@entries.edit_url@" title="[_ logger.Edit_this_log_entry]"
            ><img src="/shared/images/Edit16.gif" height="16" width="16" 
            alt="[_ acs-kernel.common_Edit]" border="0"></a>
            </if>        
        }
    }
    project_id {
        display_col project_name
        label "[_ logger.Project]"
        hide_p {[ad_decode [exists_and_not_null project_ids] 1 1 0]}
    }
    user_id {
        label "[_ logger.User]"
        display_col user_name
        link_url_eval {[acs_community_member_url -user_id $user_id]}
        csv_col user_name
        hide_p {[ad_decode [exists_and_not_null user_id] 1 1 0]}
    }
    time_stamp {
        label "[_ logger.Date]"
        display_col time_stamp_pretty
        aggregate_label {[ad_decode $variable(type) "additive" "[_ logger.Total]" "[_ logger.Average]"]}
        aggregate_group_label {[ad_decode $variable(type) "additive" "[_ logger.Group_total]" "[_ logger.Group_Average]"]}
    }
    value {
        label $variable(name)
        link_url_eval {[export_vars -base "${my_base_url}log" { entry_id }]}
        link_html { title "[_ logger.View_this_entry]" }
        aggregate {[ad_decode $variable(type) "additive" sum average]}
        html { align right }
        display_eval {[lc_numeric $value]}
    }
    description {
        label "[_ logger.Description]"
        display_eval {[string_truncate -len 50 -- $description]}
        link_url_eval {[export_vars -base "${my_base_url}log" { entry_id }]}
        link_html { title "[_ logger.View_this_entry]" }
    }
    description_long {
        label "[_ logger.Description]"
        display_eval {[string_truncate -len 400 -- $description]}
        hide_p 1
        link_url_eval {[export_vars -base "${my_base_url}log" { entry_id }]}
        link_html { title "[_ logger.View_this_entry]" }
    }
}

#----------------------------------------------------------------------
# Define list filters
#----------------------------------------------------------------------


# For the description filter we get the value of the parameter
if {$dotlrn_installed_p} {
    set community_id [dotlrn_community::get_community_id]
}

if { [exists_and_not_null community_id] } {
    set logger_package_id [dotlrn_community::get_package_id_from_package_key \
			       -package_key "logger" \
			       -community_id $community_id]
} else {
    set logger_package_id [ad_conn package_id]
}

set desc_options [list]
set default_descriptions [split [parameter::get -parameter "DefaultDescriptionList" -package_id $logger_package_id] ";"]
foreach desc $default_descriptions {
    lappend desc_options [list $desc $desc]
}

set filters {
    project_ids {
        label "[_ logger.Projects]"
        values $project_values
        where_clause {
            le.project_id in ([join $project_ids ","])
        }
        add_url_eval {[export_vars -base "${base_url}log" { { project_id $__filter_value } pm_task_id variable_id }]}
        has_default_p {[ad_decode [llength $project_values] 1 1 0]}
    }
    project_status {
        label "[_ logger.Project_status]"
        values $project_status_values
        where_clause {
            lp.active_p = :project_status
        }
    }
    variable_id {
        label "[_ logger.Variables]"
        values {[db_list_of_lists select_variables {}]}
        where_clause {
            le.variable_id = :variable_id
        }
        add_url_eval {[ad_decode [exists_and_not_null project_id] 1 [export_vars -base "${base_url}log" { project_id pm_task_id { variable_id $__filter_value } }] ""]}
        has_default_p t
    }
    projection_id {
        label "[_ logger.Projections]"
        type multivar
        values $projection_values
        has_default_p 1
    }
    user_id {
        label "[_ logger.Users]"
        values {[db_list_of_lists select_users {}]}
        where_clause {
            submitter.person_id = :user_id
        }
    }
    time_stamp {
        label "[_ logger.Date]"
        where_clause {
            le.time_stamp >= to_date(:start_date,'YYYY-MM-DD') and le.time_stamp <= to_date(:end_date,'YYYY-MM-DD')
        }
        other_label "[_ logger.Custom]"
        type multival
        has_default_p 1
        values {
            {
                "[_ logger.Today]" {
                    [clock format [clock seconds] -format "%Y-%m-%d"]
                    [clock format [clock seconds] -format "%Y-%m-%d"]
                }
            }
            {
                "[_ logger.Yesterday]" {
                    [clock format [clock scan "-1 days"] -format "%Y-%m-%d"]
                    [clock format [clock scan "-1 days"] -format "%Y-%m-%d"]
                }
            }
            {
                "[_ logger.This_week]" {
                    [clock format [clock scan "-$weekdayno days"] -format "%Y-%m-%d"]
                    [clock format [clock scan "[expr 6-$weekdayno] days"] -format "%Y-%m-%d"]
                }
            }
            {
                "[_ logger.Last_week]" {
                    [clock format [clock scan "[expr -7-$weekdayno] days"] -format "%Y-%m-%d"]
                    [clock format [clock scan "[expr -1-$weekdayno] days"] -format "%Y-%m-%d"]
                }
            }
            {
                "[_ logger.Past_7_days]" {
                    [clock format [clock scan "-1 week 1 day"] -format "%Y-%m-%d"]
                    [clock format [clock seconds] -format "%Y-%m-%d"]
                }
            }
            {
                "[_ logger.This_month]" {
                    [clock format [clock scan "[expr 1-$monthdayno] days"] -format "%Y-%m-%d"]
                    [clock format [clock scan "1 month -1 day" -base [clock scan "[expr 1-$monthdayno] days"]] -format  "%Y-%m-%d"]
                }
            }
            {
                "[_ logger.Last_month]" {
                    [clock format [clock scan "-1 month [expr 1-$monthdayno] days"] -format "%Y-%m-%d"]
                    [clock format [clock scan "1 month -1 day" -base [clock scan "-1 month [expr 1-$monthdayno] days"]] -format  "%Y-%m-%d"]
                }
            }
            {
                "[_ logger.Past_30_days]" {
                    [clock format [clock scan "-1 month 1 day"] -format "%Y-%m-%d"]
                    [clock format [clock seconds] -format "%Y-%m-%d"]
                }
            }
            {
                "[_ logger.Always]" {
                    [clock format 0 -format "%Y-%m-%d"]
                    [clock format [clock scan "+10 year"] -format "%Y-%m-%d"]
                }
            }
        }
    }
    pm_task_id {
        label "[_ logger.Tasks]"
        where_clause {
            task.item_id = :pm_task_id
        }
    }
    description_f {
        label "[_ logger.Description]"
	values $desc_options
	where_clause {
	    le.description = :description_f
	}
    }
}

set orderbys {
    time_stamp {
        label "[_ logger.Date]"
        orderby_desc "le.time_stamp desc, ao.creation_date desc"
        orderby_asc "le.time_stamp asc, ao.creation_date asc"
        default_direction desc
    }
    project_id {
        label "[_ logger.Project]" 
        orderby_asc "project_name asc, le.time_stamp desc, ao.creation_date desc"
        orderby_desc "project_name desc, le.time_stamp desc, ao.creation_date desc"
    }
    user_id {
        label "[_ logger.User]"
        orderby_asc "user_name asc, le.time_stamp desc, ao.creation_date desc"
        orderby_desc "user_name desc, le.time_stamp desc, ao.creation_date desc"
    }
    value {
        label $variable(name)
        orderby_asc "value asc, le.time_stamp desc, ao.creation_date desc"
        orderby_desc "value desc, le.time_stamp desc, ao.creation_date desc"
    }
    description {
        label "[_ logger.Description]"
        orderby_asc "description asc, le.time_stamp desc, ao.creation_date desc"
        orderby_desc "description desc, le.time_stamp desc, ao.creation_date desc"
    }
    default_value time_stamp,desc
}

# the calling include may not want to show links to sort
if {[exists_and_not_null show_orderby_p] && [string is false $show_orderby_p]} {
    set orderbys {
	time_stamp {
	    label "[_ logger.Date]"
	    orderby_desc "le.time_stamp desc, ao.creation_date desc"
	    orderby_asc "le.time_stamp asc, ao.creation_date asc"
	    default_direction desc
	}
	default_value time_stamp,desc
    }
}


set groupby_values {
    { "\#logger.Day\#" { { groupby time_stamp } { orderby time_stamp,desc } } }
    { "\#logger.Week\#" { { groupby time_stamp_week } { orderby time_stamp,desc } }  }
    { "\#logger.Project\#" { { groupby project_name } { orderby project_id,asc } } }
    { "\#logger.User\#" { { groupby user_id } { orderby user_id,asc } } }
    { "\#logger.Description\#" { { groupby description } { orderby user_id,asc } } }
}

set normal_row {
    checkbox {}
    edit {}
    project_id {}
    user_id {}
    time_stamp {}
}

foreach id $tree_ids {
    # Elements
    set id_var c_${id}_category_id
    set cmd "join \[category::get_names \$$id_var\] \", \""
    lappend elements c_${id}_category_id \
        [list label \[[list category_tree::get_name $id]\] \
             display_eval \[$cmd\]]

    # Format
    lappend normal_row c_${id}_category_id {}

    # Filters
    set values_${id} [list]
    foreach elm [category_tree::get_tree $id] {
        util_unlist $elm category_id category_name deprecated_p level
        lappend values_${id} [list "[string repeat "..." [expr $level-1]]$category_name" $category_id]
    }
    set tree_name_${id} [category_tree::get_name $id]
    # Grab value directly from request
    if { [ns_queryexists cat_${id}] } {
        set cat_${id} [ns_queryget cat_${id}]
    }
    lappend filters cat_${id} \
        [list label \$tree_name_${id} \
             values \$values_${id} \
             where_clause "exists (select 1 from category_object_map where object_id = le.entry_id and category_id = :cat_${id})"]

    # Orderby
    lappend orderbys c_${id}_category_id  \
        [list label \$tree_name_${id} multirow_cols c_${id}_category_id]

    # Groupby
    set groupby_values [list [category_tree::get_name $id] \
                                [list [list groupby c_${id}_category_id] \
                                     [list orderby c_${id}_category_id]]]
    
}


if {$show_tasks_p} {
    lappend normal_row task_name {}
    lappend elements task_name {
	label "[_ logger.Task]"
	link_url_eval {[export_vars -base "${my_project_manager_url}task-one" { task_id }]}
    }
}

lappend normal_row value {} description {}

# we modify the queries if we are viewing tasks

if { [exists_and_not_null pm_task_id]} {
    set task_select "task.title as task_name, task.item_id as task_id,"

    set task_left_join {
        LEFT JOIN  (select 
                    r.title, 
                    ar.object_id_two as logger_entry,
                    i.item_id 
                    from 
                    cr_items i, 
                    cr_revisions r,
		    acs_data_links ar
		    where r.item_id = ar.object_id_one and
                    i.live_revision = r.revision_id) task 
        ON le.entry_id = task.logger_entry,
    }
} else {
    set task_left_join ","
    set task_select ""
}

#----------------------------------------------------------------------
# Define list
#----------------------------------------------------------------------

if {![info exists add_link]} {
    set add_link "${base_url}project-select"
}

set actions_list [list "[_ logger.Add_Entry]" $add_link "[_ logger.Add_new_log_entry]"] 

set delete_link "${base_url}log-delete"

set bulk_actions_list [list "[_ logger.Delete]" $delete_link "[_ logger.lt_Delete_checked_entrie]"] 

list::create \
    -name entries \
    -multirow entries \
    -key entry_id \
    -row_pretty_plural "[_ logger.entries]" \
    -checkbox_name checkbox \
    -selected_format $format \
    -class "list" \
    -main_class "list" \
    -sub_class "narrow" \
    -pass_properties {
        variable
    } -actions $actions_list \
    -bulk_actions $bulk_actions_list \
    -bulk_action_export_vars {
        return_url
    } \
    -elements $elements -filters $filters \
    -groupby {
        label "[_ logger.Group_by]"
        type multivar
        values $groupby_values
    } -orderby $orderbys -formats {
            normal {
            label "[_ logger.Table]"
            layout table
            row $normal_row
        }
        detailed {
            label "[_ logger.Detailed_table]"
            layout table
            row {
                checkbox {
                    html { rowspan 2 }
                }
                edit {} 
                project_id {}
                user_id {}
                time_stamp {}
                value {}
            }
            row {
                description_long {
                    html { colspan 5 }
                    hide_p 0
                }
            }
        }
        list {
            label "[_ logger.List]"
            layout list
            template {
                <table cellpadding="0" cellspacing="4">
                  <tr>
                    <td valign="top">
                      <listelement name="checkbox"> 
                    </td>
                    <td valign="top">
                      <span class="list-label">@variable.name@:</span>
                      <listelement name="value">
                      <span class="list-label">@variable.unit@</span><br>

                      <listelement name="description_long"><br>

                      <span class="list-label">[_ logger.Project_1]</span> <listelement name="project_id"><br>

                      <span class="list-label">[_ logger.By]</span> <listelement name="user_id">
                      <span class="list-label">[_ logger.on]</span> <listelement name="time_stamp">
                    </td>
                  </tr>
                </table>
            }
        }
        csv {
            label "[_ logger.CSV]"
            output csv
            page_size 0
        }
    }

# TODO B: With multiple categories from the same tree, make sure they're listed in correct sort_order



# We add a virtual column per category tree

# some more documentation of what's going on here would be helpful. 

set extend  { edit_url delete_url delete_onclick time_stamp_pretty edit_p delete_p my_base_url my_project_manager_url task_name task_id }
foreach id $tree_ids {
    lappend extend c_${id}_category_id
}

array set row_categories [list]
array set project_write_p [list]

db_multirow -extend $extend -unclobber entries select_entries2 { } {

    set my_base_url $base_url 
    set my_project_manager_url $project_manager_url

    if { [exists_and_not_null tree_id] && [exists_and_not_null category_id] } {
        lappend row_categories($tree_id) $category_id
    }

    if {$show_tasks_p} {
	if {![exists_and_not_null task_id]} {
	    set task_id ""
	    set task_name ""
	    db_0or1row get_task {
		select 
		r.title as task_name, 
		i.item_id as task_id
		from 
		cr_items i, 
		cr_revisions r,
		acs_data_links ar
		where r.item_id = ar.object_id_one and
		i.live_revision = r.revision_id
		and object_id_two = :entry_id
	    }
	}
    }
    
    if { ![db_multirow_group_last_row_p -column entry_id] } {
        continue
    } else {
        set selected_p [string equal [ns_queryget entry_id] $entry_id]
        set edit_url [export_vars -base "${base_url}log" { entry_id { edit t } pm_project_id pm_task_id { return_url [ad_return_url] } }]
        if { ![exists_and_not_null project_write_p($project_id)] } {
            set project_write_p($project_id) [template::util::is_true [permission::permission_p -object_id $project_id -privilege write]]
        }
        set edit_p [expr $project_write_p($project_id) || ($user_id == [ad_conn user_id])]
        set delete_p $edit_p
        if { $delete_p } {
            set delete_onclick "return confirm('Are you sure you want to delete log entry with $value $variable(unit) $variable(name) on $time_stamp?');"
            set delete_url [export_vars -base "${base_url}log-delete" { entry_id }]
        } else {
            set delete_url {}
        }
        set time_stamp_pretty [lc_time_fmt $time_stamp_ansi "%x"]

        foreach tree_id [array names row_categories] {
            set c_${tree_id}_category_id $row_categories($tree_id)
        }
        
        array unset row_categories
    }
}



# This spits out the CSV if we happen to be in CSV layout
list::write_output -name entries
