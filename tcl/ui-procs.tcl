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
} {
    <p>
      Return 1 if the navbar link with given URL (relative server URL) should be marked
      selected in the UI for the current request and 0 otherwise.
    </p>

    <p>
      A link is considered selected if the current page url starts with the url of the link
      followed by the optional slash, question mark and query string
    </p>

    @author Peter Marklund
} {
    # Let's remove any trailing slash and make it optional in our pattern
    regsub {(.*)/$} $navbar_url {\1} url_no_slash

    # For readability I define the pattern in curly braces which avoids a lot of backslashes
    set selected_pattern {^<url_no_slash>/?(\?[^/]*$|$)}
    regsub {<url_no_slash>} $selected_pattern $url_no_slash selected_pattern

    set page_url [ad_conn url]
    set selected_p [regexp $selected_pattern $page_url match]

    return $selected_p
}
