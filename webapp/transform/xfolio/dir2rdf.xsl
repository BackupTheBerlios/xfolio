<?xml version="1.0" encoding="UTF-8"?>
<!--
creation:
	2004-01-27
modified:
	2004-02-10
creator:
	frederic.glorieux@ajlsm.com
publisher:
	http://www.strabon.org

goal:
  crawl a list of i18n files and directories, to include dc:property from an RDF

logic:

-->
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dir="http://apache.org/cocoon/directory/2.0"  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" exclude-result-prefixes="dir">
  <xsl:import href="naming.xsl"/>
  <xsl:import href="file2rdf.xsl"/>
  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
  <!-- prefix of your persistant URIs -->
  <xsl:param name="domain"/>
  <!-- branch of the file -->
  <xsl:param name="branch"/>
  <xsl:param name="depth" select="1"/>
  <!-- default file of a directory -->
  <xsl:param name="index" select="'index'"/>
  <xsl:template match="/" priority="1">
    <!--
		<xsl:processing-instruction name="xml-stylesheet">
			<xsl:text>type="text/xsl" href="/stylesheets/meta/dir2html.xsl"</xsl:text>
		</xsl:processing-instruction>
-->
    <rdf:RDF xsi:type="directory" xml:base="{$domain}{$branch}">
      <xsl:apply-templates>
        <xsl:with-param name="depth" select="$depth"/>
      </xsl:apply-templates>
    </rdf:RDF>
  </xsl:template>
  <!--

	dir:directory

-->
  <!-- default, keep all directories (prune empties)  -->
  <xsl:template match="dir:directory"/>
  <!-- take all directories with files -->
  <xsl:template match="dir:directory[dir:file | dir:directory]">
    <xsl:param name="branch" select="$branch"/>
    <xsl:param name="depth"/>
    <!-- correct case of root directory -->
    <xsl:variable name="name">
      <xsl:choose>
        <xsl:when test="not(ancestor::dir:directory)"/>
        <xsl:otherwise>
          <xsl:value-of select="concat(@name, '/')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <rdf:Description rdf:about="{$name}">
      <!-- 
	count items, one for each document (in any formats and languages 
let it for full table of contents 
feature better optimized with a db:xml
-->
      <!--
				<dc:format xsi:type="count">

					<xsl:value-of select="count(
.//dir:file [../dir:file[starts-with(@name, '&index;')]]  
[
	(contains(@name, '_') and contains(@name, '.') 
		and not(contains(preceding-sibling::dir:file/@name, substring-before(@name, '_')))  
	)
  or ( not(contains(@name, '_')) and contains(@name, '.') 
  		and not(contains(preceding-sibling::dir:file/@name, substring-before(@name, '.')))  
  	)
	or ( not(contains(@name, '_')) and not(contains(@name, '.')))
]
)"/>
				</dc:format>
-->
      <xsl:choose>
        <xsl:when test="dir:file[starts-with(@name, 'index')]">
          <xsl:apply-templates select="dir:file[starts-with(@name, 'index')]" mode="dc">
            <xsl:with-param name="branch" select="concat($branch, $name)"/>
          </xsl:apply-templates>
        </xsl:when>
        <xsl:when test="dir:file">
          <xsl:apply-templates select="dir:file[1]" mode="dc">
            <xsl:with-param name="branch" select="concat($branch, $name)"/>
          </xsl:apply-templates>
        </xsl:when>
      </xsl:choose>
      <!-- last chance title -->
      <dc:title xsi:type="filename">
        <xsl:value-of select="@name"/>
      </dc:title>
      <dc:identifier xsi:type="filename">
        <xsl:value-of select="concat($domain, $branch, $name)"/>
      </dc:identifier>
    </rdf:Description>
    <!--
	TODO : toc CAUTION will not work ! (repeated index or first file)
-->
    <xsl:if test="$depth &gt; 0">
      <xsl:choose>
        <!-- index already handled -->
        <xsl:when test="dir:file[starts-with(@name, 'index')]">
          <xsl:apply-templates select="*[not(starts-with(@name, $index))]">
            <xsl:with-param name="branch" select="concat($branch, $name)"/>
            <xsl:with-param name="depth" select="$depth - 1"/>
          </xsl:apply-templates>
        </xsl:when>
        <!-- first already given as default -->
        <xsl:otherwise>
          <xsl:apply-templates select="dir:directory|dir:file[preceding-sibling::dir:file]">
            <xsl:with-param name="branch" select="concat($branch, $name)"/>
            <xsl:with-param name="depth" select="$depth - 1"/>
          </xsl:apply-templates>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>
  <!-- 


a file  



-->
  <xsl:template match="dir:file">
    <xsl:param name="branch" select="$branch"/>
    <xsl:param name="radical">
      <xsl:call-template name="getRadical">
        <xsl:with-param name="path" select="@name"/>
      </xsl:call-template>
    </xsl:param>
    <xsl:comment>
      <xsl:value-of select="@name"/>
    </xsl:comment>
    <xsl:choose>
      <xsl:when test="preceding-sibling::dir:file[starts-with(@name, $radical)]"/>
      <xsl:otherwise>
        <rdf:Description rdf:about="{$radical}">
          <xsl:apply-templates select="../dir:file[starts-with(@name, $radical)]" mode="dc">
            <xsl:with-param name="branch" select="$branch"/>
          </xsl:apply-templates>
        </rdf:Description>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:transform>
