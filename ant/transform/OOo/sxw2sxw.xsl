<?xml version="1.0" encoding="UTF-8"?>
<!--
 = WHAT =

Normalize a deflat OOo.sxw doc, for now in ant context only.
(should be adapted in cocoon context). Apply to a content.xml

 = WHO =

 [FG] "Frédéric Glorieux" <frederic.glorieux@xfolio.org>

 = HOW =


 = CHANGES =

 * 2004-10-29 [FG] creation

 = REFERENCES =  


-->
<xsl:transform version="1.1" xmlns:style="http://openoffice.org/2000/style" xmlns:text="http://openoffice.org/2000/text" xmlns:office="http://openoffice.org/2000/office" xmlns:table="http://openoffice.org/2000/table" xmlns:draw="http://openoffice.org/2000/drawing" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:meta="http://openoffice.org/2000/meta" xmlns:OOoMeta="http://openoffice.org/2000/meta" xmlns:number="http://openoffice.org/2000/datastyle" xmlns:svg="http://www.w3.org/2000/svg" xmlns:chart="http://openoffice.org/2000/chart" xmlns:dr3d="http://openoffice.org/2000/dr3d" xmlns:math="http://www.w3.org/1998/Math/MathML" xmlns:OOoStyleName="http://openoffice.org/2000/style#name" xmlns:form="http://openoffice.org/2000/form" xmlns:script="http://openoffice.org/2000/script" xmlns:config="http://openoffice.org/2001/config" office:class="text" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" exclude-result-prefixes="office meta  table number fo xlink chart math script xsl draw svg dr3d form config text style">
  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
  <!-- TODO -->
  <xsl:param name="template.sxw"/>
  <xsl:param name="meta.xml"/>
  <xsl:param name="styles.xml"/>
  <!-- ROOT, could be changed -->
  <xsl:template match="/">
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
