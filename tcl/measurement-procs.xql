<?xml version="1.0"?>

<queryset>

  <fullquery name="logger::measurement::get.select_measurement">
    <querytext>
        select measurement_id,
               project_id, 
               variable_id,
               value,
               time_stamp,
               description
        from logger_measurements
        where measurement_id = :measurement_id
    </querytext>
  </fullquery>

</queryset>
