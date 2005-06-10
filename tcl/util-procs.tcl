ad_library {
    Procedures in the logger::util namespace. Contains
    helper procedures used by the package.
    
    @creation-date 2003-04-22
    @author Peter Marklund (peter@collaboraid.biz)
    @cvs-id $Id$
}

namespace eval logger::util {}

ad_proc -private logger::util::set_vars_from_ad_conn {
    variable_names
} {
    Takes a list of variable names and initializes variables
    with those names in the callers scope using values from
    the ad_conn data structure.

    The proc uses logger::util::lookup_ad_conn_var_name to
    get the ad_conn var name from a variable name in the provided list.

    @param variable_names A list of variable names to set in the callers scope.

    @author Peter Marklund
} {
    if { [ad_conn isconnected] } {
        foreach variable_name $variable_names {
            upvar $variable_name $variable_name
            set ad_conn_name [logger::util::lookup_ad_conn_var_name $variable_name]
            set $variable_name [ad_conn $ad_conn_name]
        }
    } else {
        foreach variable_name $variable_names {
            upvar $variable_name $variable_name
            set $variable_name [db_null]
        }
    }    
}

ad_proc -private logger::util::lookup_ad_conn_var_name {
    variable_name
} {
    Given a variable name return the corresponding ad_conn var name.

    For example creation_user will return user_id.

    @author Peter marklund
} {
    switch -- $variable_name {
        creation_user {
            set ad_conn_name user_id
        }
        creation_ip {
            set ad_conn_name peeraddr
        }
        default {
            set ad_conn_name $variable_name
        }
    }

    return $ad_conn_name
}


ad_proc -public logger::util::project_manager_url {
} {
    Returns a valid URL to a project-manager instance, if and only if this
    logger instance is set up to be integrated in project-manager.
    This is set in the project-manager admin pages. Currently, this
    proc assumes it is called from within logger.
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-05-24
    
    @return empty string if there is no linked in project-manager
    
    @error 
} {

    set package_id [ad_conn package_id]

    return [util_memoize "logger::util::project_manager_url_cached -package_id $package_id"]
}


ad_proc -private logger::util::project_manager_url_cached {
    -package_id:required
} {
    Memoized portion of project_manager_url
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-05-24

    @see logger::util::project_manager_url
    
    @return 
    
    @error empty string if project manager is not installed
} {

    set pm_package_id [lindex [application_link::get_linked -from_package_id $package_id -to_package_key "project-manager"] 0]
    return [lindex [site_node::get_url_from_object_id -object_id $pm_package_id] 0]

}


ad_proc -public logger::util::project_manager_linked_p {
} {
    Returns 1 if there is a project manager linked to this instance
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-06-03
    
    @return 
    
    @error 
} {
    set url [logger::util::project_manager_url]

    if {[empty_string_p $url]} {
        return 0
    } else {
        return 1
    }
}
