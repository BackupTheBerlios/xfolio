<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="../html/xsl2html.xsl"?>
<!--

(c) 2004 ADNX <http://adnx.org>
  
  = WHAT =

Normalize a deflat OOo.sxw doc, for now in ant context only.
(should be adapted in cocoon context). Apply to a content.xml

  = WHO =

 [FG] "Frédéric Glorieux" <frederic.glorieux@ajlsm.com>

  = FEATURES =

 * aggregate XML files from an sxw pack
 * add an XSL declaration to the generated XML
 * add some convenient processing-instruction() for future transformations (css, js...)

  = MAYDO =

 * normalize heading levels in case of splitted docs
 * apply a template 
    1) styles.xml (copy)
    2) meta.xml (merge)
    3) content.xml (insert : header, footer)

  = CHANGES =

 * 2004-11-05 [FG] xsl declaration
 * 2004-10-29 [FG] creation

  = REFERENCES =  


-->
<xsl:transform version="1.1" xmlns:style="http://openoffice.org/2000/style" xmlns:text="http://openoffice.org/2000/text" xmlns:office="http://openoffice.org/2000/office" xmlns:table="http://openoffice.org/2000/table" xmlns:draw="http://openoffice.org/2000/drawing" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:meta="http://openoffice.org/2000/meta" xmlns:OOoMeta="http://openoffice.org/2000/meta" xmlns:number="http://openoffice.org/2000/datastyle" xmlns:svg="http://www.w3.org/2000/svg" xmlns:chart="http://openoffice.org/2000/chart" xmlns:dr3d="http://openoffice.org/2000/dr3d" xmlns:math="http://www.w3.org/1998/Math/MathML" xmlns:OOoStyleName="http://openoffice.org/2000/style#name" xmlns:form="http://openoffice.org/2000/form" xmlns:script="http://openoffice.org/2000/script" xmlns:config="http://openoffice.org/2001/config" office:class="text" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" exclude-result-prefixes="office meta  table number fo xlink chart math script xsl draw svg dr3d form config text style">
  <xsl:import href="sxw-common.xsl"/>
  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
  <!-- TODO, what about a template ? -->
  <xsl:param name="template.sxw"/>
  <xsl:param name="meta.xml"/>
  <xsl:param name="styles.xml"/>
  <!-- an URI to an XSL transform for browsers -->
  <xsl:param name="xsl"/>
  <!-- a contextual path for this doc
maybe absolute URI or relative to a root folder
 -->
  <xsl:param name="path"/>
  <!-- a base URI where to find embed pictures -->
  <xsl:param name="pictures"/>
  <!-- an URI where to find css for an HTML transform -->
  <xsl:param name="css"/>
  <!-- extension of the generated doc, useful to resolve relative links -->
  <xsl:param name="extension">
    <xsl:choose>
      <xsl:when test="$path">
        <xsl:call-template name="getExtension">
          <xsl:with-param name="path" select="$path"/>
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>
  </xsl:param>
  <!-- ROOT -->
  <xsl:template match="/">
    <!-- add some processing instructions to produce a useful xml -->
		<xsl:if test="$xsl">
      <xsl:text>
</xsl:text>
			<xsl:processing-instruction name="xml-stylesheet">
				<xsl:text>type="text/xsl" href="</xsl:text>
        <xsl:call-template name="getRelative">
          <xsl:with-param name="from" select="$path"/>
          <xsl:with-param name="to" select="$xsl"/>
        </xsl:call-template>
				<xsl:text>"</xsl:text>
			</xsl:processing-instruction>
		</xsl:if>
		<xsl:if test="$pictures">
      <xsl:text>
</xsl:text>
      <xsl:processing-instruction name="pictures">
        <xsl:value-of select="$pictures"/>
      </xsl:processing-instruction>
		</xsl:if>
		<xsl:if test="$css">
      <xsl:text>
</xsl:text>
      <xsl:processing-instruction name="css">
        <xsl:value-of select="$css"/>
      </xsl:processing-instruction>
		</xsl:if>
		<xsl:if test="$path">
      <xsl:text>
</xsl:text>
      <xsl:processing-instruction name="path">
        <xsl:value-of select="$path"/>
      </xsl:processing-instruction>
		</xsl:if>
    <office:document>
      <xsl:if test="$meta.xml">
        <xsl:apply-templates select="document($meta.xml, .)/*"/>
      </xsl:if>
      <xsl:if test="$styles.xml">
        <xsl:apply-templates select="document($styles.xml, .)/*"/>
      </xsl:if>
      <xsl:apply-templates/>
    </office:document>
  </xsl:template>
  <!-- in case of apply to content.xml -->
  <xsl:template match="office:document-content | office:document-meta | office:document-styles | office:document-settings">
    <xsl:apply-templates/>
  </xsl:template>
  <!-- default copy all -->
  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>    
  
</xsl:transform>
