<master src="lib/master">
<property name="title">@page_title;noquote@</property>
<property name="context">@context;noquote@</property>
<property name="focus">log_entry_form.value</property>

<script language="javascript">
   function project_change() {
      document.forms['log_entry_form'].elements['__refreshing_p'].value = 1;
      document.forms['log_entry_form'].elements['__refresh'].value = 'project';
      document.forms['log_entry_form'].submit();
   }
   function variable_change() {
      document.forms['log_entry_form'].elements['__refreshing_p'].value = 1;
      document.forms['log_entry_form'].elements['__refresh'].value = 'variable';
      document.forms['log_entry_form'].submit();
   }
</script>

<if @variables:rowcount@ not nil>
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
</if>

<blockquote>
  <formtemplate id="log_entry_form" style="standard-lars"></formtemplate>
</blockquote>

<if @entry_exists_p@>
  <p class="logger_font">
    <b>&raquo;</b>
    <a href="@add_entry_url@">Add new log entry</a>
  </p>
</if>

<if @show_log_history_p@>
  <h3 class="logger" style="clear: left;">Log history for the past @log_history_n_days@ days</h3>

  <include src="lib/entries-table" 
        selected_user_id="@current_user_id;noquote@" 
        selected_project_id="@project_id;noquote@" 
        selected_variable_id="@variable_id;noquote@" 
        start_date_ansi="@start_date_ansi;noquote@"
        selected_entry_id="@entry_id_or_blank;noquote@" />
</if>
