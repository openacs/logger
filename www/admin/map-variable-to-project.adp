<master src="../lib/master">
<property name="title">@page_title;noquote@</property>
<property name="context">@context;noquote@</property>

<if @variables:rowcount@ ne 0>
  <ul>
  <multiple name="variables">
    <li><a href="map-variable-to-project-2?project_id=@project_id@&variable_id=@variables.variable_id@">@variables.name@</a>
         (@variables.unit@, @variables.type@)</li>
  </multiple>
  </ul>
</if>
<else>
  <p>
    <span class="no_items_text">You do not have access to any variables that are not already added to the project</span>
  </p>
</else>
