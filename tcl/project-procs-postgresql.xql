<?xml version="1.0"?>

<queryset>
  <rdbms><type>postgresql</type><version>7.2</version></rdbms>

  <fullquery name="logger::project::insert.insert_project">
    <querytext>
        select  logger_project__new (
                :project_id,
                :name,
                :description,
                :project_lead,
                :creation_user,
                :creation_ip,
                :package_id               
              );
    </querytext>
  </fullquery>

  <fullquery name="logger::project::delete.delete_project">
    <querytext>
          select logger_project__del(:project_id);
    </querytext>
  </fullquery>
 
  <fullquery name="logger::project::get_current_projection.select_current_projection">
    <querytext>
        select min(p.projection_id)
        from   logger_projections p
        where  p.project_id = :project_id
        and    p.variable_id = :variable_id
        and    current_timestamp between p.start_time and p.end_time
    </querytext>
  </fullquery>

</queryset>
