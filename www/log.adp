<master src="lib/master">
<property name="title">@page_title@</property>
<property name="context">@context@</property>
<property name="focus">log_entry_form.value</property>

<div class="logger_filter_bar" style="float: right; padding: 4px; style:">
  <table border="0" cellspacing="0" cellpadding="2" width="150">
    <tr>
      <td colspan="2" class="logger_filter_header">
        Add Entry
      </td>
    </tr>
    <multiple name="variables">
      <if @variables.selected_p@ true>
        <tr class="logger_filter_selected">
      </if>
      <else>
        <tr>
      </else>
        <td class="logger_filter">
          <b>&raquo;</b>
          <a href="@variables.url@">@variables.name@</a>
        </td>
      </tr>        
    </multiple>
  </table>
</div>

<blockquote>
  <formtemplate id="log_entry_form" style="standard-lars"></formtemplate>
</blockquote>

<p class="logger_font">
  <b>&raquo;</b>
  <a href="@add_entry_url@">Add new log entry</a>
</p>

<if @show_log_history_p@>
  <h3 class="logger" style="clear: left;">Log history for the past @log_history_n_days@ days</h3>

  <include src="lib/entries-table" 
        selected_user_id="@current_user_id@" 
        selected_project_id="@project_id@" 
        selected_variable_id="@variable_id@" 
        start_date_ansi="@start_date_ansi@"
        selected_entry_id="@entry_id_or_blank@" />
</if>
