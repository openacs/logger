<?xml version="1.0"?>

<queryset>

  <fullquery name="logger::variable::edit.update_variable">
    <querytext>
      update logger_variables
             set name = :name,
                 unit = :unit,
                 type = :type
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
