<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:error="http://apache.org/cocoon/error/2.1" xmlns:dir="http://apache.org/cocoon/directory/2.0" xmlns:htm="http://www.w3.org/1999/xhtml">
  <xsl:param name="context"/>
  <xsl:template match="/aggregate">
    <!-- one day in skin ? -->
    <xsl:apply-templates select="content/htm:html"/>
  </xsl:template>
  <xsl:template match="htm:select[@name='skin']">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <option/>
      <xsl:for-each select="//dir:directory[@name='skin']/*">
        <option>
          <xsl:value-of select="@name"/>
        </option>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
