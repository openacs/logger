ad_library {
    Procedures in the logger::ui namespace. Those
    procedures are used to support the building of the logger
    UI.
    
    @creation-date 21 April 2003
    @author Peter Marklund (peter@collaboraid.biz)
    @cvs-id $Id$
}

namespace eval logger::ui {}

ad_proc -public logger::ui::navbar_link_selected_p {
    navbar_url
    param_list
} {
    <p>
      Return 1 if the navbar link with given URL (relative server URL) should be marked
      selected in the UI for the current request and 0 otherwise.
    </p>

    <p>
      A link is considered selected if the current page url starts with the url of the link
      and each HTML parameter in the param_list has the specified value.
    </p>

    @author Peter Marklund
} {
    # Let's remove any trailing slash and make it optional in our pattern
    regsub {(.*)/$} $navbar_url {\1} url_no_slash

    # For readability I define the pattern in curly braces which avoids a lot of backslashes
    set selected_pattern {^<url_no_slash>/?(\?[^/]*$|$)}
    regsub {<url_no_slash>} $selected_pattern $url_no_slash selected_pattern

    set page_url [ad_conn url]
    set url_matches_p [regexp $selected_pattern $page_url match]

    set params_match_p 1
    foreach {param_item} $param_list {
        set param_name [lindex $param_item 0]
        set param_value [lindex $param_item 1]

        set actual_param_value [ns_set iget [rp_getform] $param_name]

        ns_log Notice "pm debug param_name $param_name param_value $param_value actual_param_value $actual_param_value"
        if { ![string equal $param_value $actual_param_value] } {
            set params_match_p 0
            break
        }
    }

    if { [llength $param_list] == 0 && ![empty_string_p [ad_conn query]] } {
        # The navbar link has no url parameters but there url parameters in the
        # request. Don't consider the link selected
        set params_match_p 0
    }

    set selected_p [expr $url_matches_p && $params_match_p]

    ns_log Notice "pm debug url_no_slash $url_no_slash page_url $page_url selected_p $selected_p"

    return $selected_p
}
