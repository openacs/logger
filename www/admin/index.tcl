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

db_multirow projects select_projects {} {
    set description [string_truncate -len 50 $description]
}

logger::package::variables_multirow

ad_return_template
