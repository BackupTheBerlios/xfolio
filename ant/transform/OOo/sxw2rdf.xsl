<?xml version="1.0" encoding="UTF-8"?>
<!--


 = WHAT =

provide the best set of Dublin Core properties from an OpenOffice.org
writer document. This transformation is tested under different contexts
 * OOo export filter
 * Cocoon transformer step
 * Ant task
Should be applied to an XML file with office:body

 = WHO =

 [FG] "Frédéric Glorieux" <frederic.glorieux@xfolio.org>


 = HOW =

The root template produce an RDF document with the DC properties
Single DC properties may be accessed by global xsl:param
A template "metas" give an HTML version of this properties.
This template may be externalize in a specific rdf2meta ?

 = CHANGES =

 * 2004-06-28:FG better linking resolving
The metas could be used separated for other usages.
These transformation was extracted from a global oo2html
 * 2004-O1-27 [FG]  creation from an OOo2html.xsl


 = TODO =  

may be used for other target namespace DC compatible
what about a default properties document ?
format in arabic

 = BUGS =

seems to bug with xalan under cocoon in creator template

 = REFERENCES =  

http://www.w3.org/TR/xhtml2/abstraction.html#dt_MediaDesc

-->
<xsl:transform version="1.1" xmlns:style="http://openoffice.org/2000/style" xmlns:text="http://openoffice.org/2000/text" xmlns:office="http://openoffice.org/2000/office" xmlns:table="http://openoffice.org/2000/table" xmlns:draw="http://openoffice.org/2000/drawing" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:meta="http://openoffice.org/2000/meta" xmlns:number="http://openoffice.org/2000/datastyle" xmlns:svg="http://www.w3.org/2000/svg" xmlns:chart="http://openoffice.org/2000/chart" xmlns:dr3d="http://openoffice.org/2000/dr3d" xmlns:math="http://www.w3.org/1998/Math/MathML" xmlns:form="http://openoffice.org/2000/form" xmlns:script="http://openoffice.org/2000/script" xmlns:config="http://openoffice.org/2001/config" office:class="text" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" exclude-result-prefixes="office table number fo xlink chart math script xsl draw svg dr3d form config">
  <!--
  <xsl:import href="../xfolio/naming.xsl"/>
  <xsl:import href="oo2html.xsl"/>
-->
  <xsl:import href="naming.xsl"/>
  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
  <xsl:variable name="office:meta" select=".//office:meta"/>
  <xsl:variable name="office:automatic-styles" select=".//office:automatic-styles"/>
  <xsl:variable name="office:body" select=".//office:body"/>
  <!-- maydo, get an RDF template for absent properties -->
  <xsl:param name="template.rdf"/>
  <xsl:variable name="template"/>
  <!-- used to resolve links for images (?) -->
  <!-- identifier for doc in all formats -->
  <xsl:param name="identifier"/>
  <!-- extensions from which a transformation is expected -->
  <xsl:param name="extensions"/>
  <!-- 
FG:2004-06-10

  language logic.
  
  DC property may be precised by an @xml:lang attribute.
  Priority order of the information
   - filename
   - meta oo

	important, don't let an empty attribute

	-->
  <xsl:param name="language">
    <xsl:if test="$identifier">
      <xsl:call-template name="getLang">
        <xsl:with-param name="path" select="$identifier"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:param>
  <xsl:param name="lang">
    <xsl:choose>
      <xsl:when test="normalize-space($language) != ''">
        <xsl:value-of select="$language"/>
      </xsl:when>
      <xsl:otherwise>
        <!-- unsure for authors writing different languages with same app -->
        <xsl:value-of select="$office:meta/dc:language"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>
  <xsl:param name="publisher"/>
  <xsl:param name="copyright"/>
  <!-- in case of more precise typing -->
  <xsl:param name="type" select="'text'"/>
  <!-- 
