<?xml version="1.0" encoding="UTF-8"?>
<!--
(c) 2003, 2004 [xfolio.org], [ajlsm.com], [strabon.org], [eumedis.net]
Licence :  [http://www.gnu.org/copyleft/gpl.html GPL]

= WHAT =

This transformation take a documented directory as input,
and give some HTML views on it.

= WHO =

 *[FG] FredericGlorieux frederic.glorieux@xfolio.org

= CHANGES =

 * 2004-07-14:FG  "write site" in real time

= WHY =

I had implemented the same functionalities in pure XSL, and I'm now glad
to forget all that stuff for an easier solution to maintain (cause now 
most of the logic is done by a JAVA generator).

= TODO =

Everything.

-->
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dir="http://apache.org/cocoon/directory/2.0" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:i18n="http://apache.org/cocoon/i18n/2.1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" exclude-result-prefixes="xsl rdf dc xsi dir i18n">
  <xsl:output method="xml" encoding="UTF-8"/>
  <!-- encoding, default is the one specified in xsl:output -->
  <xsl:param name="encoding" select="document('')/*/xsl:output/@encoding"/>
  <!-- lang requested -->
  <xsl:param name="lang"/>
  <!-- default language -->
  <xsl:param name="langDefault" select="'en'"/>
  <!-- extensions transformed by server -->
  <xsl:param name="htmlizable" select="' dbx sxw jpg '"/>
  <!-- root -->
  <xsl:param name="root" select=".//dir:navigation/dir:directory/@href"/>
  <!-- skin -->
  <xsl:param name="skin" select="concat(.//dir:navigation/dir:directory/@href, 'skin/')"/>
  <!-- size -->
  <xsl:param name="size" select="22"/>
  <!--

Root template
-->
  <xsl:template match="/">
    <html>
      <head>
        <title>&#160;</title>
        <meta http-equiv="Content-type" content="text/html; charset={$encoding}"/>
      </head>
      <body>
        <div id="navbar">
          <xsl:apply-templates select="dir:navigation" mode="navbar"/>
        </div>
      </body>
    </html>
  </xsl:template>
  <xsl:template match="dir:navigation" mode="navbar">
    <!-- home -->
    <table border="0" cellpadding="0" cellspacing="0">
      <tr>
        <td nowrap="nowrap" valign="middle">
          <a href="{dir:directory/@href}">
            <xsl:attribute name="title">
              <xsl:apply-templates select="dir:directory" mode="title"/>
            </xsl:attribute>
            <img border="0" width="{$size}" height="{$size}" src="{$skin}buttons/home_{$size}.png" onload="var imgover=new Image(); imgover.src='{$skin}buttons/home-over_{$size}.png';" onmouseover="this.src='{$skin}buttons/home-over_{$size}.png'" onmouseout="this.src='{$skin}buttons/home_{$size}.png'"/>
          </a>
          <a>
            <xsl:attribute name="title">
              <xsl:apply-templates select="dir:prev" mode="title"/>
            </xsl:attribute>
            <xsl:attribute name="href">
              <xsl:apply-templates select="dir:prev" mode="href"/>
            </xsl:attribute>
            <img border="0" width="{$size}" height="{$size}" src="{$skin}buttons/prev_{$size}.png" onload="var imgover=new Image(); imgover.src='{$skin}buttons/prev-over_{$size}.png';" onmouseover="this.src='{$skin}buttons/prev-over_{$size}.png'" onmouseout="this.src='{$skin}buttons/prev_{$size}.png'"/>
          </a>
          <a>
            <xsl:attribute name="href">
              <xsl:apply-templates select="dir:next" mode="href"/>
            </xsl:attribute>
            <xsl:attribute name="title">
              <xsl:apply-templates select="dir:next" mode="title"/>
            </xsl:attribute>
            <img align="bottom" border="0" width="{$size}" height="{$size}" src="{$skin}buttons/next_{$size}.png" onload="var imgover=new Image(); imgover.src='{$skin}buttons/next-over_{$size}.png';" onmouseover="this.src='{$skin}buttons/next-over_{$size}.png'" onmouseout="this.src='{$skin}buttons/next_{$size}.png'">
            
            </img>
          </a>
        </td>
        <td> &#160;</td>
        <td>
          <xsl:apply-templates select="dir:directory" mode="path"/>
          <!-- lang -->
          <xsl:if test=".//dir:directory[@requested]/dir:file[@selected][@xml:lang]">
            <select onchange="window.location.href=this.options[this.selectedIndex].value;">
              <option/>
              <xsl:for-each select=".//dir:directory[@requested]/dir:file[@selected][@xml:lang]">
                <option>
                  <xsl:attribute name="value">
                    <xsl:apply-templates select="." mode="href"/>
                  </xsl:attribute>
                  <xsl:if test="@xml:lang = $lang">
                    <xsl:attribute name="selected">selected</xsl:attribute>
                  </xsl:if>
                  <!-- may do, href if not long title -->
                  <xsl:attribute name="title">
                    <xsl:apply-templates select="." mode="href"/>
                  </xsl:attribute>
                  <xsl:value-of select="@xml:lang"/>
                </option>
              </xsl:for-each>
            </select>
          </xsl:if>
        </td>
      </tr>
    </table>
  </xsl:template>
  <!--
  process nested directories up to file list
-->
  <xsl:template match="dir:directory" mode="path">
    <xsl:text> &gt;&#160;</xsl:text>
    <a>
      <xsl:attribute name="href">
        <xsl:apply-templates select="." mode="href"/>
      </xsl:attribute>
      <xsl:attribute name="title">
        <xsl:apply-templates select="." mode="title"/>
      </xsl:attribute>
      <xsl:apply-templates select="." mode="title">
        <xsl:with-param name="short" select="true()"/>
      </xsl:apply-templates>
    </a>
    <xsl:choose>
      <xsl:when test="@requested">
        <xsl:text> &gt;&#160;</xsl:text>
        <select onchange="window.location.href=this.options[this.selectedIndex].value;">
          <option/>
          <xsl:for-each select="dir:*">
            <xsl:variable name="radical" select="@radical"/>
            <xsl:choose>
              <!-- process only one file of same radical -->
              <xsl:when test="preceding-sibling::dir:*[1]/@radical=$radical"/>
              <!-- strip empty directories -->
              <xsl:when test="name()='dir:directory' and not(dir:file)"/>
              <xsl:when test="../dir:file[@radical=$radical][@xml:lang=$lang]">
                <xsl:apply-templates select="../dir:file[@radical=$radical][@xml:lang=$lang][1]" mode="option"/>
              </xsl:when>
              <xsl:when test="../dir:file[@radical=$radical][@xml:lang=$langDefault]">
                <xsl:apply-templates select="../dir:file[@radical=$radical][@xml:lang=$langDefault][1]" mode="option"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates select="." mode="option"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </select>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="dir:directory[1]" mode="path"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- option -->
  <xsl:template match="dir:*" mode="option">
    <option>
      <xsl:attribute name="value">
        <xsl:apply-templates select="." mode="href"/>
      </xsl:attribute>
      <xsl:copy-of select="@selected"/>
      <!-- may do, href if not long title -->
      <xsl:attribute name="title">
        <xsl:apply-templates select="." mode="href"/>
      </xsl:attribute>
      <xsl:apply-templates select="." mode="title">
        <xsl:with-param name="short" select="true()"/>
      </xsl:apply-templates>
    </option>
  </xsl:template>
  <!--
get title
-->
  <xsl:template match="*" mode="title">
    <xsl:param name="short"/>
    <xsl:choose>
      <xsl:when test="dir:file[@xml:lang=$lang][@radical='index'][.//dc:title]">
        <xsl:apply-templates select="dir:file[@xml:lang=$lang][@radical='index'][1]" mode="title">
          <xsl:with-param name="short" select="$short"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="dir:file[@xml:lang=$langDefault][@radical='index'][.//dc:title]">
        <xsl:apply-templates select="dir:file[@xml:lang=$langDefault][@radical='index'][1]" mode="title">
          <xsl:with-param name="short" select="$short"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="dir:file[@radical='index'][.//dc:title]">
        <xsl:apply-templates select="dir:file[@radical='index'][1]" mode="title">
          <xsl:with-param name="short" select="$short"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="name() = 'dir:directory'">
        <xsl:value-of select="@name"/>
      </xsl:when>
      <!-- TODO: search a trick for short title  -->
      <xsl:when test=".//dc:title[2] and name()='dir:file' and not($short)">
        <xsl:apply-templates select=".//dc:title[2]" mode="title"/>
      </xsl:when>
      <xsl:when test=".//dc:title and name()='dir:file'">
        <xsl:apply-templates select=".//dc:title[1]" mode="title"/>
      </xsl:when>
      <xsl:when test="dir:file[@xml:lang=$lang]">
        <xsl:apply-templates select="dir:file[@xml:lang=$lang][1]" mode="title">
          <xsl:with-param name="short" select="$short"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="dir:file[@xml:lang=$langDefault]">
        <xsl:apply-templates select="dir:file[@xml:lang=$langDefault][1]" mode="title">
          <xsl:with-param name="short" select="$short"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="dir:file">
        <xsl:apply-templates select="dir:file[1]" mode="title">
          <xsl:with-param name="short" select="$short"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="@radical">
        <xsl:value-of select="@radical"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="dc:title" mode="title">
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template>
  <!-- global redirection of links -->
  <xsl:template match="*" mode="href">
    <xsl:choose>
      <xsl:when test="@extension and contains($htmlizable, concat(' ',@extension,' '))">
        <!-- may bug with some naming like 01/01/01 or 01.sxw/01.sxw -->
        <xsl:value-of select="substring-before(@href, @name)"/>
        <xsl:value-of select="substring-before(@name, concat('.', @extension))"/>
        <xsl:text>.html</xsl:text>
      </xsl:when>
      <xsl:when test="dir:file[@xml:lang=$lang][@radical='index']">
        <xsl:apply-templates select="dir:file[@xml:lang=$lang][@radical='index'][1]" mode="href"/>
      </xsl:when>
      <xsl:when test="dir:file[@xml:lang=$langDefault][@radical='index']">
        <xsl:apply-templates select="dir:file[@xml:lang=$langDefault][@radical='index'][1]" mode="href"/>
      </xsl:when>
      <xsl:when test="dir:file[@radical='index']">
        <xsl:apply-templates select="dir:file[@radical='index'][1]" mode="href"/>
      </xsl:when>
      <xsl:when test="name() = 'dir:directory'">
        <xsl:value-of select="@href"/>
      </xsl:when>
      <xsl:when test="dir:file[@xml:lang=$lang]">
        <xsl:apply-templates select="dir:file[@xml:lang=$lang][1]" mode="href"/>
      </xsl:when>
      <xsl:when test="dir:file[@xml:lang=$langDefault]">
        <xsl:apply-templates select="dir:file[@xml:lang=$langDefault][1]" mode="href"/>
      </xsl:when>
      <xsl:when test="dir:file">
        <xsl:apply-templates select="dir:file[1]" mode="href"/>
      </xsl:when>
      <xsl:when test="@href">
        <xsl:value-of select="@href"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
</xsl:transform>
