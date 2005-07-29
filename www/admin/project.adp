<master src="/packages/logger/lib/master">
<property name="title">@page_title;noquote@</property>
<property name="context">@context;noquote@</property>
<property name="focus">project_form.name</property>

<blockquote>
  <formtemplate id="project_form"></formtemplate>
</blockquote>

<if @project_exists_p@ and @edit_mode_p@ eq 0>
  <ul class="action-links">
    <li><a href="@category_map_url@"><#Define_categories Define categories#></a></li>
  </ul>

  <if @variables:rowcount@ eq 0>
    <div class="boxed-user-message">
      <h3><#Important_Message Important Message#></h3>
      <div class="body">
        <#You_must You must#> <a href="@add_variable_url@"><#add_a_variable add a variable#></a> <#lt_to_your_project_befor to your project before
        you will be able to log entries to it.#>
      </div>
    </div>
  </if>

  <h2><#Variables Variables#></h2>

  <listtemplate name="variables"></listtemplate>
  <p></p>

  <h2><#Projections Projections#></h2>

  <listtemplate name="projections"></listtemplate>
  <p></p>
</if>

