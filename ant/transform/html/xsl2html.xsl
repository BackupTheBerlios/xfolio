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
  <!-- different interesting tools for the fast test view -->
  <xsl:import href="html-common.xsl"/>
  <!-- import to format the text comments -->
  <xsl:import href="text2html.xsl"/>
  <!-- the output declaration -->
  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
  <!-- messages -->

  <xsl:template match="/">
    <xsl:call-template name="html"/>
  </xsl:template>
  
  <xsl:template name="html">
    <html>
      <head>
        <title>TODO</title>
        <!--
        <xsl:call-template name="head-common"/>
        -->
      </head>
      <xsl:call-template name="body"/>
    </html>
  </xsl:template>
  
  
  <xsl:template name="body">
    <body>
      <xsl:apply-templates select="comment()" mode="text2html"/>
      <xsl:apply-templates select="xsl:stylesheet | xsl:transform"/>
    </body>
  </xsl:template>
  
  <xsl:template match="xsl:stylesheet | xsl:transform">
    <!-- header -->
    <!-- TODOs -->
    <xsl:if test="contains(.//comment(), ' TODO ')">
      <h1>TODOs</h1>
      
    </xsl:if>
    <!-- templates -->
    <table>
      <caption><h1>Templates</h1></caption>
      <thead>
        <tr>
          <th>name</th>
          <th>parameters</th>
          <th>description</th>
        </tr>
      </thead>
      <tbody>
        <xsl:apply-templates select="xsl:template[@name]">
          <xsl:sort select="@name"/>
        </xsl:apply-templates>
      </tbody>
      <thead>
        <tr>
          <th>mode</th>
          <th>match</th>
          <th>description</th>
        </tr>
      </thead>
      <tbody>
        <xsl:apply-templates select="xsl:template[@match]">
          <xsl:sort select="@mode"/>
          <xsl:sort select="@match"/>
        </xsl:apply-templates>
      </tbody>
    </table>
    <!-- output elements -->
    <!-- output messages -->
    <!-- source -->
  </xsl:template>

  <xsl:template match="xsl:template[@name]">
    <tr>
      <th>
        <xsl:value-of select="@name"/>
      </th>
      <td>
        <xsl:apply-templates select="xsl:parameter"/>
      </td>
      <td>
<xsl:value-of select="generate-id(preceding-sibling::node()[1])"/>
<xsl:value-of select="generate-id(preceding-sibling::*[1])"/>
        <xsl:if test="
generate-id(preceding-sibling::node()[1]) = generate-id(preceding-sibling::comment()[1])
                      ">
           <xsl:apply-templates select="preceding-sibling::comment()[1]" mode="text2html"/>
        </xsl:if>
      </td>
    </tr>
  </xsl:template>

  <!-- named templates -->
  <xsl:template match="xsl:template[@match]">
    <tr>
      <th>
        <xsl:value-of select="@mode"/>
      </th>
      <td>
        <xsl:apply-templates select="@match"/>
      </td>
      <td>
<xsl:value-of select="generate-id(preceding-sibling::node()[1])"/>
<xsl:value-of select="name(preceding-sibling::node()[1])"/>
      
        <xsl:if test="
generate-id(preceding-sibling::node()[1]) = generate-id(preceding-sibling::comment()[1])
                      ">
           <xsl:apply-templates select="preceding-sibling::comment()[1]" mode="text2html"/>
        </xsl:if>
      </td>
    </tr>
  </xsl:template>

  <!-- 
parameters 
<xsl:param name="?" select="?"/>
-->
  <xsl:template match="xsl:param">
    <xsl:value-of select="@name"/>
    
  </xsl:template>
</xsl:transform>
