-- Drop non-procedural data model of the Logger application.
-- NOTE: In general it is not a good idea to source sql drop scripts 
-- from the command line since such scripts may assume that any data in package instances
-- has already been dropped by the APM through the before-uninstantiate callback.
-- Use the /acs-admin/apm UI instead to delete packages.
-- 
-- @author Lars Pind (lars@collaboraid.biz)
-- @author Peter Marklund (peter@collaboraid.biz)
-- @creation-date 3:d of April 2003

drop table logger_entries;

begin
    acs_object_type.drop_type (
	'logger_entry'
    );
end;
/
show errors

drop table logger_projections;

drop sequence logger_projections_seq;

drop table logger_project_var_map;

drop table logger_variables;

begin
    acs_object_type.drop_type (
	'logger_variable'
    );
end;
/
show errors

drop table logger_project_pkg_map;

drop table logger_projects;

begin
    acs_object_type.drop_type (
	'logger_project'
    );
end;
/
show errors