These variables are used to normalize style names of styles
-->
  <xsl:variable name="majs" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZÀÁÂÃÄÅÆÈÉÊËÌÍÎÏÐÑÒÓÔÕÖÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõöùúûüýÿþ .()/\?'"/>
  <xsl:variable name="mins" select="'abcdefghijklmnopqrstuvwxyzaaaaaaaeeeeiiiidnooooouuuuybbaaaaaaaceeeeiiiionooooouuuuyyb------'"/>
  <!--


-->
  <xsl:template match="/">
    <rdf:RDF>
      <rdf:Description>
        <xsl:call-template name="dc:properties"/>
      </rdf:Description>
    </rdf:RDF>
  </xsl:template>
  <!--

Properties are ordered in this template 
(each source are not equally significant)


-->
  <xsl:template name="dc:properties">
    <!-- process properties from meta form (office:meta) more significant than in doc -->
    <!-- first title, get the one one from meta (to be a short title) -->
    <xsl:apply-templates select="$office:meta/dc:title"/>
    <xsl:apply-templates select="$office:meta/dc:subject"/>
    <xsl:apply-templates select="$office:meta/meta:keywords"/>
    <!-- dc:description, more than one is not a problem -->
    <xsl:apply-templates select="$office:meta/dc:description"/>
    <!-- process body blocks before the first title -->
    <xsl:variable name="next" select="$office:body/text:h[1]"/>
    <xsl:choose>
      <xsl:when test="not($next)">
        <xsl:apply-templates mode="dc" select="
