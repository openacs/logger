<master src="../lib/master">
<property name="title">@page_title@</property>
<property name="context">@context@</property>

<blockquote>
  <formtemplate id="project_form" style="standard-lars"></formtemplate>
</blockquote>

<if @project_exists_p@>
  <h2>Variables</h2>

  <if @variables:rowcount@ gt 0>
  <ul>
  <multiple name="variables">
    <li>
      <p>
        <a href="variable?variable_id=@variables.variable_id@">@variables.name@</a>
        <if @variables.primary_p@ eq f>
        &nbsp; 
        [ <a href="unmap-variable-from-project?variable_id=@variables.variable_id@&project_id=@project_id@">unmap</a> | 
          <a href="set-primary-variable?variable_id=@variables.variable_id@&project_id=@project_id@">make primary</a> ]   
      </if>
      <else>
        (primary)
      </else>
      </p>
     </li>
  </multiple>
  </ul>
  </if>
  <else>
    <p>
      <span class="no_items_text">no variables</span>
    </p>
  </else>

  <if @n_can_be_mapped@ gt 0>
    <p>
      [ <a href="map-variable-to-project?project_id=@project_id@">add variable</a> ] 
    </p>
  </if>

</if>

<h2>Projections</h2>

<if @projections:rowcount@ ne 0>
  <table class="logger_table" cellpadding="4" cellspacing="1">
    <tr class="logger_table_header">
      <th>&nbsp;</th>
      <th>Name</th>
      <th>Start day</th>
      <th>End day</th>
      <th>Variable</th>      
      <th>Value</th>
      <th>Description</th>
    </tr>

  <multiple name="projections">
    <tr class="logger_table_rows">
      <td>
        <if @projections.admin_p@> [ <a href="projection-delete?projection_id=@projections.projection_id@" 
          onclick="return confirm('Are you sure you want to delete projection @projections.name@?');">delete</a> ]
        </if> 
      </td>
      <td><a href="projection?projection_id=@projections.projection_id@">@projections.name@</a></td>
      <td>@projections.start_day@</td>
      <td>@projections.end_day@</td>
      <td>@projections.variable_name@</td>
      <td>@projections.value@</td>
      <td>@projections.description@</td>
    </tr>
  </multiple>

  </table>    
</if>
<else>
  <!-- There are no projections -->
  <span class="no_items_text">There are no projections</span>
</else>

<p>
  [ <a href="projection?project_id=@project_id@">add projection</a> ]
</p>