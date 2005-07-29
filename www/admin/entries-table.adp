<!-- Log entries table start -->

<if @entries:rowcount@ eq 0>
  <span class="no_items_text">#logger.lt_There_are_no_matching#</span>
</if>
<else>
  <table class="logger_table" cellpadding="4" cellspacing="1">
    <tr class="logger_table_header">
      <th>&nbsp;</th>
    <if @selected_project_id@ nil>
      <th>#logger.Project#</th>  
    </if>
    <if @selected_user_id@ nil>
      <th>#logger.User#</th>  
    </if>        
      <th>#logger.Date#</th>
      <th>#logger.Variable#</th>
      <th>#logger.Value#</th>
      <th>#logger.Description#</th>
    </tr>
  <multiple name="entries">
    <tr class="logger_table_rows">
      <td>@entries.action_links@</td>
    <if @selected_project_id@ nil>
      <td>@entries.project_name@</td>
    </if>
    <if @selected_user_id@ nil>
      <td>@entries.user_name@</td>
    </if>
      <td align="center">@entries.time_stamp@</td>
      <td align="center">@entries.variable_name@</td>
      <td align="right">@entries.value@ @entries.unit@</td>
      <td>@entries.description@</td>
    </tr>
  </multiple>

    <!-- Row for the grand total -->
    <tr class="logger_table_rows">
      <td class="logger_emphasized_text">#logger.Total#</td>
    <if @selected_project_id@ nil>
      <td>&nbsp;</td>
    </if>
    <if @selected_user_id@ nil>
      <td>&nbsp;</td>
    </if>
      <td align="center">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td align="right" class="logger_emphasized_text">@value_total@ @selected_variable_unit@</td>
      <td>&nbsp;</td>
    </tr>

    <!-- Row for projected value -->
  <if @projection_value@ not nil>
    <tr class="logger_table_rows">
      <td class="logger_emphasized_text">#logger.Projection#</td>
    <if @selected_project_id@ nil>
      <td>&nbsp;</td>
    </if>
    <if @selected_user_id@ nil>
      <td>&nbsp;</td>
    </if>
      <td align="center">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td align="right" class="logger_emphasized_text">@projection_value@ @selected_variable_unit@</td>
      <td>&nbsp;</td>
    </tr>
  </if>

  </table>
</else>

<!-- Log entries table end -->

