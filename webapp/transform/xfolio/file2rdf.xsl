<?xml version="1.0" encoding="UTF-8"?>
<!--
creation=2004-01-27
modified=2004-01-27
author=frederic.glorieux@ajlsm.com
publisher=http://www.strabon.org

goal=
  provide a single DC record from multiple versions of a same document
  with links by language and format

-->
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dir="http://apache.org/cocoon/directory/2.0" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xi="http://www.w3.org/2001/XInclude" xmlns:cinclude="http://apache.org/cocoon/include/1.0" exclude-result-prefixes="dir xi cinclude">
  <xsl:import href="naming.xsl"/>
  <xsl:import href="../meta/xmp2dc.xsl"/>
  <xsl:output method="xml" indent="yes"/>
  <!-- extensions on which a DC record is expected to be include -->
  <xsl:param name="includes" select="' dbx sxw '"/>
  <!-- URI from which a server may answer a DC record -->
  <xsl:param name="context"/>
  <!-- prefix of your persistant URIs -->
  <xsl:param name="domain"/>
  <!-- branch of the file -->
  <xsl:param name="branch"/>
  <!-- an xsl processing instruction ? -->
  <xsl:param name="xsl"/>
  <!-- root -->
    <!--
<?xml-stylesheet type="text/xsl" href="**.xsl"?>
-->
  <xsl:template match="/*">
    <xsl:text>
</xsl:text>
    <xsl:if test="$xsl">
      <xsl:processing-instruction name="xml-stylesheet">
        <xsl:text>type="text/xsl" href="</xsl:text>
        <xsl:value-of select="$xsl"/>
        <xsl:text>"</xsl:text>
      </xsl:processing-instruction>
    </xsl:if>
    <rdf:RDF xml:base="{$domain}{$branch}">
      <rdf:Description>
        <xsl:apply-templates select="dir:file" mode="dc"/>
      </rdf:Description>
    </rdf:RDF>
  </xsl:template>
  <!--
 
for each file, pass a path in case of recursive crossing directory

-->
  <xsl:template match="dir:file" mode="dc">
    <xsl:param name="branch" select="$branch"/>
    <xsl:param name="name" select="@name"/>
    <xsl:param name="radical">
      <xsl:call-template name="getRadical">
        <xsl:with-param name="path" select="@name"/>
      </xsl:call-template>
    </xsl:param>
    <xsl:variable name="extension">
      <xsl:call-template name="getExtension">
        <xsl:with-param name="path" select="@name"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="lang">
      <xsl:call-template name="getLang">
        <xsl:with-param name="path" select="@name"/>
      </xsl:call-template>
    </xsl:variable>
    <!-- process nested elements first, could be xmp -->
    <xsl:apply-templates/>
    <!-- essentially for mediadir -->
<!--
    <xsl:apply-templates select="@*"/>
-->
    <!-- get meta from which we can expect an rdf version -->
    <xsl:choose>
      <!--
		TODO, may bug here
		-->
      <xsl:when test="contains($includes, concat(' ', $extension, ' '))">
        <!-- this xsl may provide an rdf result from more than one dc record -->
        <!--
this solution may be expensive, cross server

				<xsl:copy-of select="document(concat($context, $branch, substring-before(@name, '.'), '.dc'))/*/*/*"/>

cocoon:/ protocol buggy under cocoon2.0

        <xi:include href="{$context}{$branch}{substring-before(@name, '.')}.dc#xpointer(/*/*/*)"/>


This have produce strange bugs
				<cinclude:include src="cocoon:/{$path}{substring-before(@name, '.')}.dc"/>


-->
        <xsl:comment>
          <xsl:text>xi:include  </xsl:text>
          <xsl:value-of select="@name"/>
        </xsl:comment>
        <!-- xsl document is a afst solution to keep caching process -->
<!--
				<xsl:copy-of select="document(concat($context, $branch, substring-before(@name, '.'), '.dc'))/*/*/*"/>
-->
        <xi:include href="zip://content.xml@C:\xfolio\xfolio\doc\tests\perf\00.sxw"/>
				<xsl:copy-of select="document('zip://content.xml@C:\xfolio\xfolio\doc\tests\perf\00.sxw')"/>
      </xsl:when>
      <!--
