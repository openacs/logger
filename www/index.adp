<master src="lib/master">
<property name="title">Logger Application</property>

<if @projects:rowcount@ ne 0>

  <!-- There are projects mapped to this package so we can display log entries -->

  <table border="1" cellpadding="3" cellspacing="2" width="100%">
    <tr>
      <td>
        <!-- The left filter bar -->
        <p class="logger_filter_bar_header">
          Filter
        </p>

        <table border="0" cellspacing="0" cellpadding="2" width="100%">
          <tr>
            <td colspan="2">
              <p class="logger_filter_bar_section_header">
                Projects
              </p>
            </td>
          </tr>

          <multiple name="projects">            
            <tr>
              <td>
                <a href="@projects.url@">@projects.name@</a> <a href="log?project_id=@projects.project_id@">log</a>
              </td>
            </tr>
          </multiple>

        </table>
      </td>

      <td>
        <!-- The body of the page with log entries -->

        <if @measurements:rowcount@ eq 0>
          <i>There are no matching log entries</i>
        </if>
        <else>
          <table cellpadding="4" cellspacing="3">
            <tr>
              <th>Time</th>
              <th>Value</th>
              <th>Variable</th>
              <th>Description</th>
              <th>&nbsp;</th>
            </tr>
          <multiple name="measurements">
            <tr>
              <td align="center">@measurements.time_stamp@</td>
              <td align="center">@measurements.value@</td>
              <td align="center">@measurements.variable_name@ (@measurements.unit@)</td>
              <td>@measurements.description@</td>
              <td>[ <a href="log?measurement_id=@measurements.id@">Edit</a> ]</td>
            </tr>
          </multiple>
          </table>
        </else>

      </td>
    </tr>
  </table>
  
</if>
<else>

  <!-- There are no projects mapped to this package so no log entries can be displayed -->  

  <p>
    Before anyone can start working with the Logger application an administrator needs to setup a project.
  </p>    
  <if @admin_p@>
    <!-- User is an admin so offer him/her to map or create projects -->
    <p>    
      Since you are an administrator you may <a href="admin">visit the admin pages</a> to do so now.
    </p>
  </if>
  <else>
    <p>
      Please contact an administrator about this. Thank you.
    </p>
  </else>

</else>
