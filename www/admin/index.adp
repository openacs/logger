<master src="../lib/master">
<property name="title">@page_title@</property>

<div class="logger_body">
<h2>Projects</h2>

<if @projects:rowcount@ ne 0>
  <% # Project table header %>

  <table class="logger_table" cellpadding="4" cellspacing="1">
    <tr class="logger_table_header">
      <th>&nbsp;</th>
      <th>Project Name</th>
      <th>Project Description</th>
      <th>Active</th>
      <th>Project Lead</th>
    </tr>

  <% # Project table rows %>
  <multiple name="projects">
    <tr class="logger_table_rows">
      <td>
          <if @projects.admin_p@> [ <a href="@projects.permissions_url@">permissions</a> | 
            <a href="project-delete?project_id=@projects.project_id@" 
            onclick="return confirm('Are you sure you want to delete project @projects.name@?');">delete</a> ]
          </if> 
      </td>
      <td><a href="project?project_id=@projects.project_id@">@projects.name@</a>
      </td>
      <td>@projects.description@</td>
      <td><if @projects.active_p@ eq t>yes</if><else>no</else> </td>
      <td><a href="@home_url@?user_id=@projects.project_lead_id@">@projects.project_lead_name@</a></td>
    </tr>  
  </multiple>

  <% # Close project table %>
  </table>
</if>
<else>
  <!-- No projects -->
  <span class="no_items_text">There are no projects</span>
</else>

<p>
  [ <a href="project">add new project</a> ]
</p>

<h2>Variables</h2>

<if @variables:rowcount@ ne 0>
  <table class="logger_table" cellpadding="4" cellspacing="1">
    <tr class="logger_table_header">
      <th>&nbsp;</th>
      <th>Name</th>
      <th>Unit</th>
      <th>Additive</th>
    </tr>

  <multiple name="variables">
    <tr class="logger_table_rows">
      <td>
        <if @variables.admin_p@> [ <a href="@variables.permissions_url@">permissions</a> |
          <a href="variable-delete?variable_id=@variables.variable_id@" 
          onclick="return confirm('Are you sure you want to delete variable @variables.name@?');">delete</a> ]
        </if> 
      </td>
      <td><a href="variable?variable_id=@variables.variable_id@">@variables.name@</a></td>
      <td>@variables.unit@</td>
      <td><if @variables.type@ eq additive>yes</if><else>no</else></td>
    </tr>
  </multiple>

  </table>    
</if>
<else>
  <!-- There are no variables -->
  <span class="no_items_text">There are no variables</span>
</else>

<p>
  [ <a href="variable">add new variable</a> ]
</p>

<h2>Package</h2>
<p>
  [ <a href="@package_permissions_url@">set permissions of this package</a> ]
</p>
</div>
