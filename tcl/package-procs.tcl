ad_library {
    Procedures the logger::package namespace. Those procedures
    operate on logger package objects.

   Unlike many other -procs.tcl files in the logger package this
   file contains no ::new and ::delete procedures. The reason
   is that packages are created by the APM proc apm_package_instance_new.
   When the logger application needs extra data to be setup for package
   instances this would be done in an after-instantiate callback in
   the file apm-callback-procs.tcl.

    @creation-date 4:th of April 2003
    @author Peter Marklund (peter@collaboraid.biz)
    @cvs-id $Id$
}

namespace eval logger::package {}

ad_proc -public logger::package::projects_only_in_package {
    {-package_id:required}
} {
    Return the ids of all logger projects that are mapped to
    the given package and are not mapped to any other packages.
    These are the projects that the package owns.

    @param package_id The id of the package to return projects for

    @return A list of project_id:s. An empty list if there are no matching projects.

    @author Peter Marklund
} {
    return [db_list select_projects {}]
}

ad_proc -public logger::package::all_projects_in_package {
    {-package_id:required}
} {
    Return a list of ids for all logger projects mapped to the given package.

    @param package_id The id of the package to return projects for

    @return A list of project_id:s. An empty list if there are no matching projects.    

    @author Peter Marklund
} {
    return [db_list select_projects {}]
}

ad_proc -public logger::package::variables_multirow { 
    {-not_in_project_id ""}
} {
    Executes a db_multirow that returns all variables created
    in the current package and all variables mapped to projects
    in the current package. Also returns the default variables
    that come with the installation of the Logger - Time and Expense
    (created in no particular package instance).

    @param not_in_project_id Exclude variables already mapped to the given project_id.

    @author Peter Marklund
} {
    set package_id [ad_conn package_id]
    set user_id [ad_conn user_id]

    if { ![empty_string_p $not_in_project_id] } {
        set extra_where_clause \
        "and not exists (select 1
                         from logger_project_var_map
                         where project_id = $not_in_project_id
                         and variable_id = lv.variable_id
                         )"
    } else {
        set extra_where_clause ""
    }

    db_multirow variables select_variables {}    
}


ad_proc -public logger::package::map_project {
    -project_id:required
    {-package_id ""}
} {
    Maps a project to a package
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-05-20
    
    @param project_id

    @param package_id A package ID (must be present in the
    apm_packages table)

    @return 
    
    @error 
} {

    if {[empty_string_p $package_id]} {
        set package_id [ad_conn package_id]
    }

    permission::require_permission -object_id $project_id -privilege "read"
    
    db_dml map_project {
        insert into logger_project_pkg_map (project_id, package_id) values (:project_id, :package_id)
    }

    return 1
}


ad_proc -public logger::package::unmap_project {
    -project_id:required
    -package_id:required
} {
    Unmaps a project from a package
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-05-20
    
    @param project_id

    @param package_id

    @return 
    
    @error 
} {
    
    db_dml map_project {
        delete 
        from   logger_project_pkg_map 
        where  project_id = :project_id
        and    package_id = :package_id
    }

    return 1
}
