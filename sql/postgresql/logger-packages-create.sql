--
-- Postgres packages for the Logger application
--
-- @author Lars Pind (lars@collaboraid.biz)
-- @author Peter Marklund (peter@collaboraid.biz)
-- @creation-date 2003-04-03
-- @auther Postgres Port by Dirk Gomez (openacs@dirkgomez.de)

create function logger_project__new (integer, varchar, varchar, integer, integer, varchar, integer) 
returns integer as '
declare
    project_id          alias for $1; -- default null
    name                alias for $2;
    description         alias for $3; -- default null
    project_lead        alias for $4;
    creation_user       alias for $5;
    creation_ip         alias for $6; -- default null
    package_id          alias for $7;

    v_project_id               integer;
begin
        v_project_id := acs_object__new(
            project_id,
            ''logger_project'',
            package_id,
            creation_ip,
            creation_user
        );
       
       insert into logger_projects (project_id, name, description, project_lead)
           values (v_project_id, name, description, project_lead);

       insert into logger_project_pkg_map (project_id, package_id)
                values (v_project_id, logger_project.new.package_id);

       return v_project_id;  
end; ' language 'plpgsql';

create function logger_project__delete (integer) 
returns integer as '
declare
    project_id          alias for $1;
begin
        -- Delete all entries in the project
        for rec in (select entry_id
                    from logger_entries
                    where project_id = logger_project.delete.project_id
                   )
        loop
          logger_entry.delete(rec.entry_id);
        end loop;        

        -- Delete all variables only mapped to this project.
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
        -- as well as all projections in the project
        acs_object.delete(project_id);
end; ' language 'plpgsql';

create function logger_project__name (integer) 
returns varchar as '
declare
      project_id      alias for $1;

      v_name          logger_projects.name%TYPE;
begin
      select name
      into   v_name
      from   logger_projects
      where  project_id = name.project_id;

      return v_name;
end; ' language 'plpgsql';

create function logger_entry__new (integer, integer, integer, integer, date, varchar, integer, varchar, integer) 
returns integer as '
declare
        entry_id      alias for $1;  -- default null
        project_id          alias for $2;
        variable_id         alias for $3;
        value               alias for $4;
        time_stamp          alias for $5;
        description         alias for $6; -- default null
        creation_user       alias for $7;
        creation_ip         alias for $8; -- default null

        v_entry_id               integer;
begin
        v_entry_id := acs_object__new(
            entry_id,
            ''logger_entry'',
            project_id,
            creation_ip,
            creation_user
        );
       
       insert into logger_entries (entry_id, project_id, variable_id, value, 
                                        time_stamp, description)
           values (v_entry_id, project_id, variable_id, value, time_stamp, description);

       return v_entry_id;  
end; ' language 'plpgsql';

create function logger_entry__delete (integer) 
returns integer as '
declare
        entry_id      alias for $1;  -- default null
begin
        -- The row in the entries table will cascade
        acs_object.delete(entry_id);
end; ' language 'plpgsql';

create function logger_entry__name (integer) 
returns varchar as '
declare
      v_name          logger_projects.name%TYPE;  
  begin
        -- TODO: Should we only return the say 20 first characters here?
        select description into v_name
        from logger_entries
        where entry_id = logger_entry.name.entry_id;

        return v_name;
end; ' language 'plpgsql';
