<if @filters_p@ true>
  <table cellpadding="3" cellspacing="3" width="100%" border="0">
    <tr>
      <td class="list-filter-pane" valign="top" width="200">
        <listfilters name="entries"></listfilters>
      </td>
      <td valign="top">
</if>
      <if @projection_id@ not nil>
        <div style="border-top: 1px dotted black; border-bottom: 1px dotted black; margin-bottom: 8px;">
          <include src="/packages/logger/lib/projection" projection_id="@projection_id@">
        </div>
      </if>
      <listtemplate name="entries"></listtemplate>
<if @filters_p@ true>
      </td>
    </tr>
  </table>
</if>
