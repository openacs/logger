<?xml version="1.0"?>

<queryset>

  <fullquery name="logger::projection::new.insert_projection">
    <querytext>
      insert into logger_projections (projection_id, project_id, variable_id, start_time, end_time, value)
           values (:projection_id, :project_id, :variable_id, :start_time, :end_time, :value)
    </querytext>
  </fullquery>

  <fullquery name="logger::projection::delete.delete_projection">
    <querytext>
        delete from logger_projections
        where projection_id = :projection_id
    </querytext>
  </fullquery>

  <fullquery name="logger::projection::get.select_projection">
    <querytext>
        select projection_id, 
               project_id, 
               variable_id, 
               start_time, 
               end_time, 
               value
        from logger_projections
        where projection_id = :projection_id
    </querytext>
  </fullquery>

</queryset>
