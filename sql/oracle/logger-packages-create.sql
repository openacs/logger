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
        name            in cr_revisions.title%TYPE,
        description     in cr_revisions.description%TYPE default null,
        project_lead    in integer,
        creation_user   in acs_objects.creation_user%TYPE,
        creation_ip     in acs_objects.creation_ip%TYPE default null,
        package_id      in apm_packages.package_id%TYPE
  ) return integer;

  procedure delete (
        project_id      in integer
  );

  function name (
      project_id        in integer
   ) return varchar2;

end logger_project;
/
show errors;

------------------------------------
-- Package body implementations
------------------------------------

create or replace package body logger_project
as
  function new (
        project_id      in integer default null,
        name            in cr_revisions.title%TYPE,
        description     in cr_revisions.description%TYPE default null,
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

  procedure delete (
        project_id      in integer
  )
  is
  begin
        -- Delete all variables only mapped to this project. This will cascade
        -- referencing measurements
        for rec in (select variable_id
                   from logger_variables
                   where exists (select 1
                                 from logger_project_pkg_map
                                 where project_id = logger_project.delete.project_id
                                )
                   and not exists (select 1 
                                   from logger_project_pkg_map 
                                   where project_id <> logger_project.delete.project_id
                                  )
                   )
        loop
            delete from logger_variables where variable_id = rec.variable_id;
        end loop;                                 

        -- Delete the project acs object. This will cascade the row in the logger_projects table
        -- as well as all remaining measurements and projections in the project
        acs_object.delete(project_id);

  end delete;

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
