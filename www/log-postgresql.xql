<?xml version="1.0"?>

<queryset>

  <rdbms><type>postgresql</type><version>7.2</version></rdbms>

  <fullquery name="get_task_values">
    <querytext>
        SELECT
        title as task_title, 
        case when percent_complete is null then 0 
        else percent_complete end as percent_complete, 
        estimated_hours_work,
        estimated_hours_work_min,
        estimated_hours_work_max,
        s.description as status_description
        FROM
        pm_tasks_revisionsx p,
        cr_items i,
        pm_task_status s,
        pm_tasks t
        WHERE i.item_id = p.item_id and
        p.item_id = :pm_task_id and 
        i.item_id = t.task_id and
        t.status  = s.status_id and 
        p.revision_id = i.live_revision
    </querytext>
  </fullquery>
  
</queryset>
