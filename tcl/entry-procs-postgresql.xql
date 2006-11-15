<?xml version="1.0"?>

<queryset>
  <rdbms><type>postgresql</type><version>7.2</version></rdbms>

  <fullquery name="logger::entry::new.insert_entry">
    <querytext>
		Begin	
		LOCK TABLE acs_objects IN SHARE ROW EXCLUSIVE MODE;
        perform logger_entry__new (
                  :entry_id,
                  :project_id,
                  :variable_id,
                  :value,
                  :time_stamp,
                  :description,
                  :creation_user,
                  :creation_ip
              );
	return 0;
	end;
    </querytext>
  </fullquery>

  <fullquery name="logger::entry::delete.delete_entry">
    <querytext>
        select logger_entry__del(:entry_id);
    </querytext>
  </fullquery>
 
  <fullquery name="logger::entry::task_id.task_id">
    <querytext>
      SELECT
      task_item_id
      FROM
      pm_task_logger_proj_map m
      WHERE
      logger_entry = :entry_id
    </querytext>
  </fullquery>

</queryset>
