<master src="../lib/master">
<property name="title">@page_title;noquote@</property>

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
        <th class="logger_listing_narrow">Unlink</th>
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
          <a href="@projects.edit_url@" title="Edit project attributes"><img src="/shared/images/Edit16.gif" height="16" width="16" alt="Edit" border="0"></a>
        </td>
        <td class="logger_listing">
          <a href="@projects.display_url@" title="Display project info">@projects.name@</a>
        </td>
        <td class="logger_listing"><if @projects.active_p@ eq t>Yes (<a href="@projects.make_inactive_url@" title="Make this project inactive">toggle</a>)</if><else>No (<a href="@projects.make_active_url@" title="Make this project active">toggle</a>)</else> </td>
        <td class="logger_listing">@projects.project_lead_chunk@</td>
        <td class="logger_listing_narrow" align="center">
          <if @projects.admin_p@>
            <a href="@projects.permissions_url@" title="Set permissions for this project">Set</a>
          </if>
        </td>
        <td class="logger_listing_narrow">
          <a href="@projects.unmap_url@">Unlink</a>
        </td>
        <td class="logger_listing_narrow">
          <if @projects.admin_p@>
            <a href="@projects.delete_url@" title="Delete this project"
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
    <b>&raquo;</b> <a href="project">Create new project</a>
  </p>

  <if @mappable_projects:rowcount@ gt 0>
    <p>
      Projects not in this logger application instance which can be linked in:
    </p>
    <table class="logger_listing" cellpadding="4" cellspacing="1">
      <tr class="logger_listing_header">
        <th class="logger_listing_narrow">Name</th>
        <th class="logger_listing_narrow">Link to instance</th>
      </tr>

      <multiple name="mappable_projects">
        <if @mappable_projects.rownum@ odd>
          <tr class="logger_listing_odd">
        </if>
        <else>
          <tr class="logger_listing_even">
        </else>
          <td class="logger_listing">
            @mappable_projects.name@
          </td>
          <td class="logger_listing_narrow" align="center">
            <a href="@mappable_projects.map_url@">Link</a>
          </td>
        </tr>
      </multiple>
    </table>

  </if>  

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
          <a href="@variables.edit_url@" title="Edit variable"><img src="/shared/images/Edit16.gif" height="16" width="16" alt="Edit" border="0"></a>
        </td>
        <td class="logger_listing"><a href="@variables.edit_url@">@variables.name@</a></td>
        <td class="logger_listing">@variables.unit@</td>
        <td class="logger_listing"><if @variables.type@ eq additive>Yes</if><else>No</else></td>
        <td class="logger_listing_narrow" align="center">
          <if @variables.admin_p@>
            <a href="@variables.permissions_url@">Set</a>
          </if> 
        <td class="logger_listing_narrow">
          <if @variables.admin_p@>
            <a href="@variables.delete_url@" 
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

  <h2 class="logger">Logger Application Instance</h2>

  <p>
    <b>&raquo;</b> <a href="@package_permissions_url@">Set permissions for this logger application instance</a>
  </p>

  <h2 class="logger">Help</h2>

  <p class="logger_font">
    The logger can track a number of <b>variables</b> in different <b>projects</b>.
  </p>

  <p class="logger_font">
    A <b>variable</b> is something you wish to track, for example:
  </p>

  <ul class="logger_font">
    <li>
      Time spent (hours)
    </li>
    <li>
      Expenses (currency, USD, EUR, whatever)
    </li>
    <li>
      Weight of goods shipped (lbs, kgs)
    </li>
    <li>
      Your personal weight (lbs, kgs). Non-additive.
    </li>
  </ul>

  <p class="logger_font">
    Variables are <b>shared between all projects</b>, so that you can
    summarize the variable across projects. However, if you have many
    diverse projects going on, only certain variables will make sense
    for any given project, hence we let you <b>map variables to
    projects</b>.
  </p>

  <p class="logger_font">
    Some variables will be <b>additive</b>, meaning that it makes
    sense to add them together and look at the total. An example of an
    additive variable is time spent. Others are <b>non-additive</b>,
    which means the opposite. Instead, you would typically average
    over them. An example is measuring your personal weight, or the
    account balance of your bank account. It doesn't make sense to add
    those numbers together, they're snapshots at a given point in
    time, and just because you check your account balance 10 times a
    day doesn't (necessarily) mean you're getting richer and richer.
  </p>
  
  <p class="logger_font">
  
  </p>
  
  <p class="logger_font">
  
  </p>
  
  <p class="logger_font">
  
  </p>
  

  <p class="logger_font">
    You can mount multiple <b>instances of the logger
    application</b>. The projects you define are shared between all
    logger application instances, subject to the permissions you grant
    on them. Each instance of logger will be setup to display a
    certain subset of the projects available, as defined by the
    administrator of that instance.
  </p>

  <p class="logger_font">
    An example of why this is useful is if you work for a company,
    which works on many different projects for different clients. In
    that scenario, you would mount a logger instance in your intranet,
    where people log the hours they spend on projects. Then if you
    want to give your clients access to your logs, you can mount an
    instance per client in the client's extranet area. These client
    loggers would only have access to the projects that pertain to the
    given client.
  </p>

</div>

