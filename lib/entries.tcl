# Expected variables:
#
# filters_p, default true, show filters
#

if { ![exists_and_not_null filters_p] } {
    set filters_p 1
}

if { ![exists_and_not_null format] } {
    set format "normal"
}

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

# Define the list

list::create \
    -name entries \
    -multirow entries \
    -key entry_id \
    -row_pretty_plural "entries" \
    -checkbox_name checkbox \
    -selected_format $format \
    -class "list" \
    -main_class "list" \
    -sub_class "narrow" \
    -pass_properties {
        variable
    } -actions {
        "Add Entry" "project-select" "Add new log entry"
    } -bulk_actions {
        "Delete" "log-delete" "Delete checked entries"
    } -elements {
        edit {
            label {}
            display_template {
               <if @entries.edit_p@ true>
                <a href="@entries.edit_url@" title="Edit this log entry"
                ><img src="/shared/images/Edit16.gif" height="16" width="16" 
                alt="Edit" border="0"></a>
                </if>        
            }
        }
        project_id {
            display_col project_name
            label "Project"
            hide_p {[ad_decode [exists_and_not_null project_id] 1 1 0]}
        }
        user_id {
            label "User"
            display_col user_name
            link_url_eval {[acs_community_member_url -user_id $user_id]}
            csv_col user_name
            hide_p {[ad_decode [exists_and_not_null user_id] 1 1 0]}
        }
        time_stamp {
            label "Date"
            display_col time_stamp_pretty
            aggregate_label {[ad_decode $variable(type) "additive" "Total" "Average"]}
            aggregate_group_label {[ad_decode $variable(type) "additive" "Group total" "Group Average"]}
        }
        value {
            label $variable(name)
            link_url_eval {log?[export_vars { entry_id }]}
            link_html { title "View this entry" }
            aggregate {[ad_decode $variable(type) "additive" sum average]}
            html { align right }
            display_eval {[lc_numeric $value]}
        }
        description {
            label "Description"
            display_eval {[string_truncate -len 50 -- $description]}
            link_url_eval {log?[export_vars { entry_id }]}
            link_html { title "View this entry" }
        }
        description_long {
            label "Description"
            display_eval {[string_truncate -len 400 -- $description]}
            hide_p 1
            link_url_eval {log?[export_vars { entry_id }]}
            link_html { title "View this entry" }
        }
    } -filters {
        project_id {
            label "Projects"
            values {[db_list_of_lists select_projects {}]}
            where_clause {
                le.project_id = :project_id
            }
            add_url_eval {[export_vars -base "log" { { project_id $__filter_value } variable_id }]}
        }
        variable_id {
            label "Variables"
            values {[db_list_of_lists select_variables {}]}
            where_clause {
                le.variable_id = :variable_id
            }
            add_url_eval {[ad_decode [exists_and_not_null project_id] 1 [export_vars -base "log" { project_id { variable_id $__filter_value } }] ""]}
            has_default_p t
        }
        user_id {
            label "Users"
            values {[db_list_of_lists select_users {}]}
            where_clause {
                submitter.user_id = :user_id
            }
        }
        time_stamp {
            label "Date"
            where_clause {
                le.time_stamp >= to_date(:start_date,'YYYY-MM-DD') and le.time_stamp <= to_date(:end_date,'YYYY-MM-DD')
            }
            other_label "Custom"
            type multival
            has_default_p 1
            values {
                {
                    "Today" {
                        [clock format [clock seconds] -format "%Y-%m-%d"]
                        [clock format [clock seconds] -format "%Y-%m-%d"]
                    }
                }
                {
                    "Yesterday" {
                        [clock format [clock scan "-1 days"] -format "%Y-%m-%d"]
                        [clock format [clock scan "-1 days"] -format "%Y-%m-%d"]
                    }
                }
                {
                    "This week" {
                        [clock format [clock scan "-$weekdayno days"] -format "%Y-%m-%d"]
                        [clock format [clock scan "[expr 6-$weekdayno] days"] -format "%Y-%m-%d"]
                    }
                }
                {
                    "Last week" {
                        [clock format [clock scan "[expr -7-$weekdayno] days"] -format "%Y-%m-%d"]
                        [clock format [clock scan "[expr -1-$weekdayno] days"] -format "%Y-%m-%d"]
                    }
                }
                {
                    "Past 7 days" {
                        [clock format [clock scan "-1 week 1 day"] -format "%Y-%m-%d"]
                        [clock format [clock seconds] -format "%Y-%m-%d"]
                    }
                }
                {
                    "This month" {
                        [clock format [clock scan "[expr 1-$monthdayno] days"] -format "%Y-%m-%d"]
                        [clock format [clock scan "1 month -1 day" -base [clock scan "[expr 1-$monthdayno] days"]] -format  "%Y-%m-%d"]
                    }
                }
                {
                    "Last month" {
                        [clock format [clock scan "-1 month [expr 1-$monthdayno] days"] -format "%Y-%m-%d"]
                        [clock format [clock scan "1 month -1 day" -base [clock scan "-1 month [expr 1-$monthdayno] days"]] -format  "%Y-%m-%d"]
                    }
                }
                {
                    "Past 30 days" {
                        [clock format [clock scan "-1 month 1 day"] -format "%Y-%m-%d"]
                        [clock format [clock seconds] -format "%Y-%m-%d"]
                    }
                }
                {
                    "Always" {
                        [clock format 0 -format "%Y-%m-%d"]
                        [clock format [clock scan "+10 year"] -format "%Y-%m-%d"]
                    }
                }
            }
        }
    } -groupby {
        label "Group by"
        type multivar
        values {
            { "Day" { { groupby time_stamp } { orderby time_stamp,desc } } }
            { "Week" { { groupby time_stamp_week } { orderby time_stamp,desc } }  }
            { "Project" { { groupby project_name } { orderby project_id,asc } } }
            { "User" { { groupby user_id } { orderby user_id,asc } } }
        }
    } -orderby {
        default_value time_stamp,desc
        time_stamp {
            label "Date"
            orderby_desc "le.time_stamp desc, ao.creation_date desc"
            orderby_asc "le.time_stamp asc, ao.creation_date asc"
            default_direction desc
        }
        project_id {
            label "Project" 
            orderby_asc "project_name asc, le.time_stamp desc, ao.creation_date desc"
            orderby_desc "project_name desc, le.time_stamp desc, ao.creation_date desc"
        }
        user_id {
            label "User"
            orderby_asc "user_name asc, le.time_stamp desc, ao.creation_date desc"
            orderby_desc "user_name desc, le.time_stamp desc, ao.creation_date desc"
        }
        value {
            label $variable(name)
            orderby_asc "value asc, le.time_stamp desc, ao.creation_date desc"
            orderby_desc "value desc, le.time_stamp desc, ao.creation_date desc"
        }
        description {
            label "Description"
            orderby_asc "description asc, le.time_stamp desc, ao.creation_date desc"
            orderby_desc "description desc, le.time_stamp desc, ao.creation_date desc"
        }
    } -formats {
        normal {
            label "Table"
            layout table
            row {
                checkbox {}
                edit {}
                project_id {}
                user_id {}
                time_stamp {}
                value {}
                description {}
            }
        }
        detailed {
            label "Detailed table"
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
            label "List"
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

                      <span class="list-label">Project:</span> <listelement name="project_id"><br>

                      <span class="list-label">By</span> <listelement name="user_id">
                      <span class="list-label">on</span> <listelement name="time_stamp">
                    </td>
                  </tr>
                </table>
            }
        }
        csv {
            label "CSV"
            output csv
            page_size 0
        }
    }



# This query will override the ad_page_contract value entry_id

db_multirow -extend { edit_url delete_url delete_onclick } -unclobber entries select_entries "
" {
    set selected_p [string equal [ns_queryget entry_id] $entry_id]
    set edit_url "log?[export_vars { entry_id { edit t } }]"
    set edit_p [ad_decode [expr [ad_decode $edit_p "t" 1 0]  || ($user_id == [ad_conn user_id])] 1 "t" "f"]
    if { $delete_p } {
        set delete_onclick "return confirm('Are you sure you want to delete log entry with $value $variable(unit) $variable(name) on $time_stamp?');"
        set delete_url "log-delete?[export_vars { entry_id }]"
    } else {
        set delete_url ""
    }
}



# This spits out the CSV if we happen to be in CSV layout
list::write_output -name entries
