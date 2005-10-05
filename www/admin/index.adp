<master src="/packages/logger/lib/master">
<property name="title">@page_title;noquote@</property>

<div class="logger_body">

  <h2 class="logger">#logger.Projects#</h2>

  <listtemplate name="projects"></listtemplate>
  
  <p></p>

  <if @mappable_projects:rowcount@ gt 0>
    <p>
      #logger.lt_Projects_not_in_this_#
    </p>
    <listtemplate name="mappable_projects"></listtemplate>
    <p></p>

  </if>  

  <h2 class="logger">#logger.Variables#</h2>

  <listtemplate name="variables"></listtemplate>
  <p></p>

  <h2 class="logger">#logger.lt_Logger_Application_In#</h2>

  <ul class="action-links">
    <li><a href="@package_permissions_url@">#logger.lt_Set_permissions_for_t#</a></li> 
    <li><a href="@parameters_url@">#acs-subsite.Parameters#</a>
  </ul>

  <h2 class="logger">#logger.Help#</h2>

  <p class="logger_font">
    #logger.lt_The_logger_can_track_# <b>#logger.variables#</b> #logger.in_different# <b>#logger.projects#</b>.
  </p>

  <p class="logger_font">
    #logger.A# <b>#logger.variable#</b> #logger.lt_is_something_you_wish#
  </p>

  <ul class="logger_font">
    <li>
      #logger.Time_spent_hours#
    </li>
    <li>
      #logger.lt_Expenses_currency_USD#
    </li>
    <li>
      #logger.lt_Weight_of_goods_shipp#
    </li>
    <li>
      #logger.lt_Your_personal_weight_#
    </li>
  </ul>

  <p class="logger_font">
    #logger.Variables_are# <b>#logger.lt_shared_between_all_pr#</b>#logger.lt__so_that_you_can____s# <b>#logger.lt_map_variables_to____p#</b>.
  </p>

  <p class="logger_font">
    #logger.lt_Some_variables_will_b# <b>#logger.additive#</b>#logger.lt__meaning_that_it_make# <b>#logger.non-additive#</b>#logger.lt_____which_means_the_o#
  </p>
  
  <p class="logger_font">
  
  </p>
  
  <p class="logger_font">
  
  </p>
  
  <p class="logger_font">
  
  </p>
  

  <p class="logger_font">
    #logger.lt_You_can_mount_multipl# <b>#logger.lt_instances_of_the_logg#</b>#logger.lt__The_projects_you_def#
  </p>

  <p class="logger_font">
    #logger.lt_An_example_of_why_thi#
  </p>

</div>


