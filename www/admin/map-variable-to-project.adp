<master src="../lib/master">
<property name="title">@page_title@</property>
<property name="context">@context@</property>

<if @variables:rowcount@ ne 0>
  <ul>
  <multiple name="variables">
    <li><a href="map-variable-to-project-2?project_id=@project_id@&variable_id=@variables.variable_id@">@variables.name@</a>
         (@variables.unit@, @variables.type@)</li>
  </multiple>
  </ul>
</if>
<else>
  <span class="no_items_text">There are no variables in this package that are not already added to the project</span>
</else>
