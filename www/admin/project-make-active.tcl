ad_page_contract {
    Make project active.
} {
    project_id:integer,multiple,optional
}

db_transaction {
    foreach id $project_id {
        logger::project::set_active_p \
            -project_id $id \
            -active_p t
    }
}

ad_returnredirect .

