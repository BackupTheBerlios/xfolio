<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="../html/xsl2html.xsl"?>
<!--

Title     : Transform hierarchical  in semantic XHTML
Label     : toc2html.xsl
Copyright : © 2003, 2004, "ADNX" <http://adnx.org>.
Licence   : "CeCILL" <http://www.cecill.info/licences/Licence_CeCILL_V1.1-US.html> 
            ("GPL" <http://www.gnu.org/copyleft/gpl.html> like)
Creator   : [FG] "Frédéric Glorieux" <frederic.glorieux@ajlsm.com> 
            ("AJLSM" <http://ajlsm.org>)

  = What =

This transformation take a documented directory as input,
and give some HTML views on it.

-->
<xsl:transform version="1.0" 
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
xmlns:dc="http://purl.org/dc/elements/1.1/"
xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
xmlns="http://www.w3.org/1999/xhtml" 
exclude-result-prefixes="xsl rdf dc xsi i18n">
  <!-- different tools to output not too bad xhtml (especially encoding) -->
  <xsl:import href="../html/html-common.xsl"/>
  <!-- path utilities -->
  <xsl:import href="path.xsl"/>
  <xsl:output method="xml" omit-xml-declaration="yes" indent="yes" encoding="UTF-8" />
  <!-- 
radical of file used as default leave to document a directory 
perhaps no more useful, because of a good initial generation (take first !)
-->
  <xsl:param name="welcome" select="'index'"/>
  <!-- extension on which build links -->
  <xsl:param name="extension" select="'xhtml'"/>
  <!-- 
the theme directory where to find some rendering resources
especially a css for icons, and js script.
 -->
  <xsl:param name="js" select="'explorer.js'"/>
  <xsl:param name="css" select="'explorer.css'"/>
  <!-- target frame for links -->
  <xsl:param name="target" select="'file'"/>
  <!-- TODO mode param -->
  <xsl:param name="mode"/>
  <!-- path of the applied doc from which resolve links -->
  <xsl:param name="path"/>
  <!-- lang requested, if no provide, guess it from path -->
  <xsl:param name="lang">
    <xsl:call-template name="getLang">
      <xsl:with-param name="path" select="$path"/>
    </xsl:call-template>
  </xsl:param>
  <!-- unsignificant extensions (multiple and displayable formats for same content) -->
  <xsl:param name="transformable" select="' sxw html rdf jpg png gif '"/>
  <!-- extensions transformed by server, to rewrite links -->
  <xsl:param name="htmlizable" select="' sxw '"/>
  <!-- extensions for which rdf may be available -->
  <xsl:param name="rdfizable" select="' sxw jpg '"/>
  <!--

Root template
-->
  <xsl:template match="/">
    <html>
      <xsl:call-template name="head"/>
      <body 
 onload="if (window.explorerInit) explorerInit()">
    <div style="
    width:29.9%; float:left;  clear:none; -moz-box-sizing: margin-box; box-sizing: margin-box;
 /* IE5 Mac hack \*/ overflow: auto; height:100%; /* useful ? */ 
    
    ">
        <ul id="explorer">
          <xsl:apply-templates select=".//collection[not(ancestor::collection)][1]/*"/>
        </ul>
        <p>&#160;</p>
     </div>
        <iframe style="float:right;clear:none;"
         name="file"
         frameborder="0" 
         marginheight="0" 
         marginwidth="0"  
         height="100%"
         width="70%" 
         align="bottom"
         >
        </iframe>

      </body>
    </html>
  </xsl:template>

    <!-- -->
  
  <!-- in case of muliple view of this toc, should be configurable -->
  <xsl:template name="toc-navigation">
    <table width="100%" cellpadding="0" cellspacing="0" border="0">
      <tr>
        <td width="100%">
          <select style="width:100%">
            <option>Contents</option>
            <option>Authors</option>
            <option>Index</option>
          </select>
        </td>
        <td>
          <select onchange="goLang(this)">
            <option/>
            <xsl:for-each select="
            .//resource/@xml:lang[not(.=preceding::resource/@xml:lang)]">
              <option>
                <xsl:if test=". = $lang">
                  <xsl:attribute name="selected">selected</xsl:attribute>
                </xsl:if>
                <xsl:value-of select="."/>
              </option>
            </xsl:for-each>
          </select>
        </td>
      </tr>
    </table>
  </xsl:template>
  <!-- html head -->
  <xsl:template name="head">
    <head>
      <title> explorer.xsl </title>
      <!-- specific properties for the explorer -->
      <style type="text/css">
html,body {
	height: 100%;
}

body {
  margin:0px;
  padding:0px;
  scrollbar-track-color:ButtonFace;
}      
      </style>
      <xsl:call-template name="html-metas"/>
    </head>
  </xsl:template>
  <!--

A simple toc

maybe problems with directories called index ?
-->
  <!-- write a link -->
  <xsl:template name="toc-link">
    <!-- given by caller if this item should be active -->
    <xsl:param name="id"/>
    <li>
      <xsl:choose>
        <xsl:when test="$id">
          <xsl:attribute name="class">open</xsl:attribute>
          <xsl:attribute name="id">
            <xsl:value-of select="$id"/>
          </xsl:attribute>
          <xsl:attribute name="onclick">if (window.expand) expand(this);</xsl:attribute>
        </xsl:when>
        <!-- TODO better matching of home -->
        <xsl:when test="not(preceding::resource)">
          <xsl:attribute name="class">home</xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="class">
            <xsl:value-of select="@extension"/>
          </xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
    <a>
    <!--
      Better to be handle directly from the js file
      <xsl:attribute name="onkeydown">if (window.tocKeyDown) return tocKeyDown(event, this);</xsl:attribute>
      <xsl:attribute name="onmouseover">this.focus()</xsl:attribute>
    -->
      <xsl:if test="$target">
        <xsl:attribute name="target">
          <xsl:value-of select="$target"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:attribute name="href">
        <xsl:call-template name="href"/>
      </xsl:attribute>
      <xsl:call-template name="title"/>
    </a>
    </li>
  </xsl:template>
  <!-- no output for empty directories -->
  <xsl:template match="collection[not(.//resource)]"/>
  <!-- open a directory -->
  <xsl:template match="collection" name="collection">
    <xsl:variable name="id">
      <xsl:call-template name="toc-number"/>
    </xsl:variable>
      <xsl:choose>
        <!-- no welcome file, write a link on directory name, and pray for an auto  -->
        <xsl:when test="not(resource[@radical = $welcome])">
          <xsl:call-template name="toc-link">
            <xsl:with-param name="id" select="$id"/>
          </xsl:call-template>
        </xsl:when>
        <!-- different things and a welcome file to get a title -->
        <xsl:otherwise>
          <xsl:apply-templates select="*[@radical = $welcome]">
            <xsl:with-param name="id" select="$id"/>
          </xsl:apply-templates>
        </xsl:otherwise>
      </xsl:choose>
      <ul class="explorer" id="{$id}-">
        <!-- in case of error to not let an empty tag (considered open by brother) -->
        <xsl:comment> - </xsl:comment>
        <xsl:apply-templates select="*[not(@radical) or @radical != $welcome]"/>
      </ul>
  </xsl:template>
  <!-- 
A quite tricky matching of resources

Idea is to exclude some resource to have a nicer list

to display only one file by radical, proceed only the first (and catch others) 
Input should be not too badly ordered, especially for extensions
-->
  <xsl:template match="resource" >
    <!-- param send from collection if this resource is used as a welcome file -->
    <xsl:param name="id"/>
    <xsl:choose>
      <!-- NO : lang requested, a brother have it, but not this one -->
      <xsl:when test="
normalize-space($lang) != '' and not(contains(@xml:lang, $lang))
and ../resource[@radical= current()/@radical]
               [generate-id() != generate-id(current())]
               [contains(@xml:lang, $lang)]
      "/>
      <!-- NO : lang requested but unavailable, take the first with same radical -->
      <xsl:when test="
normalize-space($lang) != '' 
and not(../resource[@radical= current()/@radical]
               [contains(@xml:lang, $lang)])
and preceding::resource[@radical= current()/@radical]               
      "/>
      <!-- NO : a more friendly extension exist with same basename (radical + lang) -->
      <xsl:when test="
../resource[@basename= current()/@basename]
           [generate-id() != generate-id(current())]
           [contains($transformable, concat(' ', @extension, ' ') )]
"/>
      <!-- NO : no lang is requested, a brother with another language have already been outputed -->
      <xsl:when test="
normalize-space($lang)='' and      
preceding-sibling::resource[@radical=current()/@radical]
      "/>
      <xsl:otherwise>
        <xsl:call-template name="toc-link">
          <xsl:with-param name="id" select="$id"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!--
get title
-->
  <xsl:template name="title">
    <!-- if no link ? -->
    <xsl:choose>
      <!-- called from a directory without welcome file -->
      <xsl:when test="name() = 'collection'">
        <xsl:value-of select="@name"/>
      </xsl:when>
      <!-- an embed RDF -->
      <xsl:when test=".//dc:title">
        <xsl:apply-templates select=".//dc:title[1]"/>
      </xsl:when>
      <!-- no RDF, use filename as title -->
      <xsl:when test="@radical = 'index' ">
        <xsl:value-of select="ancestor::collection[1]/@name"/>
      </xsl:when>
      <!-- unsignificant extension -->
      <xsl:when test="contains($transformable, @extension)">
        <xsl:value-of select="@radical"/>
      </xsl:when>
      <!-- case of welcome file without include title -->
      <xsl:otherwise>
        <xsl:value-of select="@name"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- global redirection of links -->
  <xsl:template name="href">
    <xsl:choose>
      <xsl:when test="false()"/>
      <xsl:when test="name()='collection'">
        <xsl:call-template name="getRelative">
          <xsl:with-param name="from" select="$path"/>
          <xsl:with-param name="to" select="@href"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="contains($htmlizable, concat(' ',@extension,' '))">
        <xsl:call-template name="getRelative">
          <xsl:with-param name="from" select="$path"/>
          <xsl:with-param name="to">
            <xsl:value-of select="../@href"/>
            <xsl:value-of select="substring-before(@name, concat('.', @extension))"/>
            <xsl:text>.</xsl:text>
            <xsl:value-of select="$extension"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="getRelative">
          <xsl:with-param name="from" select="$path"/>
          <xsl:with-param name="to">
            <xsl:value-of select="@href"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- a numbering -->
  <xsl:template name="toc-number">
    <xsl:choose>
      <xsl:when test="collection[not(ancestor::collection)]">dir</xsl:when>
      <xsl:otherwise>
        <xsl:number count="collection[.//resource]" format="1.1" level="multiple" 
        from="/*"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- sample input for this transformation -->
  <xsl:template name="xsl:input">
    <?xml-stylesheet  type="text/xsl" href="explorer.xsl"?>
    <!-- used by the transformation upper to link html generated to the script -->
    <?js explorer.js?>
    <!-- 
used by the transformation upper to link html generated css
links to icons are in the css and should be correct from there.
    -->
    <?css explorer.css?>
    <collection 
       generated="2004-11-22T13:31:04" 
       directory="/explorer" 
       name="explorer" 
       href="" 
       modified="2004-11-22T12:53:20">
       
       </collection>   
  </xsl:template>
</xsl:transform>
