--
--
-- Fixed deleting projects also deleting pre-installed variables
--
-- @cvs-id $Id$
--

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

