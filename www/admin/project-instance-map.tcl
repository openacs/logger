ad_page_contract {
    Map a project to a logger instance
} {
    project_id:integer
    {unmap "f"}
}

set package_id [ad_conn package_id]

if { [string equal $unmap "f"] } {

    logger::package::map_project \
        -project_id $project_id \
        -package_id $package_id

} else {

    logger::package::unmap_project \
        -project_id $project_id \
        -package_id $package_id

}

ad_returnredirect .