$office:body/*
"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="dc" select="
$office:body/*[generate-id(following-sibling::text:h[1]) = generate-id($next)]
"/>
      </xsl:otherwise>
    </xsl:choose>
    <!-- relations -->
    <xsl:apply-templates select="$office:body//text:bibliography-mark" mode="dc"/>
    <xsl:apply-templates select="$office:body//draw:image" mode="dc"/>
    <!-- dates -->
    <xsl:apply-templates select="$office:meta/dc:date"/>
    <xsl:apply-templates select="$office:meta/meta:creation-date"/>
    <!-- server give an identifier for the doc, common to each lang and format -->
    <xsl:if test="$identifier">
      <dc:identifier>
        <xsl:call-template name="lang"/>
        <xsl:value-of select="$identifier"/>
      </dc:identifier>
    </xsl:if>
    <!-- mime/type  -->
    <dc:format xsi:type="dcterms:IMT">application/vnd.sun.xml.writer</dc:format>
    <!-- format as size -->
    <xsl:apply-templates select="meta:document-statistic"/>
    <!-- links for images -->
    <xsl:for-each select="//draw:image">
    </xsl:for-each>
    <!-- copyright -->
    <!--
      <dc:rights>
        <xsl:call-template name="lang"/>
        <xsl:value-of select="$copyright"/>
      </dc:rights>
    -->
  </xsl:template>
  <!--

Properties from meta.xml

-->
  <!-- title from meta form, to use as short title -->
  <xsl:template match="dc:title">
    <dc:title xsi:type="meta:title">
      <xsl:call-template name="lang"/>
      <xsl:apply-templates/>
    </dc:title>
  </xsl:template>
  <!-- main subject to index -->
  <xsl:template match="dc:subject">
    <dc:subject xsi:type="meta:subject">
      <xsl:call-template name="lang"/>
      <xsl:apply-templates/>
    </dc:subject>
  </xsl:template>
  <!-- treat comma separated subjects as different topics -->
  <xsl:template match="meta:keywords">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="meta:keyword">
    <dc:subject xsi:type="meta:keyword">
      <xsl:call-template name="lang"/>
      <xsl:apply-templates/>
    </dc:subject>
  </xsl:template>
  <!-- description from meta form -->
  <xsl:template match="dc:description">
    <dc:description xsi:type="meta:description">
      <xsl:call-template name="lang"/>
      <xsl:apply-templates/>
    </dc:description>
  </xsl:template>
  <!-- dates -->
  <xsl:template match="meta:creation-date | dc:date">
    <dc:date xsi:type="meta:{local-name()}">
      <xsl:call-template name="lang"/>
      <xsl:value-of select="substring-before(.,'T')"/>
    </dc:date>
  </xsl:template>
  <!-- meta user defined when not empty -->
  <xsl:template match="meta:user-defined">
    <xsl:if test="normalize-space(.)!=''">
      <meta name="{@meta:name}" content="{.}"/>
    </xsl:if>
  </xsl:template>
  <!-- do something with that ? -->
  <xsl:template match="meta:editing-cycles"/>
  <xsl:template match="meta:editing-duration"/>
  <!-- Creators from automatic metas may not express author will -->
  <xsl:template match="meta:initial-creator">
    <xsl:comment> This value maybe not desired from the author </xsl:comment>
    <dc:creator xsi:type="meta:creator">
      <xsl:call-template name="lang"/>
      <xsl:apply-templates/>
    </dc:creator>
  </xsl:template>
  <!--

Process document to extract DC properties

-->
  <!-- default, catch all -->
  <xsl:template match="node()" mode="dc"/>
  <!-- table, lists, section : continue -->
  <xsl:template match="text:unordered-list | text:ordered-list | text:list-item | table:table | table:table-row | table:table-cell" mode="dc">
    <xsl:apply-templates mode="dc"/>
  </xsl:template>
  <!-- blocks as meta properties -->
  <xsl:template match="text:p" mode="dc">
    <!-- get styles -->
    <xsl:variable name="prev">
      <xsl:apply-templates select="preceding-sibling::*[1]/@text:style-name"/>
    </xsl:variable>
    <xsl:variable name="style">
      <xsl:apply-templates select="@text:style-name"/>
    </xsl:variable>
    <xsl:variable name="next">
      <xsl:apply-templates select="following-sibling::*[1]/@text:style-name"/>
    </xsl:variable>
    <xsl:choose>
      <!-- FG:2004-06-17  careful when strip empty blocks, some can contain images -->
      <xsl:when test="normalize-space(.)='' and not(*[name()!='text:change'])"/>
      <!-- already handled -->
      <xsl:when test="text:title"/>
      <xsl:when test="contains ($style, 'title')">
        <dc:title>
          <xsl:call-template name="lang"/>
          <xsl:attribute name="xsi:type">
            <xsl:text>style:</xsl:text>
            <xsl:value-of select="$style"/>
          </xsl:attribute>
          <xsl:apply-templates/>
        </dc:title>
      </xsl:when>
      <xsl:when test="contains ($style, 'signature') or contains ($style, 'sender') or contains ($style, 'creator')">
        <dc:creator>
          <xsl:call-template name="persname"/>
        </dc:creator>
      </xsl:when>
      <xsl:when test="contains ($style, 'contributor')">
        <dc:contributor>
          <xsl:call-template name="persname"/>
        </dc:contributor>
      </xsl:when>
      <!-- TODO handle case of sibling style -->
      <xsl:when test="($prev != $style) and (contains ($style, 'description') or contains ($style, 'abstract'))">
        <dc:description>
          <xsl:call-template name="lang"/>
          <xsl:attribute name="xsi:type">
            <xsl:text>style:</xsl:text>
            <xsl:value-of select="$style"/>
          </xsl:attribute>
          <xsl:apply-templates/>
          <!-- TODO sibbling styles
          <xsl:if test="$next = $style">
            <xsl:apply-templates select="following-sibling::*[1]" mode="level2"/>
          </xsl:if>
          -->
        </dc:description>
      </xsl:when>
      <!-- do nothing -->
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:template>
  <!-- images -->
  <xsl:template match="draw:image" mode="dc">
    <xsl:variable name="path" select="@xlink:href"/>
    <xsl:variable name="link">
      <xsl:choose>
        <!-- rewrite internal image links -->
        <xsl:when test="contains($path, '#Pictures/')">
          <xsl:value-of select="$identifier"/>
          <xsl:text>.sxw/</xsl:text>
          <xsl:value-of select="substring-after($path, '#')"/>
        </xsl:when>
        <xsl:when test="not(contains($path, 'http://'))">
          <xsl:call-template name="getParent">
            <xsl:with-param name="path" select="$identifier"/>
          </xsl:call-template>
          <xsl:value-of select="$path"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$path"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <dc:relation>
      <xsl:attribute name="dc:format">
        <xsl:call-template name="getMime">
          <xsl:with-param name="path" select="$link"/>
        </xsl:call-template>
      </xsl:attribute>
      <xsl:call-template name="lang"/>
      <xsl:value-of select="$link"/>
    </dc:relation>
  </xsl:template>
  <!-- links -->
  <!-- 
bibliography 

TODO some processing of biblio may be useful elsewhere
-->
  <xsl:template match="text:bibliography-mark" mode="dc">
    <dc:source xsi:type="text:bibliography-mark">
      <xsl:apply-templates select="@*" mode="att"/>
      <xsl:apply-templates select="." mode="text"/>
    </dc:source>
  </xsl:template>
  <!-- process bibliographic attributes as pure text -->
  <xsl:template match="text:bibliography-mark" mode="text">
    <xsl:apply-templates select="@text:identifier" mode="text"/>
    <xsl:apply-templates select="@text:author" mode="text"/>
    <xsl:apply-templates select="@text:title" mode="text"/>
    <xsl:apply-templates select="@text:year" mode="text"/>
    <xsl:apply-templates select="@text:publisher" mode="text"/>
    <xsl:apply-templates select="@text:url" mode="text"/>
  </xsl:template>
  <xsl:template match="@*" mode="text"/>
  <xsl:template match="@text:identifier" mode="text">
    <xsl:text>[</xsl:text>
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:text>] </xsl:text>
  </xsl:template>
  <xsl:template match="@text:author" mode="text">
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:text>. </xsl:text>
  </xsl:template>
  <xsl:template match="@text:title" mode="text">
    <xsl:text>"</xsl:text>
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:text>" </xsl:text>
  </xsl:template>
  <xsl:template match="@text:year" mode="text">
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:text>, </xsl:text>
  </xsl:template>
  <xsl:template match="@text:publisher" mode="text">
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:text>. </xsl:text>
  </xsl:template>
  <xsl:template match="@text:url" mode="text">
    <xsl:text>&lt;</xsl:text>
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:text>&gt; </xsl:text>
  </xsl:template>
  <!-- process bibliographic attributes as attributes -->
  <xsl:template match="@*" mode="att"/>
  <xsl:template match="@text:identifier" mode="att">
    <xsl:attribute name="dc:identifier">
      <xsl:value-of select="normalize-space(.)"/>
    </xsl:attribute>
  </xsl:template>
  <xsl:template match="@text:isbn" mode="att">
    <xsl:attribute name="dc:identifier">
      <xsl:value-of select="normalize-space(.)"/>
    </xsl:attribute>
  </xsl:template>
  <xsl:template match="@text:title" mode="att">
    <xsl:attribute name="dc:title">
      <xsl:value-of select="normalize-space(.)"/>
    </xsl:attribute>
  </xsl:template>
  <xsl:template match="@text:author" mode="att">
    <xsl:attribute name="dc:creator">
      <xsl:value-of select="normalize-space(.)"/>
    </xsl:attribute>
  </xsl:template>
  <xsl:template match="@text:publisher" mode="att">
    <xsl:attribute name="dc:publisher">
      <xsl:value-of select="normalize-space(.)"/>
    </xsl:attribute>
  </xsl:template>
  <xsl:template match="@text:year" mode="att">
    <xsl:attribute name="dc:date">
      <xsl:value-of select="normalize-space(.)"/>
    </xsl:attribute>
  </xsl:template>
  <xsl:template match="@text:url" mode="att">
    <xsl:attribute name="rdf:resource">
      <xsl:value-of select="normalize-space(.)"/>
    </xsl:attribute>
  </xsl:template>
  <xsl:template match="@text:note" mode="att">
    <xsl:attribute name="dc:description">
      <xsl:value-of select="normalize-space(.)"/>
    </xsl:attribute>
  </xsl:template>
  <!--
this template restore some hierarchy for sibling style
here only description
  -->
  <xsl:template name="rdf-next" mode="rdf-next">
  
  </xsl:template>
  <!--
TODO:2004-05-11 better integration ?
	this template get a creator from user information
-->
  <xsl:template name="creator-fields">
    <xsl:value-of select="//text:sender-lastname"/>
    <xsl:if test="//text:sender-firstname">
      <xsl:text>, </xsl:text>
      <xsl:value-of select="//text:sender-firstname"/>
    </xsl:if>
    <xsl:if test="//text:sender-company">
      <xsl:text> (</xsl:text>
      <xsl:value-of select="//text:sender-company"/>
      <xsl:if test="//text:sender-country">
        <xsl:text>, </xsl:text>
        <xsl:value-of select="//text:sender-country"/>
      </xsl:if>
      <xsl:text>)</xsl:text>
    </xsl:if>
    <xsl:if test="//text:sender-email">
      <xsl:text> - </xsl:text>
      <xsl:value-of select="//text:sender-email"/>
    </xsl:if>
  </xsl:template>
  <!-- give size of a doc in different units, tooken from
		<meta:document-statistic meta:table-count="1" meta:image-count="0" meta:object-count="0" meta:page-count="11" meta:paragraph-count="326" meta:word-count="3405" meta:character-count="23617"/>
	-->
  <xsl:template match="meta:document-statistic">
    <dc:format xsi:type="meta:{local-name()}">
      <xsl:call-template name="lang"/>
      <xsl:value-of select="@meta:page-count"/>
      <xsl:text> pages : </xsl:text>
      <xsl:value-of select="@meta:word-count"/>
      <xsl:text> words, </xsl:text>
      <xsl:value-of select="@meta:character-count"/>
      <xsl:text> signs, </xsl:text>
      <xsl:value-of select="@meta:image-count"/>
      <xsl:text> images </xsl:text>
    </dc:format>
  </xsl:template>
  <!--
FG:2004-06-08
add relations to other formats

From a param provide by server of other supported export formats,
<dc:relation/> elements are generated
-->
  <xsl:template name="formats">
    <!-- normalize extensions to have always a substring-before ' ' -->
    <xsl:param name="extensions" select="concat(normalize-space($extensions), ' ')"/>
    <xsl:choose>
      <!-- no path, break here -->
      <xsl:when test="normalize-space($identifier) =''"/>
      <!-- no extensions, break here -->
      <xsl:when test="normalize-space($extensions) =''"/>
      <!-- more than one extension -->
      <xsl:otherwise>
        <xsl:variable name="extension" select="substring-before($extensions, ' ')"/>
        <xsl:variable name="mime">
          <xsl:call-template name="getMime">
            <xsl:with-param name="path" select="$extension"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="name">
          <xsl:call-template name="getName">
            <xsl:with-param name="path" select="$identifier"/>
          </xsl:call-template>
        </xsl:variable>
        <dc:relation dc:format="{$mime}" rdf:resource="{$name}.{$extension}">
          <xsl:call-template name="lang"/>
          <!-- relation maybe relative to identifier ? -->
          <xsl:value-of select="$identifier"/>
          <xsl:text>.</xsl:text>
          <xsl:value-of select="$extension"/>
        </dc:relation>
        <xsl:call-template name="formats">
          <xsl:with-param name="extensions" select="substring-after($extensions, ' ')"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- ==============================

Formatting of values

       ============================== -->
  <!-- call this from an element you presume to contain a persname value -->
  <xsl:template name="persname">
    <!-- copy the first link in creator -->
    <xsl:for-each select="*[@xlink:href][1]">
      <xsl:attribute name="rdf:resource">
        <xsl:apply-templates select="@xlink:href" mode="text"/>
      </xsl:attribute>
    </xsl:for-each>
    <!-- if complex creator key, normalize value in attribute -->
    <xsl:variable name="creator">
      <xsl:choose>
        <xsl:when test="contains(., '&lt;')">
          <xsl:value-of select="substring-before(., '&lt;')"/>
        </xsl:when>
        <xsl:when test="contains(., '(')">
          <xsl:value-of select="substring-before(., '(')"/>
        </xsl:when>
        <xsl:when test="contains(., ';')">
          <xsl:value-of select="substring-before(., ';')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:attribute name="dc:title">
      <xsl:value-of select="normalize-space(.)"/>
    </xsl:attribute>
    <xsl:value-of select="normalize-space($creator)"/>
  </xsl:template>
  <xsl:template match="*" mode="text">
    <xsl:apply-templates/>
  </xsl:template>
  <!-- link to text -->
  <xsl:template match="text:a" mode="text">
    <xsl:text>"</xsl:text>
    <xsl:text>" &lt;</xsl:text>
    <xsl:apply-templates select="xlink:href" mode="text"/>
    <xsl:text>&gt;</xsl:text>
  </xsl:template>
  <xsl:template match="@xlink:href" mode="text">
    <xsl:choose>
      <xsl:when test="starts-with(., 'mailto:') and contains(., '?')">
        <xsl:value-of select="substring-after(substring-before(., '?'), 'mailto:')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!--
FG: 2004-06-10

A centralized template to add @xml:lang attribute
-->
  <xsl:template name="lang">
    <xsl:if test="normalize-space($lang) != ''">
      <xsl:attribute namespace="http://www.w3.org/XML/1998/namespace" name="xml:lang">
        <xsl:value-of select="$lang"/>
      </xsl:attribute>
    </xsl:if>
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
  <!-- snippets to include
  <xsl:template match="tests" xmlns:date="xalan://java.util.Date" xmlns:encoder="xalan://java.net.URLEncoder"
     <xsl:value-of select="encoder:encode(string(test))"/>
     <xsl:value-of select="date:new()" />
  </xsl:template>
  -->
  <!-- default, keep meta section in normal processing -->
  <!-- try to catch paragraphs for meta, matching is complex
  because of lots of possible template implementation -->
  <!--
  <xsl:template match="text:section[@text:name='meta']"/>
  <xsl:template match="text:section[@text:name='meta']/*"/>

  <xsl:template match="text:p[@text:style-name='meta' 
  or .//*[@text:name='dc'] 
  or .//*[@text:name='dc'] 
  or .//*[@text:style-name='lang'] 
  or .//*[@text:name='lang']
  or .//*[@text:name='content' or @text:style-name='content' or @text:description='content']
  ]">
    <meta name="{normalize-space(.//*[@text:name='dc' or @text:style-name='dc'])}" lang="{normalize-space(.//*[@text:name='lang' or @text:style-name='lang'])}" scheme="{normalize-space(.//*[@text:name='scheme' or @text:style-name='scheme'])}">
      <xsl:attribute name="content">
        <xsl:variable name="content">
          <xsl:apply-templates select="
.//text:modification-date | .//text:creation-date | .//text:file-name
| 
.//*[@text:name='content' or @text:style-name='content' or @text:description='content']
          "/>
        </xsl:variable>
        <xsl:value-of select="normalize-space($content)"/>
      </xsl:attribute>
    </meta>
  </xsl:template>
-->
</xsl:transform>
