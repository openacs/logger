<?xml version="1.0"?>

<queryset>

  <fullquery name="logger::projection::new.insert_projection">
    <querytext>
      insert into logger_projections (projection_id, 
                                      project_id, 
                                      variable_id, 
                                      start_time, 
                                      end_time, 
                                      value,
                                      name,
                                      description)
           values (:projection_id, 
                   :project_id, 
                   :variable_id, 
                   to_date(:start_time, 'YYYY-MM-DD'), 
                   to_date(:end_time, 'YYYY-MM-DD'),
                   :value, 
                   :name, 
                   :description)
    </querytext>
  </fullquery>

  <fullquery name="logger::projection::edit.update_projection">
    <querytext>
        update logger_projections
            set variable_id = :variable_id,
            start_time = to_date(:start_time, 'YYYY-MM-DD'),
            end_time = to_date(:end_time, 'YYYY-MM-DD'),
            value = :value,
            name = :name,
            description = :description
        where projection_id = :projection_id
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
               to_char(start_time, 'YYYY-MM-DD') as start_time, 
               to_char(end_time, 'YYYY-MM-DD') as end_time, 
               value,
               name,
               description
        from logger_projections
        where projection_id = :projection_id
    </querytext>
  </fullquery>

</queryset>
