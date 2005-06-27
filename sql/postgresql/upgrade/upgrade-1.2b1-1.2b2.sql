-- 
-- Create Indexes on Logger Tables
-- 
-- @author Alex Kroman <alexk@bread.com>
-- @creation-date 2005-06-24
-- @arch-tag: 19e980a1-24b0-4589-a5b8-d7c60df41b96
-- @cvs-id $Id$
--


CREATE INDEX logger_variables_package_id_inx ON logger_variables(package_id);
CREATE INDEX logger_projects_inx ON logger_projects(project_lead);
CREATE INDEX logger_projections_variable_id_inx ON logger_projections(variable_id);
CREATE INDEX logger_projections_project_id_inx ON logger_projections(project_id);
CREATE INDEX logger_project_var_map_variable_id_inx ON logger_project_var_map(variable_id);
CREATE INDEX logger_project_pkg_map_package_id_inx ON logger_project_pkg_map(package_id);
CREATE INDEX logger_entries_variable_id_inx ON logger_entries(variable_id);
CREATE INDEX logger_entries_project_id_inx ON logger_entries(project_id);
CREATE INDEX logger_entries_time_stamp_inx ON logger_entries(time_stamp);
