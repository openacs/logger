<?xml version="1.0"?>

<queryset>

  <fullquery name="select_variable">
    <querytext>
	  select name,
	         unit,
	         type
	  from logger_variables
	  where variable_id = :variable_id    
    </querytext>
  </fullquery>

</queryset>
