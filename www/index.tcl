ad_page_contract {
    User index page for the Logger application.
    
    @author Peter marklund (peter@collaboraid.biz)
    @author Lars Pind (lars@collaboraid.biz)
    @creation-date 2003-04-08
    @cvs-id $Id$
} {
    entry_id:integer,optional
    {variable_id:integer,optional {[logger::variable::get_default_variable_id]}}
    project_id:integer,optional
    user_id:integer,optional
    {time_stamp:multiple,optional {[clock format [clock scan "-[clock format [clock seconds] -format %w] days"] -format "%Y-%m-%d"] [clock format [clock scan "[expr 6-[clock format [clock seconds] -format %w]] days"] -format "%Y-%m-%d"]}}
    groupby:optional
    orderby:optional
    projection_id:optional
    {format "normal"}
    page:integer,optional
} -validate {
    time_stamps_valid {
        if { [llength $time_stamp] != 0 && [llength $time_stamp] != 2 } {
            ad_complain "You must supply either two or no time_stamp values"
        } else {
            if { [catch { 
                set time_stamp_secs [list]
                foreach ts [lsort $time_stamp] {
                    lappend time_stamp_secs [clock scan $ts] 
                }
                
                # We sort the time stamps here. Plain integer sort should be what we want
                set time_stamp_secs [lsort -integer $time_stamp_secs]
            }] } {
                ad_complain "Time stamps not valid"
            } else {
                set start_date [clock format [lindex $time_stamp_secs 0] -format "%Y-%m-%d"]
                set end_date [clock format [lindex $time_stamp_secs 1] -format "%Y-%m-%d"]
            }
        }
    }
}

set instance_name [ad_conn instance_name]

set admin_p [permission::permission_p -object_id [ad_conn package_id] -privilege admin]

if { ![exists_and_not_null project_id] } {
    set package_projects [logger::package::all_projects_in_package -package_id [ad_conn package_id]]
    set num_package_projects [llength $package_projects]
    if { $num_package_projects == 1 } {
        set project_id $package_projects
    }
}

# Default to the current projection
if { [exists_and_not_null project_id] && [exists_and_not_null variable_id] && ![exists_and_not_null projection_id] } {
    set projection_id [logger::project::get_current_projection \
                           -project_id $project_id \
                           -variable_id $variable_id]
}
