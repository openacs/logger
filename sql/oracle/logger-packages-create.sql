--
-- Oracle PL/SQL packages for the Logger application
--
-- @author Lars Pind (lars@collaboraid.biz)
-- @author Peter Marklund (peter@collaboraid.biz)
-- @creation-date 2003-04-03

------------------------------------
-- Package definititions
------------------------------------

create or replace package logger_project
as
  function new (
        project_id      in integer default null,
        name            in logger_projects.name%TYPE,
        description     in logger_projects.description%TYPE default null,
        project_lead    in integer,
        creation_user   in acs_objects.creation_user%TYPE,
        creation_ip     in acs_objects.creation_ip%TYPE default null,
        package_id      in apm_packages.package_id%TYPE
  ) return integer;

  procedure del (
        project_id      in integer
  );

  function name (
      project_id        in integer
   ) return varchar2;

end logger_project;
/
show errors;

create or replace package logger_variable
as
  function new (
        variable_id      in integer default null,
        name             in logger_variables.name%TYPE,
        unit             in logger_variables.unit%TYPE,
        type             in logger_variables.type%TYPE,
        creation_user    in acs_objects.creation_user%TYPE,
        creation_ip      in acs_objects.creation_ip%TYPE default null,
        package_id       in apm_packages.package_id%TYPE
  ) return integer;

  procedure del (
        variable_id      in integer
  );

  function name (
      variable_id        in integer
   ) return varchar2;

end logger_variable;
/
show errors;

create or replace package logger_entry
as
  function new (
        entry_id      in logger_entries.entry_id%TYPE default null,
        project_id          in logger_entries.project_id%TYPE,
        variable_id         in logger_entries.variable_id%TYPE,
        value               in logger_entries.value%TYPE,
        time_stamp          in logger_entries.time_stamp%TYPE,
        description         in logger_entries.description%TYPE default null,
        creation_user       in acs_objects.creation_user%TYPE,
        creation_ip         in acs_objects.creation_ip%TYPE default null
  ) return integer;

  procedure del (
        entry_id      in integer
  );

  function name (
      entry_id        in integer
   ) return varchar2;

end logger_entry;
/
show errors;

------------------------------------
-- Package body implementations
------------------------------------

create or replace package body logger_project
as
  function new (
        project_id      in integer default null,
        name            in logger_projects.name%TYPE,
        description     in logger_projects.description%TYPE default null,
        project_lead    in integer,
        creation_user   in acs_objects.creation_user%TYPE,
        creation_ip     in acs_objects.creation_ip%TYPE default null,
        package_id      in apm_packages.package_id%TYPE
  ) return integer
  is
        v_project_id               integer;
  begin
        v_project_id := acs_object.new(
            object_id   => project_id,
            object_type => 'logger_project',
            context_id  => package_id,
            creation_ip => creation_ip,
            creation_user => creation_user
        );
       
       insert into logger_projects (project_id, name, description, project_lead)
           values (v_project_id, name, description, project_lead);

       insert into logger_project_pkg_map (project_id, package_id)
                values (v_project_id, logger_project.new.package_id);

       return v_project_id;  
  end new;

  procedure del (
        project_id      in integer
  )
  is
  begin
        -- Delete all entries in the project
        for rec in (select entry_id
                    from logger_entries
                    where project_id = logger_project.del.project_id
                   )
        loop
          logger_entry.del(rec.entry_id);
        end loop;        

        -- Delete all variables only mapped to this project that are not preinstalled (time, expenses)
        for rec in (select variable_id
                   from    logger_variables
                   where   package_id is not null
                   and     exists (select 1
                                   from logger_project_pkg_map
                                   where project_id = logger_project.del.project_id
                                  )
                   and     not exists (select 1 
                                       from logger_project_pkg_map 
                                       where project_id <> logger_project.del.project_id
                                      )
                   )
        loop
            logger_variable.del(rec.variable_id);
        end loop;                                 

        -- Delete the project acs object. This will cascade the row in the logger_projects table
        -- as well as all projections in the project
        -- acs_object.delete should delete permissions for us but this change is not on cvs head yet
        delete from acs_permissions where object_id = project_id;
        acs_object.del(project_id);

  end del;

  function name (
      project_id        in integer
  ) return varchar2
  is
      v_name          logger_projects.name%TYPE;
  begin
      select name
      into   v_name
      from   logger_projects
      where  project_id = name.project_id;

      return v_name;
  end name;

end logger_project;
/
show errors;

create or replace package body logger_variable
as
  function new (
        variable_id      in integer default null,
        name             in logger_variables.name%TYPE,
        unit             in logger_variables.unit%TYPE,
        type             in logger_variables.type%TYPE,
        creation_user    in acs_objects.creation_user%TYPE,
        creation_ip      in acs_objects.creation_ip%TYPE default null,
        package_id       in apm_packages.package_id%TYPE
  ) return integer
  is
        v_variable_id               integer;
  begin
        v_variable_id := acs_object.new(
            object_id   => variable_id,
            object_type => 'logger_variable',
            context_id  => package_id,
            creation_ip => creation_ip,
            creation_user => creation_user
        );
       
       insert into logger_variables (variable_id, name, unit, type, package_id)
           values (v_variable_id, name, unit, type, package_id);

       return v_variable_id;  
  end new;

  procedure del (
        variable_id      in integer
  )
  is
  begin
        -- Everything should be set up to cascade
        -- acs_object.delete should delete permissions for us but this change is not on cvs head yet
        delete from acs_permissions where object_id = variable_id;
        acs_object.del(variable_id);
  end del;

  function name (
      variable_id        in integer
   ) return varchar2
  is
      v_name          logger_projects.name%TYPE;
  begin
      select name
      into   v_name
      from   logger_variables
      where  variable_id = name.variable_id;

      return v_name;
  end name;

end logger_variable;
/
show errors;

create or replace package body logger_entry
as
  function new (
        entry_id      in logger_entries.entry_id%TYPE default null,
        project_id          in logger_entries.project_id%TYPE,
        variable_id         in logger_entries.variable_id%TYPE,
        value               in logger_entries.value%TYPE,
        time_stamp          in logger_entries.time_stamp%TYPE,
        description         in logger_entries.description%TYPE default null,
        creation_user       in acs_objects.creation_user%TYPE,
        creation_ip         in acs_objects.creation_ip%TYPE default null
  ) return integer
  is
        v_entry_id               integer;
  begin
        v_entry_id := acs_object.new(
            object_id   => entry_id,
            object_type => 'logger_entry',
            context_id  => project_id,
            creation_ip => creation_ip,
            creation_user => creation_user
        );
       
       insert into logger_entries (entry_id, project_id, variable_id, value, 
                                        time_stamp, description)
           values (v_entry_id, project_id, variable_id, value, time_stamp, description);

       return v_entry_id;  

  end new;

  procedure del (
        entry_id      in integer
  )
  is
  begin
        -- The row in the entries table will cascade
        -- acs_object.delete should delete permissions for us but this change is not on cvs head yet
        delete from acs_permissions where object_id = entry_id;
        acs_object.del(entry_id);
  end del;

  function name (
      entry_id        in integer
   ) return varchar2
  is
      v_name          logger_projects.name%TYPE;  
  begin
        -- TODO: Should we only return the say 20 first characters here?
        select description into v_name
        from logger_entries
        where entry_id = logger_entry.name.entry_id;

        return v_name;
  end name;

end logger_entry;
/
show errors;
