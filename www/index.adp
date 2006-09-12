<master src="/packages/logger/lib/master">
<property name="title">@instance_name@</property>

<if @num_package_projects@ eq 0>
  <p>
    #logger.lt_There_are_no_projects#
  </p>
  <if @admin_p@ true>
    <ul class="action-links">
      <li><a href="admin/">#logger.lt_Setup_logger_projects#</a></li>
    </ul>
  </if>
</if>
<else>
  <if @show_tasks_p@ eq 1>
      <include src="/packages/logger/lib/entries" 
      &="entry_id"
      &="variable_id"
      &="project_id"
      &="project_ids"
      &="user_id"
      &="time_stamp"
      &="start_date"
      &="end_date"
      &="projection_id"
      &="groupby"
      &="orderby"
      &="format"
      &="page"
      &="return_url"
      &="project_manager_url"
      &="show_tasks_p"
      &="description_f"
      &="project_status" project_ids=@project_ids@>
  </if>
  <else>
      <include src="/packages/logger/lib/entries" 
      &="entry_id"
      &="variable_id"
      &="project_id"
      &="project_ids"
      &="user_id"
      &="time_stamp"
      &="start_date"
      &="end_date"
      &="projection_id"
      &="groupby"
      &="orderby"
      &="format"
      &="page"
      &="return_url"
      &="show_tasks_p"
      &="description_f"
      &="project_status"  project_ids=@project_ids@>
  </else>
</else>

