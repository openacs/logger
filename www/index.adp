<master src="lib/master">
<property name="title">Logger Application</property>

<if @projects:rowcount@ ne 0>
  <!-- There are projects mapped to this package so we can display log entries -->

  <table cellpadding="3" cellspacing="3">
    <tr>
      <td class="logger_filter_bar">
        <!-- Left filter bar -->

        <!-- Project Section -->
        <p>
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
                    <a href="@projects.url@" title="Show log entries in project @projects.name@">@projects.name@</a>
                  </if>
                  <else>
                    @projects.name@
                  </else>
                   <a href="@projects.log_url@" title="<if @selected_variable_name@ not nil>Log @selected_variable_name@ in project @projects.name@</if><else>Add log entry in project @projects.name@</else>">+</a>
                </td>
              </tr>
            </multiple>
          </table>
        </p>
 
        <!-- Variable Section -->
        <p>
          <table border="0" cellspacing="0" cellpadding="2" width="100%">
            <tr>
              <td colspan="2">
                <p class="logger_filter_bar_section_header">
                  Variables
                </p>
              </td>
            </tr>

            <if @variables:rowcount@ ne 0>
              <multiple name="variables">
            <tr>
              <td>
                <if @selected_variable_id@ eq @variables.variable_id@>
                  <span class="logger_selected_filter">@variables.name@ (@variables.unit@)</span>
                </if>
                <else>
                  <a href="@variables.url@" title="Show log entries for variable @variables.name@">@variables.name@ (@variables.unit@)</a>
                </else>

                <if @selected_project_id@ not nil>
                  <a href="@variables.log_url@" title="Log @variables.name@ in project @selected_project_name@">+</a>
                </if>
              </td>
            </tr>
              </multiple>
            </if>
            <else>
            <tr>
              <td class="no_items_text">             
                No variables
              </td>
            </tr>
            </else>
          </table>
        </p>

        <!-- User Section -->
        <p> 
          <table border="0" cellspacing="0" cellpadding="2" width="100%">
            <tr>
              <td colspan="2">
                <p class="logger_filter_bar_section_header">
                  Users <if @selected_user_id@ not nil><a href="@all_users_url@">show all</a></if>
                </p>
              </td>
            </tr>

            <if @users:rowcount@ ne 0>
          <multiple name="users">
            <tr>
              <td>
                <if @selected_user_id@ eq @users.user_id@>
                  <span class="logger_selected_filter">@users.first_names@ @users.last_name@</span>
                </if>
                <else>
                  <a href="@users.url@" title="Show log entries by user @users.first_names@ @users.last_name@">
                  @users.first_names@ @users.last_name@</a>
                </else>                        
              </td>
            </tr>
          </multiple>
            </if>
            <else>
            <tr>
              <td class="no_items_text">             
                No users
              </td>
            </tr>
            </else>
          </table>
        </p>      

        <!-- End left filter bar -->
    </td>

    <td class="logger_body" valign="top">
      <!-- Log entries body -->

      <table width="100%">
        <tr>
          <td valign="top">
            <!-- Header showing filter selection -->
            <if @selected_project_id@ not nil>
              <span class="logger_explanation_text">Project:</span>
              <span class="logger_emphasized_text">@selected_project_name@</span>
            </if>
            <else>
              <span class="logger_explanation_text">Projects:</span>
              <span class="logger_emphasized_text">All</span>
            </else>

            <br />

            <if @selected_variable_id@ not nil>
              <span class="logger_explanation_text">Variable:</span> 
              <span class="logger_emphasized_text">@selected_variable_name@</span>

              <br />
            </if>

            <if @selected_user_id@ not nil>
              <span class="logger_explanation_text">User:</span> 
              <span class="logger_emphasized_text">@selected_user_name@</span>
            </if>
            <else>
              <span class="logger_explanation_text">Users:</span>
              <span class="logger_emphasized_text">All</span>
            </else>
          </td>
          <td valign="top">
            <formtemplate id="time_filter" style="standard-lars"></formtemplate>
          </td>
        </tr>
      </table>

      <hr />

      <include src="lib/entries-table" selected_project_id="@selected_project_id@" 
                                       selected_variable_id="@selected_variable_id@" 
                                       selected_user_id="@selected_user_id@" 
                                       start_date_ansi="@start_date_ansi@" 
                                       end_date_ansi="@end_date_plus_one_ansi@" 
                                       selected_variable_unit="@selected_variable_unit@"/>

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
