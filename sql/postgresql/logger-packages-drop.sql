--
-- Drop script for Oracle PL/SQL packages in the Logger application
--
-- @author Lars Pind (lars@collaboraid.biz)
-- @author Peter Marklund (peter@collaboraid.biz)
-- @creation-date 2003-03-28

drop function logger_project__new (integer, varchar, varchar, integer, integer, varchar, integer) ;
drop function logger_project__delete (integer) ;
drop function logger_project__name (integer) ;
drop function logger_entry__new (integer, integer, integer, integer, date, varchar, integer, varchar, integer) ;
drop function logger_entry__delete (integer) ;
drop function logger_entry__name (integer) ;
