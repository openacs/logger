<?xml version="1.0"?>

<queryset>
  <rdbms><type>postgresql</type><version>7.2</version></rdbms>

  <fullquery name="logger::variable::new.insert_variable">
    <querytext>
        select logger_variable__new (
                :variable_id,
                :name,
                :unit,
                :type,
                :creation_user,
                :creation_ip,
                :package_id               
              );
    </querytext>
  </fullquery>

  <fullquery name="logger::variable::delete.delete_variable">
    <querytext>
          select logger_variable__del(:variable_id);
    </querytext>
  </fullquery>
 
</queryset>
