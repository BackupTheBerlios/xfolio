<?xml version="1.0" encoding="UTF-8"?>
<!--
(c) 2003, 2004; ADNX <http://adnx.org>

 = WHAT =

Resolution of links, specific to sxw, but shared ebtween the formats.
Needs a naming.xsl import

 = WHO =

[FG] "Frédéric Glorieux" <frederic.glorieux@ajlsm.com>

  -->
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:style="http://openoffice.org/2000/style" xmlns:text="http://openoffice.org/2000/text" xmlns:office="http://openoffice.org/2000/office" xmlns:table="http://openoffice.org/2000/table" xmlns:draw="http://openoffice.org/2000/drawing" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:meta="http://openoffice.org/2000/meta" xmlns:number="http://openoffice.org/2000/datastyle" xmlns:svg="http://www.w3.org/2000/svg" xmlns:chart="http://openoffice.org/2000/chart" xmlns:dr3d="http://openoffice.org/2000/dr3d" xmlns:math="http://www.w3.org/1998/Math/MathML" xmlns:form="http://openoffice.org/2000/form" xmlns:script="http://openoffice.org/2000/script" xmlns:config="http://openoffice.org/2001/config" office:class="text" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:i18n="http://apache.org/cocoon/i18n/2.1" exclude-result-prefixes="office meta  table number dc fo xlink chart math script xsl draw svg dr3d form config text style i18n">
  <xsl:import href="naming.xsl"/>
  <!-- a path that could give the caller (? extracted from the doc ?) -->
  <xsl:param name="path"/>
  <!-- folder where to find pictures -->
  <xsl:param name="pictures">
    <xsl:call-template name="getRadical">
      <xsl:with-param name="path" select="$path"/>
    </xsl:call-template>
    <xsl:text>/</xsl:text>
  </xsl:param>
  <!-- no indent to preserve design -->
  <xsl:output method="xml" encoding="UTF-8"/>
  <!-- 
These variables are used to normalize names of styles
-->
  <xsl:variable name="majs" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZÀÁÂÃÄÅÆÈÉÊËÌÍÎÏÐÑÒÓÔÕÖÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõöùúûüýÿþ .()/\?'"/>
  <xsl:variable name="mins" select="'abcdefghijklmnopqrstuvwxyzaaaaaaaeeeeiiiidnooooouuuuybbaaaaaaaceeeeiiiionooooouuuuyyb------'"/>
  <!-- image links could be in the draw:a -->
  <!-- global redirection of links -->
  <xsl:template match="@xlink:href | @href">
    <xsl:choose>
      <xsl:when test="false()"/>
      <xsl:when test="not(contains(.,'//')) and contains(., '.sxw')">
        <xsl:value-of select="concat(substring-before(., '.sxw'), '.html')"/>
        <xsl:value-of select="substring-after(., '.sxw')"/>
      </xsl:when>
      <xsl:when test="not(contains(.,'//')) and contains(., '.doc')">
        <xsl:value-of select="concat(substring-before(., '.doc'), '.html')"/>
        <xsl:value-of select="substring-after(., '.sxw')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- 
	template to resolve internal image links 

shared with meta rdf
-->
  <xsl:template match="draw:image/@xlink:href">
    <xsl:variable name="path" select="."/>
    <xsl:choose>
      <xsl:when test="contains($path, '#Pictures/')">
        <xsl:value-of select="concat($pictures, substring-after($path, '#Pictures/'))"/>
      </xsl:when>
      <xsl:when test="not(contains($path, 'http://'))">
        <xsl:value-of select="$path"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!--

	get a semantic style name 
	 - CSS compatible (no space, all min) 
	 - from automatic styles 

-->
  <xsl:template match="@text:style-name | @draw:style-name | @draw:text-style-name | @table:style-name">
    <xsl:variable name="current" select="."/>
    <xsl:choose>
      <xsl:when test="
//office:automatic-styles/style:style[@style:name = $current]
">
        <!-- can't understand why but sometimes there's a confusion 
				between automatic styles with footer, same for header, fast patch here -->
        <xsl:value-of select="
translate(//office:automatic-styles/style:style[@style:name = $current][@style:parent-style-name!='Header'][@style:parent-style-name!='Footer']/@style:parent-style-name
, $majs, $mins)
"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="translate($current , $majs, $mins)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
