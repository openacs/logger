<?xml version="1.0"?>

<queryset>
  <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

  <fullquery name="logger::variable::new.insert_variable">
    <querytext>
      begin
        :1 := logger_variable.new (
                variable_id => :variable_id,
                name => :name,
                unit => :unit,
                type => :type,
                creation_user => :creation_user,
                creation_ip => :creation_ip,
                package_id => :package_id               
              );
      end;
    </querytext>
  </fullquery>

  <fullquery name="logger::variable::delete.delete_variable">
    <querytext>
        begin
          logger_variable.del(:variable_id);
        end;
    </querytext>
  </fullquery>

  <fullquery name="logger::variable::get_default_variable_id.select_first_variable_id">
    <querytext>
        select q.*
        from   (select variable_id 
                from   logger_variables 
                order  by variable_id) q
        where  rownum = 1
    </querytext>
  </fullquery>

</queryset>
