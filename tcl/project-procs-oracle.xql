<?xml version="1.0"?>

<queryset>
  <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

  <fullquery name="logger::project::insert.insert_project">
    <querytext>
      begin
        :1 := logger_project.new (
                project_id => :project_id,
                name => :name,
                description => :description,
                project_lead => :project_lead,
                creation_user => :creation_user,
                creation_ip => :creation_ip,
                package_id => :package_id               
              );
      end;
    </querytext>
  </fullquery>

  <fullquery name="logger::project::delete.delete_project">
    <querytext>
        begin
          logger_project.del(:project_id);
        end;
    </querytext>
  </fullquery>
 
  <fullquery name="logger::project::users_get_options.select_project_leads">
    <querytext>
        select acs_object.name(p.project_lead), project_lead
        from   logger_projects p,
               logger_project_pkg_map ppm
        where  ppm.project_id = p.project_id
        and    ppm.package_id = :package_id
    </querytext>
  </fullquery>

  <fullquery name="logger::project::get_current_projection.select_current_projection">
    <querytext>
        select min(p.projection_id)
        from   logger_projections p
        where  p.project_id = :project_id
        and    p.variable_id = :variable_id
        and    sysdate between p.start_time and p.end_time
    </querytext>
  </fullquery>

</queryset>
