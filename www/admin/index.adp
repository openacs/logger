<master src="../lib/master">
<property name="title">@page_title@</property>

<div class="logger_body">
<h2 class="logger">Projects</h2>

<if @projects:rowcount@ ne 0>
  <% # Project table header %>

  <table class="logger_listing" cellpadding="4" cellspacing="1">
    <tr class="logger_listing_header">
      <th class="logger_listing_narrow">&nbsp;</th>
      <th class="logger_listing">Project Name</th>
      <th class="logger_listing">Active</th>
      <th class="logger_listing">Project Lead</th>
      <th class="logger_listing_narrow">Permissions</th>
      <th class="logger_listing_narrow">&nbsp;</th>
    </tr>

  <% # Project table rows %>
  <multiple name="projects">
    <if @projects.rownum@ odd>
      <tr class="logger_listing_odd">
    </if>
    <else>
      <tr class="logger_listing_even">
    </else>
      <td class="logger_listing_narrow">
        <a href="project?project_id=@projects.project_id@" title="Edit project attributes"><img src="/shared/images/Edit16.gif" height="16" width="16" alt="Edit" border="0"></a>
      </td>
      <td class="logger_listing">
        <a href="project?project_id=@projects.project_id@" title="Edit project attributes">@projects.name@</a>
      </td>
      <td class="logger_listing"><if @projects.active_p@ eq t>Yes</if><else>No</else> </td>
      <td class="logger_listing"><a href="@home_url@?user_id=@projects.project_lead_id@">@projects.project_lead_name@</a></td>
      <td class="logger_listing_narrow" align="center">
        <if @projects.admin_p@>
          <a href="@projects.permissions_url@" title="Set permissions for this project">Set</a>
        </if>
      </td>
      <td class="logger_listing_narrow">
        <if @projects.admin_p@>
          <a href="project-delete?project_id=@projects.project_id@" title="Delete this project"
          onclick="return confirm('Are you sure you want to delete project @projects.name@?');"><img src="/shared/images/Delete16.gif" height="16" width="16" alt="Delete" border="0"></a>
        </if>
      </td>
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
  <b>&raquo;</b> <a href="project">Add project</a>
</p>

<h2 class="logger">Variables</h2>

<if @variables:rowcount@ ne 0>
  <table class="logger_listing" cellpadding="4" cellspacing="1">
    <tr class="logger_listing_header">
      <th class="logger_listing_narrow">&nbsp;</th>
      <th class="logger_listing">Name</th>
      <th class="logger_listing">Unit</th>
      <th class="logger_listing">Additive</th>
      <th class="logger_listing_narrow">Permissions</th>
      <th class="logger_listing_narrow">&nbsp;</th>
    </tr>

  <multiple name="variables">
    <if @variables.rownum@ odd>
      <tr class="logger_listing_odd">
    </if>
    <else>
      <tr class="logger_listing_even">
    </else>
      <td class="logger_listing_narrow">
        <a href="variable?variable_id=@variables.variable_id@" title="Edit variable"><img src="/shared/images/Edit16.gif" height="16" width="16" alt="Edit" border="0"></a>
      </td>
      <td class="logger_listing"><a href="variable?variable_id=@variables.variable_id@">@variables.name@</a></td>
      <td class="logger_listing">@variables.unit@</td>
      <td class="logger_listing"><if @variables.type@ eq additive>Yes</if><else>No</else></td>
      <td class="logger_listing_narrow" align="center">
        <if @variables.admin_p@>
          <a href="@variables.permissions_url@">Set</a>
        </if> 
      <td class="logger_listing_narrow">
        <if @variables.admin_p@>
          <a href="variable-delete?variable_id=@variables.variable_id@" 
          onclick="return confirm('Are you sure you want to delete variable @variables.name@?');"
          title="Delete variable"><img src="/shared/images/Delete16.gif" height="16" width="16" alt="Delete" border="0"></a>
        </if> 
      </td>
    </tr>
  </multiple>

  </table>    
</if>
<else>
  <!-- There are no variables -->
  <span class="no_items_text">There are no variables</span>
</else>

<p>
  <b>&raquo;</b> <a href="variable">Add variable</a>
</p>

<h2 class="logger">Package</h2>
<p>
  <b>&raquo;</b> <a href="@package_permissions_url@">Set permissions for this package</a>
</p>
</div>
