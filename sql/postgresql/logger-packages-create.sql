--
-- Postgresql packages for the Logger application
--
-- @author Lars Pind (lars@collaboraid.biz)
-- @author Peter Marklund (peter@collaboraid.biz)
-- @author Postgresql porting by Dirk Gomez (openacs@dirkgomez.de)
-- @creation-date 2003-05-07

-----------
--
-- Projects
--
-----------

create or replace function logger_project__new (integer, 
                                                varchar, 
                                                varchar, 
                                                integer, 
                                                integer, 
                                                varchar, 
                                                integer) 
returns integer as '
declare
    p_project_id          alias for $1;
    p_name                alias for $2;
    p_description         alias for $3;
    p_project_lead        alias for $4;
    p_creation_user       alias for $5;
    p_creation_ip         alias for $6;
    p_package_id          alias for $7;

    v_project_id          integer;
begin
       select acs_object__new(
           p_project_id,             -- object_id
           ''logger_project'',           -- object_type
           current_timestamp,      -- creation_date
           p_creation_user,        -- creation_user
           p_creation_ip,          -- creation_ip
           p_package_id,           -- context_id
           ''t''                   -- security_inherit_p
       ) into v_project_id;
       
       insert into logger_projects (project_id, name, description, project_lead)
           values (v_project_id, p_name, p_description, p_project_lead);

       insert into logger_project_pkg_map (project_id, package_id)
                values (v_project_id, p_package_id);

       return v_project_id;  
end; ' language 'plpgsql';

create or replace function logger_project__del (integer) 
returns integer as '
declare
    p_project_id          alias for $1;

    v_rec                 record;
begin
        -- Delete all entries in the project
        for v_rec in select entry_id
                      from logger_entries
                      where project_id = p_project_id                     
        loop
          perform logger_entry__del(v_rec.entry_id);
        end loop;        

        -- Delete all variables only mapped to this project that are not preinstalled (time, expenses)
        for v_rec in select variable_id
                      from  logger_variables
                      where package_id is not null
                      and   exists (select 1
                                    from logger_project_pkg_map
                                    where project_id = p_project_id
                                   )
                      and   not exists (select 1 
                                        from logger_project_pkg_map 
                                        where project_id <> p_project_id
                                       )
        loop
            perform logger_variable__del(v_rec.variable_id);
        end loop;                                 

        -- Delete the project acs object. This will cascade the row in the logger_projects table
        -- as well as all projections in the project
        -- acs_object__delete should delete permissions for us but this change is not on cvs head yet
        delete from acs_permissions where object_id = p_project_id;
        perform acs_object__delete(p_project_id);

        return 0;
end; ' language 'plpgsql';

create or replace function logger_project__name (integer) 
returns varchar as '
declare
      p_project_id      alias for $1;

      v_name            varchar;
begin
      select name
      into   v_name
      from   logger_projects
      where  project_id = p_project_id;

      return v_name;
end; ' language 'plpgsql';

-----------
--
-- Variables
--
-----------

create or replace function logger_variable__new(integer,
                                                varchar,
                                                varchar,
                                                varchar,
                                                integer,
                                                varchar,
                                                integer)
returns integer as '
declare
        p_variable_id      alias for $1;
        p_name             alias for $2;
        p_unit             alias for $3;
        p_type             alias for $4;
        p_creation_user    alias for $5;
        p_creation_ip      alias for $6;
        p_package_id       alias for $7;

        v_variable_id      integer;
begin
       v_variable_id := acs_object__new(
           p_variable_id,             -- object_id
           ''logger_variable'',           -- object_type
           current_timestamp,      -- creation_date
           p_creation_user,        -- creation_user
           p_creation_ip,          -- creation_ip
           p_package_id,           -- context_id
           ''t''                   -- security_inherit_p
       ); 

       insert into logger_variables (variable_id, name, unit, type, package_id)
           values (v_variable_id, p_name, p_unit, p_type, p_package_id);

       return v_variable_id;  
end; ' language 'plpgsql';

create or replace function logger_variable__del (integer) 
returns integer as '
declare
        p_variable_id      alias for $1;
begin
        -- Everything should be set up to cascade
        -- acs_object__delete should delete permissions for us but this change is not on cvs head yet
        delete from acs_permissions where object_id = p_variable_id;
        perform acs_object__delete(p_variable_id);

        return 0;
end; ' language 'plpgsql';

create or replace function logger_variable__name (integer) 
returns varchar as '
declare
      p_variable_id      alias for $1;

      v_name          varchar;  
begin
      select description into v_name
      from logger_entries
      where variable_id = p_variable_id;

      return v_name;
end; ' language 'plpgsql';

-----------
--
-- Entries
--
-----------

create or replace function logger_entry__new (integer, 
                                              integer, 
                                              integer, 
                                              real, 
                                              timestamptz,
                                              varchar, 
                                              integer, 
                                              varchar) 
returns integer as '
declare
        p_entry_id            alias for $1;
        p_project_id          alias for $2;
        p_variable_id         alias for $3;
        p_value               alias for $4;
        p_time_stamp          alias for $5;
        p_description         alias for $6;
        p_creation_user       alias for $7;
        p_creation_ip         alias for $8;

        v_entry_id            integer;
begin

    v_entry_id := acs_object__new(
        p_entry_id,             -- object_id
        ''logger_entry'',       -- object_type
        current_timestamp,      -- creation_date
        p_creation_user,        -- creation_user
        p_creation_ip,          -- creation_ip
        p_project_id,           -- context_id
        ''t''                   -- security_inherit_p
    ); 
    
    insert into logger_entries (entry_id, 
                                project_id, 
                                variable_id, 
                                value, 
                                time_stamp, 
                                description)
                        values (v_entry_id, 
                                p_project_id, 
                                p_variable_id, 
                                p_value, 
                                p_time_stamp, 
                                p_description);

    return v_entry_id;  
end; ' language 'plpgsql';

create or replace function logger_entry__del (integer) 
returns integer as '
declare
        p_entry_id      alias for $1;
begin
        -- The row in the entries table will cascade
        -- acs_object__delete should delete permissions for us but this change is not on cvs head yet
        delete from acs_permissions where object_id = p_entry_id;
        perform acs_object__delete(p_entry_id);

        return 0;
end; ' language 'plpgsql';

create or replace function logger_entry__name (integer) 
returns varchar as '
declare
      p_entry_id      alias for $1;

      v_name          varchar;  
begin
      select description into v_name
      from logger_entries
      where entry_id = p_entry_id;

      return v_name;
end; ' language 'plpgsql';
