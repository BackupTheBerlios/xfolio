<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="../html/xsl2html.xsl"?>
<!--
Label     : sxw-common.xsl
Title     : Different tools to transform sxw xml.
Copyright : © 2003, 2004, "ADNX" <http://adnx.org>.
Licence   : "CeCILL" <http://www.cecill.info/licences/Licence_CeCILL_V1.1-US.html> 
            ("GPL" <http://www.gnu.org/copyleft/gpl.html> like)
Creator   : [FG] "Frédéric Glorieux" <frederic.glorieux@ajlsm.com> 
            ("AJLSM" <http://ajlsm.org>)


 = What =

This sheet is a part of an sxw transformation pack. 
Resolution of links, specific to sxw, but shared between the formats.
Needs "naming utilities" <naming.xsl> to have extension, parent or other members of a path.

 = TODO =

Simplify import

  -->
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:style="http://openoffice.org/2000/style" xmlns:text="http://openoffice.org/2000/text" xmlns:office="http://openoffice.org/2000/office" xmlns:table="http://openoffice.org/2000/table" xmlns:draw="http://openoffice.org/2000/drawing" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:meta="http://openoffice.org/2000/meta" xmlns:number="http://openoffice.org/2000/datastyle" xmlns:svg="http://www.w3.org/2000/svg" xmlns:chart="http://openoffice.org/2000/chart" xmlns:dr3d="http://openoffice.org/2000/dr3d" xmlns:math="http://www.w3.org/1998/Math/MathML" xmlns:form="http://openoffice.org/2000/form" xmlns:script="http://openoffice.org/2000/script" xmlns:config="http://openoffice.org/2001/config" office:class="text" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:i18n="http://apache.org/cocoon/i18n/2.1" exclude-result-prefixes="office meta  table number dc fo xlink chart math script xsl draw svg dr3d form config text style i18n">
  <!-- import of naming utilities -->
  <xsl:import href="../meta/naming.xsl"/>
  <!-- a path that could give the caller (? extracted from the doc ?) -->
  <xsl:param name="path">
    <xsl:choose>
      <xsl:when test="processing-instruction('path')">
        <xsl:value-of select="processing-instruction('path')"/>
      </xsl:when>
    </xsl:choose>
  </xsl:param>
  <!-- folder where to find pictures -->
  <xsl:param name="pictures">
    <xsl:choose>
      <xsl:when test="processing-instruction('pictures')">
        <xsl:value-of select="processing-instruction('pictures')"/>
      </xsl:when>
      <xsl:when test="$path">
        <xsl:call-template name="getBasename">
          <xsl:with-param name="path" select="$path"/>
        </xsl:call-template>
        <xsl:text>/</xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:param>
  <!-- get extension of the possible desired target path -->
  <xsl:variable name="extension-path">
    <xsl:call-template name="getExtension">
      <xsl:with-param name="path" select="$path"/>
    </xsl:call-template>
  </xsl:variable>
    <!-- extension on which continue relative links
take care that this transform could be used to generate html
but also see directly xml
 -->
  <xsl:param name="extension">
    <xsl:choose>
      <xsl:when test="processing-instruction('extension')">
        <xsl:value-of select="processing-instruction('extension')"/>
      </xsl:when>
      <xsl:when test="normalize-space($extension-path) != ''">
        <xsl:value-of select="$extension-path"/>
      </xsl:when>
      <!-- which default extension ? html ? -->
      <xsl:otherwise>html</xsl:otherwise>
    </xsl:choose>
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
    <!-- extension of the dest link -->
    <xsl:variable name="destExtension">
      <xsl:call-template name="getExtension">
        <xsl:with-param name="path" select="."/>
      </xsl:call-template>
    </xsl:variable>
    <!-- anchor -->
    <xsl:variable name="anchor">
      <xsl:choose>
        <xsl:when test="not(contains(., '#'))"/>
        <xsl:when test="contains(substring-after(., '#'), '%7Coutline')
and contains(substring-after(., '#'), '%20')        
        ">
          <xsl:text>#</xsl:text>
          <xsl:value-of select="substring-before(substring-after(., '#'), '.%20')"/>
        </xsl:when>
        <xsl:when test="contains(substring-after(., '#'), '%7Ctable')">
          <xsl:text>#</xsl:text>
          <xsl:value-of select="substring-before(substring-after(., '#'), '%7Ctable')"/>
        </xsl:when>
        <xsl:when test="contains(substring-after(., '#'), '%7Cgraphic')">
          <xsl:text>#</xsl:text>
          <xsl:value-of select="substring-before(substring-after(., '#'), '%7Cgraphic')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>#</xsl:text>
          <xsl:value-of select="substring-after(., '#')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- the path without extension -->
    <xsl:variable name="basepath">
      <xsl:call-template name="getBasepath">
        <xsl:with-param name="path" select="."/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="false()"/>
      <!-- probably an absolute URI -->
      <xsl:when test="contains(.,'//')">
        <xsl:value-of select="."/>
      </xsl:when>
      <!-- relative link to another sxw file, or from a word document
 should also be transformed -->
      <xsl:when test="$destExtension = 'sxw' or $destExtension = 'doc'">
        <xsl:value-of select="$basepath"/>
        <xsl:if test="normalize-space($extension) != ''">.</xsl:if>
        <xsl:value-of select="$extension"/>
        <xsl:value-of select="$anchor"/>
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
