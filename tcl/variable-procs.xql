<?xml version="1.0"?>

<queryset>

  <fullquery name="logger::variable::new.insert_variable">
    <querytext>
      insert into logger_variables (variable_id, name, unit, type)
           values (:variable_id, :name, :unit, :type)
    </querytext>
  </fullquery>

  <fullquery name="logger::variable::delete.delete_variable">
    <querytext>
        delete from logger_variables
        where variable_id = :variable_id
    </querytext>
  </fullquery>

  <fullquery name="logger::variable::get.select_variable">
    <querytext>
        select variable_id,
               name,
               unit,
               type
        from logger_variables
        where variable_id = :variable_id
    </querytext>
  </fullquery>

</queryset>
