#
# Displays current projection, and where we're at relative to it
#
# Expects:
#
# projection_id
#

# Projection info
# TODO: Really should use the projection::get API
db_1row projection {
    select p.name,
           p.project_id,
           p.variable_id,
           p.value as projected_value,
           to_char(start_time, 'YYYY-MM-DD HH24:MI:SS') as start_time_ansi,
           to_char(end_time, 'YYYY-MM-DD HH24:MI:SS') as end_time_ansi
    from   logger_projections p
    where  p.projection_id = :projection_id
}

logger::variable::get \
    -variable_id $variable_id \
    -array variable


# Get current budget consumption level, and latest timestamp within the range
set total_value 0
set counter 0
set time_stamp_ansi $start_time_ansi

db_foreach select_values {
    select e.value,
           to_char(e.time_stamp, 'YYYY-MM-DD HH24:MI:SS') as time_stamp_ansi
    from   logger_entries e
    where  e.project_id = :project_id
    and    e.variable_id = :variable_id
    and    e.time_stamp 
               between to_date(:start_time_ansi, 'YYYY-MM-DD HH24:MI:SS') 
               and     to_date(:end_time_ansi, 'YYYY-MM-DD HH24:MI:SS') 
    order  by e.time_stamp
} {
    incr counter
    set total_value [expr $total_value + $value]
}

# TODO: plus/minus one problem: logger_entry.time_stamp always has time part being midnight
# We should probably change all logic to use dates, not timestamps (and then we can use the projection API)


# Calculate percentage of time spent
set start_time_epoch [clock scan $start_time_ansi]
set end_time_epoch [clock scan $end_time_ansi]
set time_stamp_epoch [clock scan $time_stamp_ansi]

set total_time [expr $end_time_epoch - $start_time_epoch]
set progress_time [expr $time_stamp_epoch - $start_time_epoch]

# We do a floating point division with round here, because daylight savings
# may otherwise make the computation off by one
set total_days [expr round($total_time / (60*60)/24.0) + 1]
set progress_days [expr round($progress_time / (60*60)/24.0) + 1]

set progress_time_pct [expr round($progress_time*100.0 / $total_time)]
set progress_time_pct_inverse [expr 100-$progress_time_pct]


# Calculate percentage of value spent
set progress_value_pct [expr round($total_value*100.0 / $projected_value)]
set progress_value_pct_inverse [expr (100-$progress_value_pct)]


set total_value_pretty [lc_numeric $total_value]
set projected_value_pretty [lc_numeric $projected_value]


set progress_time_pct2 [expr $progress_time_pct * 2]
set progress_time_pct_inverse2 [expr $progress_time_pct_inverse * 2]
set progress_value_pct2 [expr $progress_value_pct * 2]
set progress_value_pct_inverse2 [expr $progress_value_pct_inverse * 2]
