<?xml version="1.0"?>

<queryset>
  <rdbms><type>postgresql</type><version>7.2</version></rdbms>

  <fullquery name="logger::entry::new.insert_entry">
    <querytext>
        select logger_entry__new (
                  :entry_id,
                  :project_id,
                  :variable_id,
                  :value,
                  :time_stamp,
                  :description,
                  :creation_user,
                  :creation_ip
              );
    </querytext>
  </fullquery>

  <fullquery name="logger::entry::delete.delete_entry">
    <querytext>
        select logger_entry__del(:entry_id);
    </querytext>
  </fullquery>
 
</queryset>
