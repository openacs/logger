<?xml version="1.0"?>

<queryset>

  <fullquery name="n_log_entries">
    <querytext>
    select count(*)
    from logger_entries
    where variable_id = :variable_id
    </querytext>
  </fullquery>

</queryset>