case of jpg

This is a bad place to say it but let it for now ?
Should be in sitemap

-->
      <xsl:when test="$extension = 'jpg'">
        <dc:relation>
          <xsl:attribute name="xsi:type">
            <xsl:call-template name="getMime">
              <xsl:with-param name="path" select="@name"/>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:value-of select="concat($domain, $branch, @name)"/>
        </dc:relation>
        <dc:relation xsi:type="text/html">
          <xsl:value-of select="concat($domain, $branch, $radical, '.html')"/>
        </dc:relation>
      </xsl:when>
      <!-- identifier without meta -->
      <xsl:otherwise>
        <!-- this was used one day but can't remember for what
				<xsl:if test="not(../dir:file[contains(@name, $radical) 
	and contains(@name, '.')
	and contains($includes, substring-after(@name, '.')
	)]) or $short">
				</xsl:if>
				-->
        <dc:relation>
          <xsl:attribute name="xsi:type">
            <xsl:call-template name="getMime">
              <xsl:with-param name="path" select="@name"/>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:if test="$lang != ''">
            <xsl:attribute namespace="http://www.w3.org/XML/1998/namespace" name="lang">
              <xsl:value-of select="$lang"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:value-of select="concat($domain, $branch, @name)"/>
        </dc:relation>
      </xsl:otherwise>
    </xsl:choose>
    <dc:relation xsi:type="text/rdf">
      <xsl:if test="$lang != ''">
        <xsl:attribute namespace="http://www.w3.org/XML/1998/namespace" name="lang">
          <xsl:value-of select="$lang"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:value-of select="concat($domain, $branch, $radical, '.rdf')"/>
    </dc:relation>
    <!--
provide filename as last title, in hope of wikiName 
-->
    <dc:title xsi:type="filename">
      <xsl:value-of select="$radical"/>
    </dc:title>
    <dc:identifier xsi:type="filename">
      <xsl:value-of select="@name"/>
    </dc:identifier>
  </xsl:template>
  <!-- default : handle all attributes -->
  <xsl:template match="@* | @*[normalize-space(.)='']">
    <!-- unplug for now
		<xsl:comment>
			<xsl:value-of select="name()"/>
		</xsl:comment>
	-->
  </xsl:template>
  <!--

not used but kept as memory of text parsing
-->
  <xsl:template name="keywords">
    <xsl:param name="max" select="20"/>
    <xsl:param name="string" select="."/>
    <xsl:param name="separator">
      <xsl:choose>
        <xsl:when test="contains($string, ',')">,</xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="' '"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <xsl:choose>
      <xsl:when test="contains($string, $separator) and $max &gt;= 0">
        <dc:subject xsi:type="Iptc.{name()}">
          <xsl:value-of select="substring-before($string, $separator)"/>
        </dc:subject>
        <xsl:call-template name="keywords">
          <xsl:with-param name="string" select="substring-after($string, $separator)"/>
          <xsl:with-param name="separator" select="$separator"/>
          <xsl:with-param name="max" select="$max - 1"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <dc:subject xsi:type="Iptc.{name()}">
          <xsl:value-of select="$string"/>
        </dc:subject>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!--
	seems badly filled by lots of applications
	<xsl:template match="@Comment">
		<dc:description xsi:type="{name()}">
			<xsl:value-of select="."/>
		</dc:description>
	</xsl:template>
	-->
  <!-- 
TODO, get original date
-->
  <xsl:template match="@date">
    <dc:date xsi:type="modified">
      <xsl:value-of select="."/>
    </dc:date>
  </xsl:template>
  <!-- format -->
  <xsl:template match="@height"/>
  <xsl:template match="@width">
    <dc:format xsi:type="width-height">
      <xsl:apply-templates select="."/>
      <xsl:text>x</xsl:text>
      <xsl:apply-templates select="../@height"/>
      <xsl:text> pixels</xsl:text>
    </dc:format>
  </xsl:template>
</xsl:transform>
