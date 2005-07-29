<table>
  <tr>
    <td><#Dates Dates#></td>
    <td>
      <img src="/shared/1pixel?r=0&g=0&b=255" width="@progress_time_pct2@" height="16" alt="@progress_time_pct@%"
      ><img src="/shared/1pixel?r=200&g=200&b=200" width="@progress_time_pct_inverse2@" height="16">
    </td>
    <td align="right">
      &nbsp;&nbsp;&nbsp;@progress_days@/@total_days@ days
    </td>
    <td align="right">
      &nbsp;&nbsp;&nbsp;@progress_time_pct@%
    </td>
  </tr>
  <tr>
    <td>@variable.name@</td>
    <td>
      <if @progress_value_pct@ gt @progress_time_pct@>
        <img src="/shared/1pixel?r=255&g=0&b=0" width="@progress_value_pct2@" height="16" alt="@progress_value_pct@%"
        ><img src="/shared/1pixel?r=200&g=200&b=200" width="@progress_value_pct_inverse2@" height="16">
      </if>
      <else>
        <img src="/shared/1pixel?r=0&g=255&b=0" width="@progress_value_pct2@" height="16" alt="@progress_value_pct@%"
        ><img src="/shared/1pixel?r=200&g=200&b=200" width="@progress_value_pct_inverse2@" height="16">
      </else>
    </td>
    <td align="right">
      &nbsp;&nbsp;&nbsp;@total_value_pretty@/@projected_value_pretty@ @variable.unit@
    </td>
    <td align="right">
      &nbsp;&nbsp;&nbsp;@progress_value_pct@%
    </td>
  </tr>
</table>

