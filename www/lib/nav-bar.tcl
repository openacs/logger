# Set up links in the navbar that the user has access to

set package_id [ad_conn package_id]
set package_url [ad_conn package_url]
set page_url [ad_conn url]

set admin_p [permission::permission_p -object_id $package_id -privilege admin]

# The links used in the navbar on format url1 label1 url2 label2 ...
set link_list {}

if { [ad_conn user_id] != 0 } {
    lappend link_list "${package_url}"
    lappend link_list "Log entries"
}

if { $admin_p } {
    lappend link_list "${package_url}admin/"
    lappend link_list "Admin"
}

# Convert the list to a multirow and add the selected_p attribute
multirow create links name url selected_p
foreach {url label} $link_list {
    if { [regexp {/$} $url match] } {
        # Index page - special case as we additionally need to check for a URL with
        # the index word in it
        set selected_p [expr [logger::ui::navbar_link_selected_p $url] || \
                            [logger::ui::navbar_link_selected_p ${url}index]]
    } else {
        # Not an index page
        set selected_p [logger::ui::navbar_link_selected_p $url]
    }

    multirow append links $label $url $selected_p
}

ad_return_template
