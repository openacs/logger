<?xml version="1.0"?>

<queryset>

  <fullquery name="logger::entry::get.select_entry">
    <querytext>
        select le.entry_id,
               le.project_id, 
               le.variable_id,
               le.value,
               le.time_stamp,
               le.description,
               ao.creation_user,
               ao.creation_date
        from logger_entries le,
             acs_objects ao
        where le.entry_id = :entry_id
          and le.entry_id = ao.object_id
    </querytext>
  </fullquery>

  <fullquery name="logger::entry::edit.update_entry">
    <querytext>
        update logger_entries
                set value = :value,
                    time_stamp = :time_stamp,
                    description = :description
           where entry_id = :entry_id
    </querytext>
  </fullquery>

  <fullquery name="logger::entry::task_id.task_id">
    <querytext>
      select current_timestamp when 1 = 0
    </querytext>
  </fullquery>

</queryset>
