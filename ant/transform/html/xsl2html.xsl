<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="xsl2html.xsl"?>
<!--
title   : xsl2html.xsl
rights  : Copyright 2003-2004 ADNX <http://adnx.org>
creator : "Frédéric Glorieux" <frederic.glorieux@ajlsm.com>

  = WHAT =

This is an XSL to transform XSL, for documentation (a kind of "xsldoc").
This tool is designed for

 1) producing vast amount of printable paper for activities report, 
    human readable if possible (bad reason)
 2) have real time view to improve XSL design (real usage)
 3) help reusability of XSL (good wish)

  = HOW =

add a stylesheet declaration to you XSL
<?xml-stylesheet type="text/xsl" href="xsl2html.xsl"?>
and see the result in an XSL browser compatible.
So, you can have a text view in your favorite editor,
and documentation view in your browser.

  = FEATURES =

 * 

 = TODO =

 * full cross refence between XSL elements
 * templates ordered by names
 * 
 * index of generated elements
   with linking  
 * index of generated texts
 * templates ordered by name, 
 * lists of TODO, FIXME (MAYDO, and others ?)
 * lists of dates (calendar)

 = CHANGES = 

2004-11-07 [FG] creation

-->
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
 xmlns="http://www.w3.org/1999/xhtml"

>
  <!-- 
xml2html.xsl

Interesting to format comments.
*import precedence* xml2html.xsl < text2html.xsl < html-common.xsl
 -->
  <xsl:import href="xml2html.xsl"/>
  <!-- the output declaration -->
  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
  <!-- unsignificant chars -->
  
  <!-- messages -->

  <xsl:template match="/">
    <xsl:call-template name="html"/>
  </xsl:template>
  <!-- the html generated -->
  <xsl:template name="html">
    <html>
      <head>
        <title>TODO</title>
      </head>
      <xsl:call-template name="body"/>
    </html>
  </xsl:template>
  
  <!-- generate an html body -->
  <xsl:template name="body">
    <body>
      <xsl:apply-templates select="xsl:stylesheet | xsl:transform"/>
      <!-- some space to help internal links -->
      <p>&#160;</p>
      <p>&#160;</p>
      <p>&#160;</p>
      <p>&#160;</p>
    </body>
  </xsl:template>
  
  <!-- 
call this template in xsl:transform to get a table header about it 

TODO attribute-set, 
-->
  <xsl:template name="xsl:header">
      <table border="1" width="100%">
        <caption style="background:#CCCCFF; ">
          <h1>XSL Description</h1>
        </caption>
        <xsl:apply-templates select="xsl:include | xsl:import"/>
        <xsl:if test="xsl:param">
            <tr bgcolor="#EEEEEE">
              <th>Parameters</th>
              <th>description</th>
              <th>value</th>
              <th>usage</th>
            </tr>
            <xsl:apply-templates select="xsl:param"/>
        </xsl:if>
        <xsl:if test="xsl:param">
            <tr bgcolor="#EEEEEE">
                <th>Variables</th>
                <th>description</th>
                <th>value</th>
                <th>usage</th>
            </tr>
            <xsl:apply-templates select="xsl:variable"/>
        </xsl:if>
          <tr>
            <th>Output</th>
            <td colspan="4">
              <xsl:for-each select=".//*[namespace-uri() != 'http://www.w3.org/1999/XSL/Transform']">
                <xsl:sort select="name()"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="name()"/>
              </xsl:for-each>
            </td>
          </tr>
          <tr>
            <th>Messages</th>
            <td colspan="4">

              <xsl:for-each select=".//text()[normalize-space(.)!= '']
[name(./..) != 'xsl:variable']
">
                <xsl:if test="position() != 1">, </xsl:if>
                <xsl:text>"</xsl:text>
                <a>
                  <xsl:attribute name="href">
                    <xsl:text>#</xsl:text>
                    <xsl:apply-templates select="ancestor::xsl:template" mode="id"/>
                  </xsl:attribute>
                  <xsl:value-of select="."/>
                </a>
                <xsl:text>"</xsl:text>
              </xsl:for-each>

            </td>
          </tr>
      </table>

  </xsl:template>
  
  
  <!-- includes and imports in a table 
TODO rewriting of links for html (see html-common.xsl) -->
  <xsl:template match="xsl:include | xsl:import"> 
    <tr>
      <th>include</th>
      <td>
        <a href="{@href}">
          <xsl:value-of select="@href"/>
        </a>
      </td>
      <td>
        <xsl:apply-templates select="
preceding-sibling::comment()[1][generate-id(following-sibling::*)=generate-id(current())]
" mode="text2html"/>
      </td>
    </tr>
  </xsl:template>
  
  <!-- matching root variable or parameter, appears in a table -->
  <xsl:template match="
  xsl:stylesheet/xsl:param | xsl:transform/xsl:param
|  xsl:stylesheet/xsl:variable | xsl:transform/xsl:variable
  ">
    <xsl:variable name="name" select="@name"/>
    <tr>
      <!-- name -->
      <td>
        <var>
          <xsl:value-of select="@name"/>
        </var>
      </td>
      <!-- description -->
      <td>
        <xsl:apply-templates select="
