<master src="/packages/logger/lib/master">
<property name="title">@page_title;noquote@</property>
<property name="context">@context;noquote@</property>
<property name="focus">project_form.name</property>

<blockquote>
  <formtemplate id="project_form" style="standard-lars"></formtemplate>
</blockquote>

<if @project_exists_p@ and @edit_mode_p@ eq 0>
  <ul class="action-links">
    <li><a href="@category_map_url@">Define categories</a></li>
  </ul>

  <h2>Variables</h2>

  <listtemplate name="variables"></listtemplate>
  <p></p>

  <h2>Projections</h2>

  <listtemplate name="projections"></listtemplate>
  <p></p>
</if>
