<!-- Log entries table start -->

<if @entries:rowcount@ eq 0>
  <span class="no_items_text">There are no matching log entries</span>
</if>
<else>
  <table class="logger_listing_tiny" cellpadding="3" cellspacing="1">
    <tr class="logger_listing_header">
      <th class="logger_listing_narrow">&nbsp;</th>
      <th class="logger_listing_narrow">Project</th>  
      <th class="logger_listing_narrow">User</th>  
      <th class="logger_listing_narrow">Date</th>
      <th class="logger_listing_narrow">@variable.name@</th>
      <th class="logger_listing_narrow">Description</th>
      <th class="logger_listing_narrow">&nbsp;</th>
    </tr>
  <multiple name="entries">
    <if @entries.selected_p@ true>
        <tr class="logger_listing_subheader">
    </if>
    <else>
      <if @entries.rownum@ odd>
        <tr class="logger_listing_odd">
      </if>
      <else>
        <tr class="logger_listing_even">
      </else>
    </else>
      <td class="logger_listing_narrow">
        <a href="@entries.edit_url@" title="Edit this log entry"><img src="/shared/images/Edit16.gif" height="16" width="16" alt="Edit" border="0"></a>
      </td>
      <td class="logger_listing_narrow">@entries.project_name@</td>
      <td class="logger_listing_narrow">@entries.user_chunk@</td>
      <td class="logger_listing_narrow" align="left">@entries.time_stamp_pretty@</td>
      <td class="logger_listing_narrow" align="right" nowrap>
        <a href="@entries.edit_url@" title="Edit this log entry">@entries.value@</a>
      </td>
      <td class="logger_listing_narrow">@entries.description@</td>
      <td class="logger_listing_narrow">
        <if @entries.delete_url@ not nil>
          <a href="@entries.delete_url@" onclick="@entries.delete_onclick@" title="Delete this log entry"><img src="/shared/images/Delete16.gif" height="16" width="16" alt="Delete" border="0"></a>
        </if>
      </td>
    </tr>
  </multiple>

    <!-- Row for the grand total -->
    <tr class="logger_listing_subheader">
      <td class="logger_listing_narrow" align="center">&nbsp;</td>
      <td class="logger_listing_narrow" colspan="3"><b>Total</b></td>
      <td class="logger_listing_narrow" align="right" nowrap><b>@value_total@</b></td>
      <td class="logger_listing_narrow">&nbsp;</td>
      <td class="logger_listing_narrow" align="center">&nbsp;</td>
    </tr>

    <!-- Row for projected value -->
  <if @projection_value@ not nil>
    <tr class="logger_listing_odd">
      <td class="logger_listing_narrow" align="center">&nbsp;</td>
      <td class="logger_listing_narrow" colspan="3"><b>Projection</b></td>
      <td class="logger_listing_narrow" align="right" nowrap>@projection_value@</td>
      <td class="logger_listing_narrow">&nbsp;</td>
      <td class="logger_listing_narrow" align="center">&nbsp;</td>
    </tr>
  </if>

    <tr class="logger_listing_even">
      <th class="logger_listing_narrow">&nbsp;</th>
      <th class="logger_listing_narrow">&nbsp;</th>  
      <th class="logger_listing_narrow">&nbsp;</th>  
      <th class="logger_listing_narrow">&nbsp;</th>
      <th class="logger_listing_narrow">@variable.unit@</th>
      <th class="logger_listing_narrow">&nbsp;</th>
      <th class="logger_listing_narrow">&nbsp;</th>
    </tr>

  </table>
</else>

<!-- Log entries table end -->