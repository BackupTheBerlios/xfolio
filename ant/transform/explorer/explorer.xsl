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
  <!-- naming utilities -->
  <xsl:import href="../meta/naming.xsl"/>
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
  <xsl:param name="js" select="'theme/html.js'"/>
  <!-- lang requested -->
  <xsl:param name="lang"/>
  <!-- target frame for links -->
  <xsl:param name="target" select="'file'"/>
  <!-- TODO mode param -->
  <xsl:param name="mode"/>
  <!-- path of the applied doc from which resolve links -->
  <xsl:param name="path"/>
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
          <xsl:apply-templates/>
        <p>&#160;</p>
     </div>
        <iframe style="float:right;clear:none;"
         name="file"
         src="index.xhtml"
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
  
  <!-- match a root collection, TODO improve matching -->
  <xsl:template match="collection[not(ancestor::collection)]">
    <ul id="dir">
      <xsl:apply-templates/>
    </ul>
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

      <xsl:call-template name="meta-charset"/>
      <script type="text/javascript">
        <xsl:attribute name="src">
        <!-- 
could be interesting in some contexts when you have only absolute paths
rely on a naming.xsl
          <xsl:call-template name="getRelative">
            <xsl:with-param name="from" select="$path"/>
            <xsl:with-param name="to" select="$css"/>
          </xsl:call-template>
        -->
          <xsl:value-of select="'theme/explorer.js'"/>
        </xsl:attribute> 
          <!-- don't let the script tag empty, may bug in some browsers -->
        &#160;
      </script>

      <link rel="stylesheet" href="theme/explorer.css" type="text/css"/>

    
    </head>
  </xsl:template>
  <!--

A simple toc

maybe problems with directories called index ?
-->
  <!-- no output for empty directories -->
  <xsl:template match="collection[not(.//resource)]"/>
  <!--  -->
  <xsl:template match="collection" >
    <xsl:call-template name="toc-collection">
      <xsl:with-param name="collection" select="'collection'"/>
      <xsl:with-param name="resource" select="'resource'"/>
    </xsl:call-template>
  </xsl:template>
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
  <!-- open a directory -->
  <xsl:template name="toc-collection">
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
      <ul class="dir" id="{$id}-">
        <xsl:apply-templates select="*[not(@radical) or @radical != $welcome]"/>
      </ul>
  </xsl:template>
  <!-- 
to display only one file by radical, proceed only the first (and catch others) 
Input should be not too badly ordered, especially for extensions
-->
  <xsl:template match="resource[@radical = preceding-sibling::*[1]/@radical]" />
  <xsl:template match="resource" >
    <!-- param send from collection for a welcome file -->
    <xsl:param name="id"/>
    <xsl:variable name="radical" select="@radical"/>
      <xsl:choose>
        <!-- requested lang exist -->
        <xsl:when test="../resource[@radical=$radical][@xml:lang=$lang]">
          <xsl:call-template name="toc-link">
            <xsl:with-param name="id" select="$id"/>
            <xsl:with-param name="resource" select="../resource[@radical=$radical][@xml:lang=$lang][1]"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="toc-link">
            <xsl:with-param name="id" select="$id"/>
            <xsl:with-param name="current" select="../resource[@radical=$radical][1]"/>
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
      <xsl:when test="@radical != 'index'">
        <xsl:value-of select="@radical"/>
      </xsl:when>
      <!-- case of welcome file without include title -->
      <xsl:otherwise>
        <xsl:value-of select="ancestor::collection[1]/@name"/>
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
    <xsl:number count="collection[.//resource]" format="1.1" level="multiple" from="/*"/>
  </xsl:template>
<!--
Some specific style properties for the generated HTML of this transformation.
-->
  <xsl:template name="toc-css">
    <style type="text/css">
body {
  margin:0px;
  padding:0px;
}
#dir {
  font-size:9pt;
  font-family: Verdana, sans-serif;
  white-space:nowrap;
  margin:0px;
}
#dir a {
  text-decoration:none;
  color:#000000;
}
#dir a:active,
#dir a:focus {
  color:white; 
  background:#000080;
  text-decoration:none;
}
#dir a:hover {
  text-decoration:underline;
}

li.open {
  list-style:circle inside  url("skin/open.png") ;
}
li.close {
  list-style:circle inside  url("skin/close.png") ;
}
li {
  list-style:none inside ;
}
ul.dir {
  margin-top:0px; 
  margin-bottom:0px;
  margin-left:1ex;
  padding-left:1ex;
  border-left:dotted 1px;
}
    </style>
  </xsl:template>
</xsl:transform>
