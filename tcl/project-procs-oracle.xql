<?xml version="1.0"?>

<queryset>
  <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

  <fullquery name="logger::project::new.insert_project">
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
          logger_project.delete(:project_id);
        end;
    </querytext>
  </fullquery>
 
</queryset>
