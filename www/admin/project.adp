<master src="../lib/master">
<property name="title">@page_title@</property>
<property name="context">@context@</property>
<property name="focus">project_form.name</property>

<blockquote>
  <formtemplate id="project_form" style="standard-lars"></formtemplate>
</blockquote>

<if @project_exists_p@ and @edit_mode_p@ eq 0>
  <h2>Variables</h2>

  <if @variables:rowcount@ gt 0>
    <table class="logger_listing" cellpadding="3" cellspacing="1">
      <tr class="logger_listing_header">
        <th class="logger_listing">Name</th>
        <th class="logger_listing">Primary</th>
        <th class="logger_listing">Unmap</th>
      </tr>
      <multiple name="variables">
        <if @variables.rownum@ odd>
          <tr class="logger_listing_odd">
        </if>
        <else>
          <tr class="logger_listing_even">
        </else>
          <td class="logger_listing">
            <a href="variable?variable_id=@variables.variable_id@">@variables.name@</a>
          </td>
          <td class="logger_listing" align="center">
            <if @variables.primary_p@ true><b>*</b></if>
            <else><a href="set-primary-variable?variable_id=@variables.variable_id@&project_id=@project_id@">set</a></else>
          </td>
          <td class="logger_listing">
            <if @variables.primary_p@ false>
              <a href="unmap-variable-from-project?variable_id=@variables.variable_id@&project_id=@project_id@">Unmap</a>
            </if>
          </td>
        </tr>
      </multiple>
    </table>
  </if>
  <else>
    <p>
      <span class="no_items_text">No variables selected</span>
    </p>
  </else>

  <if @n_can_be_mapped@ gt 0>
    <p>
      <b>&raquo;</b> <a href="map-variable-to-project?project_id=@project_id@">Add variable</a>
    </p>
  </if>

<h2>Projections</h2>

<if @projections:rowcount@ ne 0>
  <table class="logger_listing" cellpadding="3" cellspacing="1">
    <tr class="logger_listing_header">
      <th class="logger_listing">Name</th>
      <th class="logger_listing">Start day</th>
      <th class="logger_listing">End day</th>
      <th class="logger_listing">Variable</th>      
      <th class="logger_listing">Value</th>
      <th class="logger_listing">Description</th>
      <th class="logger_listing_narrow">&nbsp;</th>
    </tr>

  <multiple name="projections">
    <if @projections.rownum@ odd>
      <tr class="logger_listing_odd">
    </if>
    <else>
      <tr class="logger_listing_even">
    </else>
      <td class="logger_listing"><a href="projection?projection_id=@projections.projection_id@">@projections.name@</a></td>
      <td class="logger_listing">@projections.start_day@</td>
      <td class="logger_listing">@projections.end_day@</td>
      <td class="logger_listing">@projections.variable_name@</td>
      <td class="logger_listing">@projections.value@</td>
      <td class="logger_listing">@projections.description@</td>
      <td class="logger_listing_narrow">
        <if @projections.admin_p@>
          <a href="projection-delete?projection_id=@projections.projection_id@" 
          onclick="return confirm('Are you sure you want to delete projection @projections.name@?');"
          title"Delete this projection"><img src="/shared/images/Delete16.gif" width="16" height="16" border="0" alt="Delete"></a>
        </if> 
      </td>
    </tr>
  </multiple>

  </table>    
</if>
<else>
  <!-- There are no projections -->
  <span class="no_items_text">There are no projections</span>
</else>

<p>
  <b>&raquo;</b> <a href="projection?project_id=@project_id@">Add projection</a>
</p>

</if>
