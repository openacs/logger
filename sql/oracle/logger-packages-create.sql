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

create or replace package logger_measurement
as
  function new (
        measurement_id      in logger_measurements.measurement_id%TYPE default null,
        project_id          in logger_measurements.project_id%TYPE,
        variable_id         in logger_measurements.variable_id%TYPE,
        value               in logger_measurements.value%TYPE,
        time_stamp          in logger_measurements.time_stamp%TYPE,
        description         in logger_measurements.description%TYPE default null,
        creation_user       in acs_objects.creation_user%TYPE,
        creation_ip         in acs_objects.creation_ip%TYPE default null
  ) return integer;

  procedure delete (
        measurement_id      in integer
  );

  function name (
      measurement_id        in integer
   ) return varchar2;

end logger_measurement;
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
        -- Delete all measurements in the project
        for rec in (select measurement_id
                    from logger_measurements
                    where project_id = logger_project.delete.project_id
                   )
        loop
          logger_measurement.delete(rec.measurement_id);
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

create or replace package body logger_measurement
as
  function new (
        measurement_id      in logger_measurements.measurement_id%TYPE default null,
        project_id          in logger_measurements.project_id%TYPE,
        variable_id         in logger_measurements.variable_id%TYPE,
        value               in logger_measurements.value%TYPE,
        time_stamp          in logger_measurements.time_stamp%TYPE,
        description         in logger_measurements.description%TYPE default null,
        creation_user       in acs_objects.creation_user%TYPE,
        creation_ip         in acs_objects.creation_ip%TYPE default null
  ) return integer
  is
        v_measurement_id               integer;
  begin
        v_measurement_id := acs_object.new(
            object_id   => measurement_id,
            object_type => 'logger_measurement',
            context_id  => project_id,
            creation_ip => creation_ip,
            creation_user => creation_user
        );
       
       insert into logger_measurements (measurement_id, project_id, variable_id, value, 
                                        time_stamp, description)
           values (v_measurement_id, project_id, variable_id, value, time_stamp, description);

       return v_measurement_id;  

  end new;

  procedure delete (
        measurement_id      in integer
  )
  is
  begin
        -- The row in the measurements table will cascade
        acs_object.delete(measurement_id);
  end delete;

  function name (
      measurement_id        in integer
   ) return varchar2
  is
      v_name          logger_projects.name%TYPE;  
  begin
        -- TODO: Should we only return the say 20 first characters here?
        select description into v_name
        from logger_measurements
        where measurement_id = logger_measurement.name.measurement_id;

        return v_name;
  end name;

end logger_measurement;
/
show errors;
