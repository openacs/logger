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
