<!-- Navigation bar -->
<table class="logger_navbar" width="100%">
    <tr>
      <td align="right">
        <table border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td>
              <multiple name="links">
                <if @links.selected_p@>
                  <span class="logger_navbar_selected_link">@links.name@</span>
                </if>
                <else>
                  <a href="@links.url@" class="logger_navbar">@links.name@</a>
                </else>
                <span class="logger_navbar">&nbsp;|&nbsp;</span>
              </multiple>
            </td>
          </tr>
        </table>
      </td>
    </tr>
</table>
