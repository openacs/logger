<?xml version="1.0"?>

<queryset>

  <fullquery name="logger::entry::get.select_entry">
    <querytext>
        select entry_id,
               project_id, 
               variable_id,
               value,
               time_stamp,
               description
        from logger_entries
        where entry_id = :entry_id
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

</queryset>
