<master src="/packages/logger/lib/master">
<property name="title">@page_title;noquote@</property>
<property name="context">@context;noquote@</property>
<property name="focus">@focus;noquote@</property>

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
          #logger.Add_Entry#
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

<formtemplate id="log_entry_form"></formtemplate>

<if @show_log_history_p@ true>
  <h3 class="logger" style="clear: left;">#logger.Recent_Entries#</h3>

  <include src="/packages/logger/lib/entries" 
      project_id="@project_id;noquote@" 
      variable_id="@variable_id;noquote@" 
      filters_p="f"
      pm_project_id="@pm_project_id;noquote@" 
      start_date="@start_date_ansi;noquote@"
      end_date="@end_date_ansi;noquote@"
      show_orderby_p="f"
      entry_id="@entry_id_or_blank;noquote@"
      show_tasks_p="@show_tasks_p;noquote@"
      return_url="@return_url;noquote@"
      project_manager_url="@project_manager_url;noquote@"
      groupby="@groupby;noquote@"
      description_f="@description_f;noquote@"	
      project_status="@project_status;noquote@"
      user_id="@user_id;noquote@"
      /> 
</if>

