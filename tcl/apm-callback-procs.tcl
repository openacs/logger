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
    logger::variable::new -name "[_ logger.Time]" -unit "[_ logger.hours]" -pre_installed_p 1

    logger::variable::new -name "[_ logger.Expense]" -unit "[_ logger.Euro]" -pre_installed_p 1
}

ad_proc -public -callback logger::apm::instantiate {
    {-package_id:required}
} {
}

ad_proc -public logger::apm::after_instantiate {
    {-package_id:required}
} {
    At the moment this is primarily a placeholder for the callback that allows the setting
    of the DefaultDescriptionList

    @author Peter Marklund
} {
    callback logger::apm::instantiate -package_id $package_id
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

ad_proc -public -callback pm::project_new -impl logger {
    {-package_id:required}
    {-project_id:required}
    {-data:required}
} {
    Create a new logger project for each new project manager project
} {
    array set callback_data $data

    db_1row project_data {
	select creation_user, title, description, project_id as project_rev_id
	from pm_projectsx
	where item_id = :project_id
    }

    if {[exists_and_not_null callback_data(organization_id)]} {
	set customer_name [organizations::name -organization_id $callback_data(organization_id)]
	if {![empty_string_p $customer_name]} {
	    set title "$customer_name - $title"
	}
    }

    # Trim the description
    set logger_description [ad_html_to_text $description]

    # create a logger project
    set logger_project [logger::project::new \
			    -name $title \
			    -description $logger_description \
			    -project_lead $creation_user]

    application_data_link::new -this_object_id $project_id -target_object_id $logger_project

    if {[exists_and_not_null callback_data(variables)]} {
	foreach var $callback_data(variables) {
	    logger::project::map_variable -project_id $logger_project -variable_id $var
	}
    } else {
	# add in the default variable
	logger::project::map_variable -project_id $logger_project -variable_id [logger::variable::get_default_variable_id]
    }

    # we want the logger project to show up in logger!
    set logger_packages [application_link::get_linked -from_package_id $package_id -to_package_key "logger"]
    foreach logger_package_id $logger_packages {
        logger::package::map_project \
            -project_id $logger_project \
            -package_id $logger_package_id
    }
    
    # if we have a default logger, map this as well (if not already mapped)
    set default_logger_package_id [site_node::get_element -url "/logger" -element "package_id"]
    if {[lsearch -exact $logger_packages $default_logger_package_id] == -1} {
	logger::package::map_project \
	    -project_id $logger_project \
	    -package_id $default_logger_package_id
    }
}

ad_proc -public -callback pm::project_edit -impl logger {
    {-package_id:required}
    {-project_id:required}
    {-data:required}
} {
    If we edit the name of the project, we need to edit the logger
    project name too.
} {
    array set callback_data $data
    set project_rev_id [pm::project::get_project_id -project_item_id $project_id]

    db_1row project_data {
	select creation_user, title, description, status_id
	from pm_projectsx
	where project_id = :project_rev_id
    }

    set logger_project [lindex [application_data_link::get_linked -from_object_id $project_id -to_object_type logger_project] 0]
    set active_p [pm::status::open_p -project_status_id $status_id]

    if {[exists_and_not_null callback_data(organization_id)]} {
	set customer_name [organizations::name -organization_id $callback_data(organization_id)]
	if {![empty_string_p $customer_name]} {
	    append title "$customer_name - $title"
	}
    }

    # Trim the description
    set logger_description [ad_html_to_text $description]

    logger::project::edit \
        -project_id $logger_project \
        -name $title \
        -description "$logger_description" \
        -project_lead $creation_user \
        -active_p $active_p

    if {[exists_and_not_null callback_data(variables)]} {
	logger::project::remap_variables -project_id $logger_project -new_variable_list $callback_data(variables)
    } else {
	logger::project::remap_variables -project_id $logger_project -new_variable_list [logger::variable::get_default_variable_id]
    }
}

ad_proc -public -callback pm::task_edit -impl logger {
    {-package_id:required}
    {-task_id:required}
} {
    Update all logged hours to make sure the hours are
    set to the correct project whenever the project is changed.
} {
    set project_item_id [pm::task::project_item_id -task_item_id $task_id]

    set logger_project [lindex [application_data_link::get_linked -from_object_id $project_item_id -to_object_type logger_project] 0]

    db_dml update_logger_entries {
	update logger_entries 
	set project_id = :logger_project 
	where entry_id in (select object_id_two
			   from acs_data_links
			   where object_id_one = :task_id)
    }
}

ad_proc -public logger::apm::after_upgrade {
    {-from_version_name:required}
    {-to_version_name:required}
} {

    apm_upgrade_logic \
        -from_version_name $from_version_name \
        -to_version_name $to_version_name \
        -spec {
	    1.1b2 1.1b3 {
		# apm_parameter_register "DefaultDescriptionList" "A list of default descriptions separeted by &quot;;&quot; to use when adding a log entry." "logger" "" "string" 
	    }
	}
}
