<master src="lib/master">
<property name="title">@instance_name@</property>

<table cellpadding="3" cellspacing="3">
  <tr>
    <td class="logger_filter_bar" valign="top" width="200">
      <!-- Left filter bar -->
      
      <multiple name="filters">
        <p style="margin-top: 0px; margin-bottom: 12px;">
          <table border="0" cellspacing="0" cellpadding="2" width="100%">
            <tr>
              <td colspan="2" class="logger_filter_header">
               @filters.filter_name@
               <if @filters.clear_url@ not nil>
                 (<a href="@filters.clear_url@" title="Clear the currently selected @filters.filter_name@">clear</a>)
               </if>
              </td>
            </tr>
            <group column="filter_name">
              <if @filters.selected_p@ true>
                <tr class="logger_filter_selected">
              </if>
              <else>
                <tr>
              </else>
                <td width="75%" class="logger_filter">
                  <if @filters.selected_p@ true><span class="logger_filter_selected">@filters.name@</span></if>
                  <else><a href="@filters.url@">@filters.name@</a></else>
                </td>
                <td align="right" class="logger_filter">
                  <if @filters.entry_add_url@ not nil>
                    <a href="@filters.entry_add_url@" title="Add entry">+</a>
                  </if>
                </td>
              </tr>
            </group>
          </table>
        </p>
      </multiple>

      <p style="margin-top: 0px; margin-bottom: 12px;">
        <table border="0" cellspacing="0" cellpadding="2" width="100%">
          <tr>
            <td class="logger_filter_header">
              Custom Date Range
            </td>
          </tr>
          <tr>
            <td class="logger_filter">
              (YYYY-MM-DD)
            </td>
          </tr>
          <tr>
            <td class="logger_filter">
              <formtemplate id="time_filter" style="tiny-plain"></formtemplate>
            </td>
          </tr>
        </table>
      </p>

      <!-- End left filter bar -->
    </td>

    <td class="logger_body" valign="top">

      <include src="lib/entries-table" selected_project_id="@selected_project_id@" 
                                       selected_variable_id="@selected_variable_id@"
                                       projection_value="@selected_projection_value@" 
                                       selected_user_id="@selected_user_id@" 
                                       start_date_ansi="@selected_start_date@" 
                                       end_date_ansi="@selected_end_date@"/>

      <!-- End log entries body -->
    </td>
  </tr>
</table>
