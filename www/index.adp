<master src="/packages/logger/lib/master">
<property name="title">@instance_name@</property>
<if @passed_project_id@ ne 0>
    <property name="project_id">@passed_project_id@</property>
</if>
<if @num_package_projects@ eq 0>
  <p>
    There are no projects in this instance of logger.
  </p>
  <if @admin_p@ true>
    <ul class="action-links">
      <li><a href="admin/">Setup logger projects now</a></li>
    </ul>
  </if>
</if>
<else>
  <if @show_tasks_p@ eq 1>
      <include src="/packages/logger/lib/entries" 
      &="entry_id"
      &="variable_id"
      &="project_id"
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
      &="show_tasks_p">
  </if>
  <else>
      <include src="/packages/logger/lib/entries" 
      &="entry_id"
      &="variable_id"
      &="project_id"
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
      &="show_tasks_p">
  </else>
</else>
