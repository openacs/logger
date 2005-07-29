<master>
<property name="title">#logger.Logger_Application#</property>
<p>
  #logger.lt_Before_anyone_can_sta#
</p>    
<if @admin_p@>
  <!-- User is an admin so offer him/her to map or create projects -->
  <p>    
    #logger.lt_Since_you_are_an_admi# <a href="admin">#logger.lt_visit_the_admin_pages#</a> #logger.to_do_so_now#
  </p>
</if>
<else>
  <p>
    #logger.lt_Please_contact_an_adm#
  </p>
</else>


