<master src="lib/master">
<property name="title">@page_title@</property>
<property name="context">@context@</property>

<p>
  Are you sure you want to delete <if @num_entries@ eq 1>this log entry</if><else>these @num_entries@ log entries</else>?
</p>

<p>
  <a href="@yes_url@" class="button">Delete</a>
  &nbsp;&nbsp;&nbsp;
  <a href="@no_url@" class="button">Cancel, do not delete</a>
</p>
