<?xml version="1.0"?>

<queryset>
  <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

  <fullquery name="logger::measurement::new.insert_measurement">
    <querytext>
      begin
        :1 := logger_measurement.new (
                  measurement_id => :measurement_id,
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

  <fullquery name="logger::measurement::new.delete_measurement">
    <querytext>
      begin
        logger_measurement.delete(:measurement_id);
      end;
    </querytext>
  </fullquery>
 
</queryset>
