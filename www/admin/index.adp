<master src="../lib/master">
<property name="title">@page_title@</property>

<div class="logger_body">
<h2>Projects</h2>

<if @projects:rowcount@ ne 0>
  <% # Project table header %>

  <table border="1" cellpadding="4">
    <tr>
      <th>Project Name</th>
      <th>Project Description</th>
      <th>Active</th>
      <th>Project Lead</th>
    </tr>

  <% # Project table rows %>
  <multiple name="projects">
    <tr>
      <td><a href="project?project_id=@projects.project_id@">@projects.name@</a>
          <if @projects.admin_p@> [ <a href="project-delete?project_id=@projects.project_id@" 
            onclick="return confirm('Are you sure you want to delete project @projects.name@?');">Delete</a> ]
           </if> 
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
  <a href="project">Add new project</a>
</p>

<h2>Variables</h2>

<if @variables:rowcount@ ne 0>
  <table border="1" cellpadding="4">
    <tr>
      <th>Name</th>
      <th>Unit</th>
      <th>Additive</th>
    </tr>

  <multiple name="variables">
    <tr>
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
  <a href="variable">Add new variable</a>
</p>
</div>