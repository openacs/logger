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
    }
}

ad_returnredirect .

