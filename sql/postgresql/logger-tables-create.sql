-- Oracle tables for the Logger application
-- 
-- @author Lars Pind (lars@collaboraid.biz)
-- @author Peter Marklund (peter@collaboraid.biz)
-- @creation-date 3:d of April 2003

create table logger_projects (
  project_id            integer
                        constraint logger_projects_pk
                        primary key
                        constraint logger_projects_pid_fk
                        references acs_objects(object_id)
                        on delete cascade,
  name                  varchar(1000),
  description           varchar(4000),
  active_p              char(1)
                        default 't'
                        constraint logger_projects_ap_nn
                        not null
                        constraint logger_projects_ap_ck
                        check (active_p in ('t', 'f')),
  project_lead          integer
                        constraint logger_projects_pl_nn
                        not null
                        constraint logger_projects_pl_fk
                        references users(user_id)
);
     
comment on table logger_projects is '
  Log entries are grouped by projects. Once we have a dedicated
  project management package for OpenACS this table will be superseeded by
  tables in that package. In order to make such a change easier in the future
  we are not referencing the logger_projects table directly in the logger datamodel
  but instead reference acs_objects.
';

-- By making projects acs objects we can use permissioning and also by
-- referencing acs objects we make any future transition to project objects in a
-- project management package easier.
create function inline_0 ()
returns integer as '
begin
PERFORM acs_object_type__create_type (
	''logger_project'',            -- object_type          
	''Logger project'',            -- pretty_name          
	''Logger projects'',           -- pretty_plural        
	''acs_object'',                -- supertype            
	''logger_projects'',           -- table_name           
	''project_id'',                -- id_column            
	null,                        -- package_name         
	''f'',                         -- abstract_p           
	null,                        -- type_extension_table 
	''logger_project.name''        -- name_method          
);
  return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();

-- 
create table logger_project_pkg_map (
  project_id            integer
                        constraint logger_project_pkg_map_pr_fk
                        references acs_objects(object_id)
                        on delete cascade,
  package_id            integer
                        constraint logger_project_pkg_map_pa_fk
                        references apm_packages(package_id)
                        on delete cascade,
  constraint logger_project_pkg_map_un
  unique (project_id, package_id)
);

comment on table logger_project_pkg_map is '
  Each project can be mounted in multiple package instances.
';

create table logger_variables (
  variable_id           integer
                        constraint logger_variables_pk
                        primary key,
  name                  varchar(200),
  unit                  varchar(200),
  type                  varchar(50)
                        default 'additive'
                        constraint logger_variables_type_nn
                        not null
                        constraint logger_variables_type_ck
                        check (type in ('additive', 'non-additive'))
);

comment on column logger_variables.type is '
  Indicates if measurements of this variable should be added together or not. 
  Examples of additive variables are time and money spent at different times during
  a project. A non-additive variable would be the amount of money in a bank account.
';

create sequence logger_variables_seq;

create table logger_project_var_map (
  project_id            integer
                        constraint logger_project_var_map_pid_fk
                        references acs_objects(object_id)
                        on delete cascade
                        constraint logger_project_var_map_pid_nn
                        not null,
  variable_id           integer
                        constraint logger_project_var_map_vid_fk
                        references logger_variables(variable_id)
                        on delete cascade
                        constraint logger_project_var_map_vid_nn
                        not null,
  primary_p             char(1)
                        default 't'
                        constraint logger_project_var_map_pp_nn
                        not null
                        constraint logger_project_var_map_pp_ck
                        check (primary_p in ('t', 'f')),
  constraint logger_project_var_map_un
  unique(project_id, variable_id)
);

comment on column logger_project_var_map.primary_p is '
  Every project must have a primary variable which represents what we are 
  most interested in logging and reporting in that project 
  - typically time spent on various tasks.
';

create table logger_projections (
  projection_id         integer
                        constraint logger_projections_pk
                        primary key,
  project_id            integer
                        constraint logger_projections_pid_nn
                        not null
                        constraint logger_projections_pid_fk
                        references acs_objects(object_id)
                        on delete cascade,
  variable_id           integer
                        constraint logger_projections_vid_nn
                        not null
                        constraint logger_projections_vid_fk
                        references logger_variables(variable_id)
                        on delete cascade,
  start_time            date
                        constraint logger_projections_st_nn
                        not null,
  end_time              date
                        constraint logger_projections_et_nn
                        not null,
  value                 integer
                        constraint logger_projections_value_nn
                        not null
);

comment on table logger_projections is '
  This table allows a project admin to specify expected or targeted logging values
  over a particular time period.
';

comment on column logger_projections.value is '
  For additive variables the projection value will represent the expected or targeted 
  sum of measurements during the time range and for non-additive variables it will 
  represent an average.
';

create sequence logger_projections_seq;

create table logger_measurements (
  measurement_id        integer
                        constraint logger_measurements_pk
                        primary key
                        constraint logger_measurements_mid_fk
                        references acs_objects(object_id)
                        on delete cascade,
  project_id            integer
                        constraint logger_measurements_pid_fk
                        references acs_objects(object_id)
                        on delete cascade,
  variable_id           integer
                        constraint logger_measurements_v_id_fk
                        references logger_variables(variable_id)
                        on delete cascade,
  value                 integer
                        constraint logger_measurements_value_nn
                        not null,
  time_stamp            date
                        default now ()
                        constraint logger_measurements_ts_nn
                        not null,
  description           varchar(4000)
);

comment on table logger_measurements is '
 This is the center piece of the logger datamodel that holds the actually reported
 data - namely numbers bound to points in time. Given the HR-XML
 Time and Reporting standard (see http://www.hr-xml.org) we considered allowing 
 for explicit start and end times. However, in the interest of simplicity
 for the initial release of the package we opted against this. The HR-XML spec talks
 about three categories of reports - time events, time intervals, and
 expenses incurred. Of those we are initially only supporting the latter two
 and for time intervals we don''t support any explicit start and end time (only a timestamp
 and a value). Support for those remaining HR-XML use cases can be added on later without
 much difficulty.
';

-- Measurements need to be acs objects if we are to categorize the with the categories
-- package
create function inline_0 ()
returns integer as '
begin
PERFORM  acs_object_type__create_type (
	''logger_measurement'',        -- object_type          
	''Logger measurement'',        -- pretty_name          
	''Logger measurements'',       -- pretty_plural        
	''acs_object'',                -- supertype            
	''logger_measurements'',       -- table_name           
	''measurement_id'',            -- id_column            
	null,                        -- package_name         
	''f'',                         -- abstract_p           
	null,                        -- type_extension_table 
	''logger_measurement.name''    -- name_method          
);
  return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();
