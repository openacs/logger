<?xml version="1.0"?>

<queryset>
  <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

  <fullquery name="logger::entry::new.insert_entry">
    <querytext>
      begin
        :1 := logger_entry.new (
                  entry_id => :entry_id,
                  project_id => :project_id,
                  variable_id => :variable_id,
                  value => :value,
                  time_stamp => :time_stamp,
                  description => :description,
                  creation_user => :creation_user,
                  creation_ip => :creation_ip
              );
      end;
    </querytext>
  </fullquery>

  <fullquery name="logger::entry::delete.delete_entry">
    <querytext>
      begin
        logger_entry.del(:entry_id);
      end;
    </querytext>
  </fullquery>
 
</queryset>
