ad_library {
    APM callback procedures in the logger::apm namespace.
    
    @creation-date 1 April 2003
    @author Peter Marklund (peter@collaboraid.biz)
    @cvs-id $Id$
}

namespace eval logger::apm {}

ad_proc -public logger::apm::after_install {} {
    The Logger application is primarily intended for time and expenses reporting
    so lets create those variables so that they don't need to be setup manually

    @author Peter Marklund
} {
    logger::variable::new -name "Time" -unit "hours" -pre_installed_p 1

    logger::variable::new -name "Expense" -unit "Euro" -pre_installed_p 1
}

ad_proc -public logger::apm::before_uninstall {} {
    This proc needs to tear down whatever the logger::apm::after_install proc
    sets up.

    @author Peter Marklund
} {
    # Let's delete all variables as this is guaranteed to cover the pre-installed ones
    db_foreach all_variables {
        select variable_id
        from logger_variables
    } {
        logger::variable::delete -variable_id $variable_id
    }
}

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
