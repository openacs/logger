# Set up links in the navbar that the user has access to

set user_id [ad_conn user_id]
set package_id [ad_conn package_id]
set package_url [ad_conn package_url]
set page_url [ad_conn url]

set project_manager_url [logger::util::project_manager_url]

set admin_p [permission::permission_p -object_id $package_id -privilege admin]

# The links used in the navbar on format url1 label1 url2 label2 ...
set link_list {}

# Log entries page
set index_urls [list "${package_url}" "${package_url}."]
lappend link_list $index_urls
lappend link_list {}
lappend link_list "List"

# My log entry page
if { [ad_conn user_id] != 0 } {
    lappend link_list $index_urls
    lappend link_list [list [list user_id $user_id]]
    lappend link_list "My Entries"

    lappend link_list [list "${package_url}project-select"]
    lappend link_list {}
    lappend link_list "Add Entry"

    if {![empty_string_p $project_manager_url]} {
        lappend link_list [list "${project_manager_url}"]
        lappend link_list {}
        lappend link_list "Projects"

        lappend link_list [list "${project_manager_url}processes"]
        lappend link_list {}
        lappend link_list "Processes"

        lappend link_list [list "${project_manager_url}tasks"]
        lappend link_list {}
        lappend link_list "Tasks"

    }
}

# The admin index page
if { $admin_p } {
    lappend link_list [list "${package_url}admin/"]
    lappend link_list {}
    lappend link_list "Admin"
}

# Convert the list to a multirow and add the selected_p attribute
multirow create links name url selected_p
foreach {url_list param_list label} $link_list {
    set selected_p 0
    foreach url $url_list {
        set selected_p [logger::ui::navbar_link_selected_p $url $param_list]
        if { $selected_p } {
            break
        }
    }

    if { ![empty_string_p $param_list] } {
        append url "?[export_vars $param_list]"
    }

    multirow append links $label $url $selected_p
}

ad_return_template
