<master>
<property name="title">@title@</property>
<property name="context">@context@</property>
<if @focus@ not nil><property name="focus">@focus@</property></if>
<property name="header_stuff">
  @header_stuff@
  <style type="text/css" media="all">
    @import "@package_url@style.css";
  </style>
</property>
<property name="doc_type">
<?xml version="1.0"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
</property>

<include src="nav-bar">

<slave>

<include src="nav-bar">

