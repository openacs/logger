<if @filters_p@ true>
  <table cellpadding="3" cellspacing="3">
    <tr>
      <td class="list-filter-pane" valign="top" width="200">
        <listfilters name="entries"></listfilters>
      </td>
      <td class="list-list-pane" valign="top">
</if>
      <listtemplate name="entries"></listtemplate>
<if @filters_p@ true>
      </td>
    </tr>
  </table>
</if>
