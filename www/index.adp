<master src="lib/master">
<property name="title">Logger Application</property>

<if @projects:rowcount@ ne 0>
  <!-- There are projects mapped to this package so we can display log entries -->

  <table cellpadding="3" cellspacing="3">
    <tr>
      <td width="25%" class="logger_filter_bar">
        <!-- Left filter bar -->

        <p class="logger_filter_bar_header">
          Filter
        </p>

        <!-- Project Section -->
        <table border="0" cellspacing="0" cellpadding="2" width="100%">
          <tr>
            <td colspan="2">
              <p class="logger_filter_bar_section_header">
                Projects <if @selected_project_id@ not nil><a href="@all_projects_url@">show all</a></if>
              </p>
            </td>
          </tr>

          <multiple name="projects">            
            <tr>
              <td>
                <if @selected_project_id@ ne @projects.project_id@>
                  <a href="@projects.url@" title="Filter by this project">@projects.name@</a>
                </if>
                <else>
                  @projects.name@
                </else>
                 <a href="@projects.log_url@" title="Add new log entry">+</a>
              </td>
            </tr>
          </multiple>
        </table>

        <!-- Variable Section -->
        <table border="0" cellspacing="0" cellpadding="2" width="100%">
          <tr>
            <td colspan="2">
              <p class="logger_filter_bar_section_header">
                Variables
              </p>
            </td>
          </tr>

          <multiple name="variables">
            <tr>
              <td>
                <if @selected_variable_id@ eq @variables.variable_id@>
                  <span class="logger_selected_filter">@variables.name@ (@variables.unit@)</span>
                </if>
                <else>
                  <a href="@variables.url@" title="Filter by this variable">@variables.name@ (@variables.unit@)</a>
                </else>

                <if @selected_project_id@ not nil>
                  <a href="@variables.log_url@" title="Log @variables.name@ in selected project">+</a>
                </if>
              </td>
            </tr>
          </multiple>
        </table>
      
        <!-- End left filter bar -->
    </td>

    <td class="logger_body" valign="top">
      <!-- Log entries body -->

      <if @selected_project_id@ not nil>
        <span class="logger_explanation_text">Project:</span>
        <span class="logger_emphasized_text">@selected_project_name@</span> <br />
      </if>
      <else>
        <span class="logger_explanation_text">Projects:</span>
        <span class="logger_emphasized_text">All</span> <br />
      </else>

      <if @selected_variable_id@ not nil>
        <span class="logger_explanation_text">Variable:</span> 
        <span class="logger_emphasized_text">@selected_variable_name@</span>
      </if>
      <hr />

      <if @entries:rowcount@ eq 0>
        <i>There are no matching log entries</i>
      </if>
      <else>
        <table class="logger_table" cellpadding="4" cellspacing="1">
          <tr class="logger_table_header">
            <th>&nbsp;</th>
          <if @selected_project_id@ nil>
            <th>Project</th>  
          </if>
            <th>Date</th>
            <th>Variable</th>
            <th>Value</th>
            <th>Description</th>
          </tr>
        <multiple name="entries">
          <tr class="logger_table_rows">
            <td>@entries.action_links@</td>
          <if @selected_project_id@ nil>
            <td>@entries.project_name@</td>
          </if>
            <td align="center">@entries.time_stamp@</td>
            <td align="center">@entries.variable_name@</td>
            <td align="right">@entries.value@ @entries.unit@</td>
            <td>@entries.description@</td>
          </tr>
        </multiple>
        </table>
      </else>

      <!-- End log entries body -->
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
