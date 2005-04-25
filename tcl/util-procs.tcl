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

    set package_url [ad_conn package_url]

    # assumes that these return in the same order!
    set possible_packages [site_node::get_children -all -package_key project-manager -node_id [site_node::get_node_id -url "/"] -element package_id]
    set possible_urls [site_node::get_children -all -package_key project-manager -node_id [site_node::get_node_id -url "/"]]

    set return_url ""

    # we go through the list of project-manager URLs, and check if the
    # current package_url is listed as one to be integrated with
    # project-manager. If it is, we return the URL to that
    # project-manager instance. 

    set index 0

    foreach this_package_id $possible_packages {

        set primary_url [parameter::get \
                             -package_id $this_package_id \
                             -parameter "LoggerPrimaryURL"]

        if {![empty_string_p $primary_url]} {

            if {[string equal $package_url $primary_url]} {

                set project_manager_url [lindex $possible_urls $index]

                set return_url $project_manager_url
            }
        }

        incr index
    }

    return $return_url
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

ad_proc -public logger::util::project_manager_project_id {
    -project_id:required
} {
    return [db_string get_pm_project {
	SELECT
        item_id
	FROM
	pm_projects, cr_items
	WHERE
	logger_project = :project_id AND
	live_revision = project_id
    } -default 0
	   ]
}