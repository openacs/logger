--
-- Drop script for Oracle PL/SQL packages in the Logger application
--
-- @author Lars Pind (lars@collaboraid.biz)
-- @author Peter Marklund (peter@collaboraid.biz)
-- @creation-date 2003-05-07

-----------
--
-- Projects
--
-----------
drop function logger_project__new (integer, varchar, varchar, integer, integer, varchar, integer) ;
drop function logger_project__del (integer) ;
drop function logger_project__name (integer) ;

-----------
--
-- Variables
--
-----------
drop function logger_variable__new(integer,
                                   varchar,
                                   varchar,
                                   varchar,
                                   integer,
                                   varchar,
                                   integer);
drop function logger_variable__del (integer);
drop function logger_variable__name (integer);

-----------
--
-- Entries
--
-----------
drop function logger_entry__new (integer, 
                                 integer, 
                                 integer, 
                                 real, 
                                 timestamptz,
                                 varchar, 
                                 integer, 
                                 varchar);
drop function logger_entry__del (integer) ;
drop function logger_entry__name (integer) ;
