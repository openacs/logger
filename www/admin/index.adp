<master src="/packages/logger/lib/master">
<property name="title">@page_title;noquote@</property>

<div class="logger_body">

  <h2 class="logger">Projects</h2>

  <listtemplate name="projects"></listtemplate>
  
  <p></p>

  <if @mappable_projects:rowcount@ gt 0>
    <p>
      Projects not in this logger application instance which can be linked in:
    </p>
    <listtemplate name="mappable_projects"></listtemplate>
    <p></p>

  </if>  

  <h2 class="logger">Variables</h2>

  <listtemplate name="variables"></listtemplate>
  <p></p>

  <h2 class="logger">Logger Application Instance</h2>

  <ul class="action-links">
    <li><a href="@package_permissions_url@">Set permissions for this logger application instance</a></li>
  </ul>

  <h2 class="logger">Help</h2>

  <p class="logger_font">
    The logger can track a number of <b>variables</b> in different <b>projects</b>.
  </p>

  <p class="logger_font">
    A <b>variable</b> is something you wish to track, for example:
  </p>

  <ul class="logger_font">
    <li>
      Time spent (hours)
    </li>
    <li>
      Expenses (currency, USD, EUR, whatever)
    </li>
    <li>
      Weight of goods shipped (lbs, kgs)
    </li>
    <li>
      Your personal weight (lbs, kgs). Non-additive.
    </li>
  </ul>

  <p class="logger_font">
    Variables are <b>shared between all projects</b>, so that you can
    summarize the variable across projects. However, if you have many
    diverse projects going on, only certain variables will make sense
    for any given project, hence we let you <b>map variables to
    projects</b>.
  </p>

  <p class="logger_font">
    Some variables will be <b>additive</b>, meaning that it makes
    sense to add them together and look at the total. An example of an
    additive variable is time spent. Others are <b>non-additive</b>,
    which means the opposite. Instead, you would typically average
    over them. An example is measuring your personal weight, or the
    account balance of your bank account. It doesn't make sense to add
    those numbers together, they're snapshots at a given point in
    time, and just because you check your account balance 10 times a
    day doesn't (necessarily) mean you're getting richer and richer.
  </p>
  
  <p class="logger_font">
  
  </p>
  
  <p class="logger_font">
  
  </p>
  
  <p class="logger_font">
  
  </p>
  

  <p class="logger_font">
    You can mount multiple <b>instances of the logger
    application</b>. The projects you define are shared between all
    logger application instances, subject to the permissions you grant
    on them. Each instance of logger will be setup to display a
    certain subset of the projects available, as defined by the
    administrator of that instance.
  </p>

  <p class="logger_font">
    An example of why this is useful is if you work for a company,
    which works on many different projects for different clients. In
    that scenario, you would mount a logger instance in your intranet,
    where people log the hours they spend on projects. Then if you
    want to give your clients access to your logs, you can mount an
    instance per client in the client's extranet area. These client
    loggers would only have access to the projects that pertain to the
    given client.
  </p>

</div>

