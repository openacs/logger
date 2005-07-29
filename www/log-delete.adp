<master src="/packages/logger/lib/master">
<property name="title">@page_title@</property>
<property name="context">@context@</property>

<p>
  #logger.lt_Are_you_sure_you_want# <if @num_entries@ eq 1>#logger.this_log_entry#</if><else>#logger.lt_these_num_entries_log#</else>?
</p>

<p>
  <a href="@yes_url@" class="button">#logger.Delete#</a>
  &nbsp;&nbsp;&nbsp;
  <a href="@no_url@" class="button">#logger.Cancel_do_not_delete#</a>
</p>

