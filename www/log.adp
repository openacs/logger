<master src="lib/master">
<property name="title">@page_title@</property>
<property name="context">@context@</property>

<blockquote>
  <formtemplate id="log_entry_form" style="standard-lars"></formtemplate>
</blockquote>

<if @show_log_history_p@>
  <h3>Log History for last 31 Days</h3>

  <include src="lib/entries-table" selected_user_id="@current_user_id@" selected_project_id="@project_id@" selected_variable_id="@variable_id@" selected_variable_unit="@variable_array.unit@"/>
</if>
