<?xml version="1.0"?>

<queryset>
  <rdbms><type>postgresql</type><version>7.1</version></rdbms>

  <fullquery name="logger::project::new.insert_project">
    <querytext>
      begin
        select  logger_project__new (
                :project_id,
                :name,
                :description,
                :project_lead,
                :creation_user,
                :creation_ip,
                :package_id               
              );
      end;
    </querytext>
  </fullquery>

  <fullquery name="logger::project::delete.delete_project">
    <querytext>
        begin
          select logger_project__delete(:project_id);
        end;
    </querytext>
  </fullquery>
 
</queryset>
