--
--
-- Fixed deleting projects also deleting pre-installed variables
--
-- @cvs-id $Id$
--

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

        -- Delete all variables only mapped to this project.
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

