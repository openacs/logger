-- Drop non-procedural data model of the Logger application.
--
-- NOTE: In general it is not a good idea to source sql drop scripts 
-- from the command line since such scripts may assume that any data in package instances
-- has already been dropped by the APM through the before-uninstantiate callback.
-- Use the /acs-admin/apm UI instead to delete packages.
-- 
-- @author Lars Pind (lars@collaboraid.biz)
-- @author Peter Marklund (peter@collaboraid.biz)
-- @creation-date 2003-05-07

drop table logger_entries;

create function inline_0 ()
returns integer as '
begin
    perform acs_object_type__drop_type (
        ''logger_entry'', ''f''
    );

    return null;
end;' language 'plpgsql';
select inline_0();
drop function inline_0 ();

drop table logger_projections;

drop sequence logger_projections_seq;

drop table logger_project_var_map;

drop table logger_variables;

create function inline_0 ()
returns integer as '
begin
    perform acs_object_type__drop_type (
        ''logger_variable'', ''f''
    );

    return null;
end;' language 'plpgsql';
select inline_0();
drop function inline_0 ();

drop table logger_project_pkg_map;

drop table logger_projects;

create function inline_0 ()
returns integer as '
begin
    perform acs_object_type__drop_type (
        ''logger_project'', ''f''
    );

    return null;
end;' language 'plpgsql';
select inline_0();
drop function inline_0 ();
