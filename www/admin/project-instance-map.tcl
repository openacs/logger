ad_page_contract {
    Map a project to a logger instance
} {
    project_id:integer
    {unmap "f"}
}

set package_id [ad_conn package_id]

if { [string equal $unmap "f"] } {

    permission::require_permission -object_id $project_id -privilege "read"
    
    db_dml map_project {
        insert into logger_project_pkg_map (project_id, package_id) values (:project_id, :package_id)
    }
} else {
    db_dml map_project {
        delete 
        from   logger_project_pkg_map 
        where  project_id = :project_id
        and    package_id = :package_id
    }
}

ad_returnredirect .