preceding-sibling::comment()[1][generate-id(following-sibling::*)=generate-id(current())]
" mode="text2html"/>
      </td>
      <!-- value -->
      <td>
        <samp>
          <xsl:value-of select="@select"/>
          <xsl:apply-templates/>
        </samp>
      </td>
      <!-- usage -->
      <td>
        <!--
 this xpath select the first occurence for each template
 of an usage of a variable  
        -->
        <xsl:for-each select="
../xsl:template[.//@*[name()='select' or name()='test'][contains(., concat('$', $name))]]">
            <xsl:if test="position()!=1">, </xsl:if>
            <xsl:apply-templates select="." mode="link"/>
        </xsl:for-each>
      </td>
    </tr>
  </xsl:template>

  <!-- for now, only templates are named and linkable -->
  <xsl:template match="xsl:template" mode="link">
    <a>
      <xsl:attribute name="href">
        <xsl:text>#</xsl:text>
        <xsl:apply-templates select="." mode="id"/>
      </xsl:attribute>
      <xsl:apply-templates select="." mode="id"/>
    </a>
  </xsl:template>
  
  <!-- default generate-id() for a node (used for anchor or target) -->
  <xsl:template match="node()|@*" mode="id">
    <xsl:value-of select="generate-id()"/>
  </xsl:template>
  <!-- id of named template is its name -->
  <xsl:template match="xsl:template[@name]" mode="id">
    <xsl:value-of select="@name"/>
  </xsl:template>
  <!-- id of match template without name -->
  <xsl:template match="xsl:template[not(@name)]" mode="id">
    <xsl:text>template</xsl:text>
    <xsl:number count="xsl:template[not(@name)]" level="any"/>
  </xsl:template>
  
  <!-- global matching of stylesheet -->
  <xsl:template match="xsl:stylesheet | xsl:transform">

    <!-- header -->
    <xsl:call-template name="xsl:header"/>
    <!-- description -->
        <xsl:apply-templates select="
preceding-sibling::comment()[1][generate-id(following-sibling::*)=generate-id(current())]
" mode="text2html"/>
    <!-- TODOs -->
    <xsl:if test="contains(.//comment(), ' TODO ')">
      <h1>TODOs</h1>
      
    </xsl:if>
    <!-- templates -->
    <table border="1">
      <caption><h1>Templates</h1></caption>
      <thead>
        <tr bgcolor="#CCCCCC">
          <th>name</th>
          <th>mode</th>
          <th>match</th>
          <th>description</th>
          <th>output</th>
        </tr>
      </thead>
      <tbody>
        <xsl:apply-templates select="xsl:template">
          <xsl:sort select="@name"/>
          <xsl:sort select="@mode"/>
          <xsl:sort select="@match"/>
        </xsl:apply-templates>
      </tbody>
    </table>
    <!-- output elements -->
    <!-- output messages -->
    <!-- source -->
  </xsl:template>

  <!-- A template (@name or @match), as a line in a table -->
  <xsl:template match="xsl:template">
    <tr>
      <xsl:attribute name="id">
        <xsl:apply-templates select="." mode="id"/>
      </xsl:attribute>
      <!-- name -->
      <th>
        <xsl:apply-templates select="." mode="link"/>
      </th>
      <!-- mode -->
      <td>
        <xsl:value-of select="@mode"/>
      </td>
      <!-- match -->
      <td>
        <xsl:value-of select="@match"/>
      </td>
      <!-- description -->
      <td>
        <xsl:apply-templates select="
preceding-sibling::comment()[1][generate-id(following-sibling::*)=generate-id(current())]
" mode="text2html"/>
      </td>
      <!-- output -->
      <td>
        <xsl:apply-templates select="*[name()!='variable' and name()!='param' ]"/>
      </td>
    </tr>
  </xsl:template>


  <!-- consider a choose as an ordered list of outputs -->
  <xsl:template match="xsl:choose">
    <ol>
        <xsl:apply-templates select="
preceding-sibling::comment()[1][generate-id(following-sibling::*)=generate-id(current())]
" mode="text2html"/>
      
        <xsl:apply-templates/>
    </ol>
  </xsl:template>
  
  <!-- consider a when as list-item -->
  <xsl:template match="xsl:when | xsl:otherwise">
    <li>
        <xsl:apply-templates select="
preceding-sibling::comment()[1][generate-id(following-sibling::*)=generate-id(current())]
" mode="text2html"/>
        <tt>
          <xsl:value-of select="@test"/>
        </tt>
    </li>
  </xsl:template>

  <!-- 
parameters 
<xsl:param name="?" select="?"/>
-->
  <xsl:template match="xsl:param">

    
  </xsl:template>
  
  <!-- 
  Matching of outputed elements

  Default is all, till we are sure that all xsl:* are handled
  Will be handled in better layout by xml2html.xsl
  -->
  <xsl:template match="*">
    <xsl:apply-templates select="." mode="xml:html"/>
  </xsl:template>
  <!-- override the template for nested content of an element, 
continue in default mode for the templates of this sheet -->
  <xsl:template name="xml:content">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="text()[normalize-space(.)='']"/>
</xsl:transform>
