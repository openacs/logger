ad_page_contract {
    Make project inactive.
} {
    project_id:integer,multiple,optional
}

db_transaction {
    foreach id $project_id {
        logger::project::set_active_p \
            -project_id $id \
            -active_p f

        if {[logger::util::project_manager_linked_p]} {
            db_dml set_status "
                UPDATE 
                pm_projects
                SET 
                status_id = [pm::status::default_closed] 
                WHERE
                project_id = (select live_revision from cr_items where item_id = [pm::project::get_project -logger_project $id])
            "

        }
    }
}

ad_returnredirect .

