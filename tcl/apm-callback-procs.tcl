ad_library {
    APM callback procedures in the logger::apm namespace.
    
    @creation-date 1 April 2003
    @author Peter Marklund (peter@collaboraid.biz)
    @cvs-id $Id$
}

namespace eval logger::apm {}

ad_proc -public logger::apm::before_uninstantiate {
    {-package_id:required}
} {
    Deletes all logger projects (and their data) mapped
    only to the given package before the package is deleted.
    We thus avoid having orphan logger data in the database.
    
    @author Peter Marklund
} {
    set project_id_list [logger::package::projects_only_in_package -package_id $package_id]
    foreach project_id $project_id_list {
        ns_log Notice "logger::apm::before_uninstantiate - deleting project $project_id for package $package_id"
        logger::project::delete -project_id $project_id
    }
}
