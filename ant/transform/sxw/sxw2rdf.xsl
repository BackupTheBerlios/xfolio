<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="../html/xsl2html.xsl"?>
<!--

Title     : Find metadatas in OpenOffice.org Writer XML
Label     : sxw2rdf.xsl
Copyright : © 2003, 2004, "ADNX" <http://adnx.org>.
Licence   : "CeCILL" <http://www.cecill.info/licences/Licence_CeCILL_V1.1-US.html> 
            ("GPL" <http://www.gnu.org/copyleft/gpl.html> like)
Creator   : [FG] "Frédéric Glorieux" <frederic.glorieux@ajlsm.com> 
            ("AJLSM" <http://ajlsm.org>)

 = What =

provide the best set of Dublin Core properties possible from an OpenOffice.org
writer document (sxw). This transformation is tested under different contexts
 * OOo export filter
 * "Cocoon" <http://cocoon.apache.org> transformer step (with "Saxon"
   <http://saxon.sourceforge.net/>)
 * "Ant" <http://ant.apache.org> task
Should be applied to an XML file with office:body


 = How =

The root template produce an RDF document with the DC properties
Single DC properties may be accessed by global xsl:param
A template "metas" give an HTML version of this properties.
This template may be externalize in a specific rdf2meta ?

 = Changes =

 * 2004-11-22 [FG] transfer same logic for html:meta
 * 2004-11-17 [FG] introduction of dcterms
 * 2004-06-28 [FG] better linking resolving
The metas could be used separated for other usages.
These transformation was extracted from a global oo2html
 * 2004-O1-27 [FG]  creation from an OOo2html.xsl


 = Ideas/tasks =  

 * dc:rights, dcterms:licence, dcterms:rightsHolder
 * an RDF-DC template with default value
 * dcterms:alternative << Title abbreviations as well as translations >>
 * dcterms:audience, dcterms:educationLevel (from style)
 * dcterms:bibliographicCitation (format a biblio citation from extracted properties)
 * dcterms:*date* (from styles, for thesis ?)

 = References =  

 * DCMI Metadata Terms. "DCMI Usage Board" <dc-usage@jiscmail.ac.uk>. 
   "The Dublin Core Metadata Initiative" <http://dublincore.org/>.
   <http://dublincore.org/documents/dcmi-terms/>
 * Expressing Dublin Core in HTML/XHTML meta and link elements.
   "Andy Powell" <a.powell@ukoln.ac.uk> (UKOLN, University of Bath).
   How Dublin Core metadata can be encoded in HTML/XHTML <meta> and <link> elements.
   <http://dublincore.org/documents/dcq-html/>
 * <http://www.w3.org/TR/xhtml2/mod-meta.html#s_metamodule>
 * [html:meta] <http://www.w3.org/TR/html4/struct/global.html#edef-META>
 * [html:link] <http://www.w3.org/TR/html4/struct/links.html#edef-LINK>
 * [html:linktypes] <http://www.w3.org/TR/html4/types.html#type-links>

-->
<xsl:transform version="1.1" 
  xmlns:style="http://openoffice.org/2000/style" 
  xmlns:text="http://openoffice.org/2000/text"
  xmlns:office="http://openoffice.org/2000/office"
  xmlns:table="http://openoffice.org/2000/table" 
  xmlns:draw="http://openoffice.org/2000/drawing" 
  xmlns:fo="http://www.w3.org/1999/XSL/Format" 
  xmlns:xlink="http://www.w3.org/1999/xlink" 
  xmlns:dc="http://purl.org/dc/elements/1.1/" 
  xmlns:meta="http://openoffice.org/2000/meta" 
  xmlns:number="http://openoffice.org/2000/datastyle" 
  xmlns:svg="http://www.w3.org/2000/svg" 
  xmlns:chart="http://openoffice.org/2000/chart" 
  xmlns:dr3d="http://openoffice.org/2000/dr3d" 
  xmlns:math="http://www.w3.org/1998/Math/MathML" 
  xmlns:form="http://openoffice.org/2000/form" 
  xmlns:script="http://openoffice.org/2000/script" 
  xmlns:config="http://openoffice.org/2001/config" 
  office:class="text" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
  xmlns:dcterms="http://purl.org/dc/terms/" 
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="
  office table number fo xlink chart math script xsl draw svg dr3d form config
  dc dcterms xsi style text meta rdf  
  ">
  <!-- naming util on filenames -->
  <xsl:import href="sxw-common.xsl"/>
  <xsl:import href="sxw2txt.xsl"/>
  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
  <!-- maydo, get an RDF template for absent properties -->
  <xsl:param name="template.rdf"/>
  <xsl:variable name="office:meta" select=".//office:meta"/>
  <xsl:variable name="office:automatic-styles" select=".//office:automatic-styles"/>
  <xsl:variable name="office:body" select=".//office:body"/>
  <!-- used to resolve links for images (?) -->
  <!-- identifier for doc in all formats -->
  <xsl:param name="path"/>
  <!-- extensions for which a transformation is expected -->
  <xsl:param name="formats"/>
  <!-- To generate absolute links -->
  <xsl:param name="server"/>
  <!-- Carriage return, can't understand why but this one works better than the one in sxw2txt.xsl -->
  <xsl:param name="CR">&#160;
</xsl:param>
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
    <xsl:if test="$path">
      <xsl:call-template name="getLang">
        <xsl:with-param name="path" select="$path"/>
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
  <xsl:template match="/">
    <xsl:call-template name="rdf"/>
  </xsl:template>
  <!-- 
A template to generate RDF with all namespace declaration needed
for children (especially for xsi:type Qname)
 -->
  <xsl:template name="rdf">
    <rdf:RDF   
    dc:xmlns="http://purl.org/dc/elements/1.1/" 
    xsi:xmlns="http://www.w3.org/2001/XMLSchema-instance"
    dcterms:xmlns="http://purl.org/dc/terms/" 
    meta:xmlns="http://openoffice.org/2000/meta" 
    text:xmlns="http://openoffice.org/2000/text" 
>
      <rdf:Description rdf:about="{$path}">
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
    <xsl:apply-templates select="$office:meta/dc:title" mode="dc"/>
    <xsl:apply-templates select="$office:meta/dc:subject" mode="dc"/>
    <xsl:apply-templates select="$office:meta/meta:keywords" mode="dc"/>
    <xsl:apply-templates select="$office:meta/meta:user-defined" mode="dc"/>
    <!-- dc:description, more than one is not a problem -->
    <xsl:apply-templates select="$office:meta/dc:description" mode="dc"/>
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
    <dcterms:tableOfContents>
      <xsl:apply-templates select="$office:body/text:h" mode="text-toc"/>
    </dcterms:tableOfContents>
    <!-- relations -->
    <xsl:apply-templates select="$office:body//text:bibliography-mark[not(@text:identifier = following::text:bibliography-mark/@text:identifier)]" mode="dc">
      <xsl:sort select="@text:identifier"/>
    </xsl:apply-templates>
    <!-- relative links -->
    <xsl:apply-templates select="$office:body//text:a" mode="dc"/>
    <!-- images -->
    <xsl:apply-templates select="$office:body//draw:image" mode="dc"/>
    <!-- dates -->
    <xsl:apply-templates select="$office:meta/dc:date" mode="dc"/>
    <xsl:apply-templates select="$office:meta/meta:creation-date" mode="dc"/>
    <!-- TODO identifier -->
    <xsl:call-template name="hasFormat"/>
    <!-- mime/type  -->
    <dc:format xsi:type="dcterms:IMT">application/vnd.sun.xml.writer</dc:format>
    <!-- format as size -->
    <xsl:apply-templates select="$office:meta/meta:document-statistic" mode="dc"/>
    <!-- copyright -->
    <!--
      <dc:rights>
        <xsl:call-template name="lang"/>
        <xsl:value-of select="$copyright"/>
      </dc:rights>
    -->
  </xsl:template>
  <!--
template to be called for an html generation
  -->
  <xsl:template name="metas">
    <!-- find a short title -->
    <title>
      <xsl:choose>
        <!-- 1) title in meta form -->
        <xsl:when test="$office:meta/dc:title[normalize-space(.)!='']">
          <xsl:value-of select="normalize-space($office:meta/dc:title[normalize-space(.)!=''])"/>
        </xsl:when>
        <!-- <text:p text:style-name="Title"/> -->
        <xsl:when test="$office:body/text:p[@text:style-name='Title'][normalize-space(.)!='']">
          <xsl:value-of select="
normalize-space($office:body/text:p[@text:style-name='Title'][normalize-space(.)!=''])
"/>
        </xsl:when>
        <!-- first text:h -->
        <xsl:when test="
$office:body/text:h[normalize-space(.)!='']
">
          <xsl:value-of select="
normalize-space($office:body/text:h[normalize-space(.)!=''])
"/>
        </xsl:when>
        <!-- TODO, a nice break long string on size max -->
        <xsl:otherwise>
          <xsl:value-of select="
substring( $office:body/text:p[string-length(normalize-space(.)) &gt; 10], 30)
"/>
        </xsl:otherwise>
      </xsl:choose>
    </title>
    <link rel="schema.DC" href="http://purl.org/dc/elements/1.1/" />
    <link rel="schema.DCTERMS" href="http://purl.org/dc/terms/" />
    <xsl:call-template name="hasFormat">
      <xsl:with-param name="mode" select="'html'"/>
    </xsl:call-template>
    <script type="application/rdf+xml">
      <xsl:call-template name="rdf"/>
    </script>

<!--
    <xsl:apply-templates select="$office:meta/dc:title" mode="dc"/>
    <xsl:apply-templates select="$office:meta/dc:subject" mode="dc"/>
    <xsl:apply-templates select="$office:meta/meta:keywords" mode="dc"/>
    <xsl:apply-templates select="$office:meta/meta:user-defined" mode="dc"/>
    <xsl:apply-templates select="$office:meta/dc:description" mode="dc"/>
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
    <dcterms:tableOfContents>
      <xsl:apply-templates select="$office:body/text:h" mode="text-toc"/>
    </dcterms:tableOfContents>
    <xsl:apply-templates select="$office:body//text:bibliography-mark[not(@text:identifier = following::text:bibliography-mark/@text:identifier)]" mode="dc">
      <xsl:sort select="@text:identifier"/>
    </xsl:apply-templates>
    <xsl:apply-templates select="$office:meta/dc:date" mode="dc"/>
    <xsl:apply-templates select="$office:meta/meta:creation-date" mode="dc"/>
    <xsl:call-template name="hasFormat"/>
    <dc:format xsi:type="dcterms:IMT">application/vnd.sun.xml.writer</dc:format>
    <xsl:apply-templates select="$office:meta/meta:document-statistic" mode="dc"/>
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
  <xsl:template match="dc:title" mode="dc">
    <dc:title xsi:type="meta:title">
      <xsl:call-template name="lang"/>
      <xsl:apply-templates/>
    </dc:title>
  </xsl:template>
  <!-- main subject to index -->
  <xsl:template match="dc:subject" mode="dc">
    <dc:subject xsi:type="meta:subject">
      <xsl:call-template name="lang"/>
      <xsl:apply-templates/>
    </dc:subject>
  </xsl:template>
  <!-- treat comma separated subjects as different topics -->
  <xsl:template match="meta:keywords" mode="dc">
    <xsl:apply-templates mode="dc"/>
  </xsl:template>
  <xsl:template match="meta:keyword" mode="dc">
    <dc:subject xsi:type="meta:keyword">
      <xsl:call-template name="lang"/>
      <xsl:apply-templates/>
    </dc:subject>
  </xsl:template>
  <!-- description from meta form -->
  <xsl:template match="dc:description" mode="dc">
    <dc:description>
      <xsl:call-template name="lang"/>
      <xsl:apply-templates/>
    </dc:description>
  </xsl:template>
  <!-- dates -->
  <xsl:template match="dc:date" mode="dc">
    <dc:date>
      <xsl:call-template name="lang"/>
      <xsl:value-of select="substring-before(.,'T')"/>
    </dc:date>
  </xsl:template>
  <xsl:template match="meta:creation-date" mode="dc">
    <dcterms:created>
      <xsl:call-template name="lang"/>
      <xsl:value-of select="substring-before(.,'T')"/>
    </dcterms:created>
  </xsl:template>
  <!-- meta user defined when not empty -->
  <xsl:template match="meta:user-defined[normalize-space(.)='']" mode="dc"/>
  <xsl:template match="meta:user-defined[not(contains(@meta:name, 'Info'))]" mode="dc">
    <xsl:element name="{translate(@meta:name, $majs, $mins)}">
      <xsl:value-of select="."/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="meta:user-defined" mode="dc">
    <xsl:choose>
      <xsl:when test="starts-with(., 'location:')">
        <dc:coverage xsi:type="gns:ufi">
          <xsl:value-of select="substring-after(., 'location:')"/>
        </dc:coverage>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <!-- do something with that ? -->
  <xsl:template match="meta:editing-cycles" mode="dc"/>
  <xsl:template match="meta:editing-duration" mode="dc"/>
  <!-- Creators from automatic metas may not express author will -->
  <xsl:template match="meta:initial-creator" mode="dc">
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
      <xsl:when test="($prev != $style) and contains ($style, 'abstract')">
        <dcterms:abstract>
          <xsl:call-template name="lang"/>
          <xsl:apply-templates/>
          <!-- TODO sibbling styles
          <xsl:if test="$next = $style">
            <xsl:apply-templates select="following-sibling::*[1]" mode="level2"/>
          </xsl:if>
          -->
        </dcterms:abstract>
      </xsl:when>
      <!-- TODO handle case of sibling style -->
      <xsl:when test="($prev != $style) and contains($style, 'description')">
        <dc:description>
          <xsl:call-template name="lang"/>
          <xsl:attribute name="xsi:type">
            <xsl:text>style:</xsl:text>
            <xsl:value-of select="$style"/>
          </xsl:attribute>
          <xsl:apply-templates/>
        </dc:description>
      </xsl:when>
      <!-- do nothing -->
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:template>
  <!-- 
 images 
ref: <http://www.w3.org/TR/rdf-primer/#example36>
-->
  <xsl:template match="draw:image" mode="dc">
    <xsl:variable name="link">
      <xsl:apply-templates select="@xlink:href"/>
    </xsl:variable>
    <dc:relation xsi:type="dcterms:URI">
      <xsl:attribute name="dc:format">
        <xsl:call-template name="getMime">
          <xsl:with-param name="path" select="$link"/>
        </xsl:call-template>
      </xsl:attribute>
      <xsl:attribute name="rdf:resource">
        <xsl:choose>
          <xsl:when test="starts-with($link, 'http://')">
            <xsl:value-of select="$link"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="normalizePath">
              <xsl:with-param name="path">
                <xsl:call-template name="getParent">
                  <xsl:with-param name="path" select="$path"/>
                </xsl:call-template>
                <xsl:value-of select="$link"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:value-of select="$link"/>
    </dc:relation>
  </xsl:template>
  <!-- relative links as relation -->
  <xsl:template match="draw:a | text:a" mode="dc">
    <xsl:variable name="path" select="@xlink:href"/>
    <xsl:variable name="link">
      <xsl:apply-templates select="@xlink:href"/>
    </xsl:variable>
    <xsl:variable name="lang">
      <xsl:call-template name="getLang">
        <xsl:with-param name="path" select="$path"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <!-- internal link, not really interersting -->
      <xsl:when test="starts-with($path, '#')"/>
      <!-- semantic link in form name:value -->
      <xsl:when test="starts-with($path, './') and contains(substring-after($path, './'), ':')">
        <dc:subject xsi:type="{substring-before(substring-after($path, './'), ':')}" dc:title="{.}">
          <xsl:value-of select="substring-after($path, ':')"/>
        </dc:subject>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="element">
          <xsl:choose>
            <xsl:when test="starts-with($path, 'http://')">dc:source</xsl:when>
            <xsl:otherwise>dc:relation</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:element name="{$element}">
          <xsl:attribute name="xsi:type">dcterms:URI</xsl:attribute>
          <xsl:attribute name="dc:format">
            <xsl:call-template name="getMime">
              <xsl:with-param name="path" select="$link"/>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:if test="normalize-space($lang) != ''">
            <xsl:attribute name="dc:language">
              <xsl:value-of select="$lang"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:attribute name="dc:title">
            <xsl:value-of select="normalize-space(.)"/>
          </xsl:attribute>
          <xsl:value-of select="$link"/>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- index marks ??? -->
  <!--
  <xsl:template match="text:user-index-mark">
    <dc:subject xsi:type="index:{@text:index-name}">
      <xsl:value-of select="@text:string-value"/>
    </dc:subject>
  </xsl:template>
  <xsl:template match="text:alphabetical-index-mark">
    <dc:subject xsi:type="text:index">
      <xsl:value-of select="@text:string-value"/>
    </dc:subject>
  </xsl:template>
  <xsl:template match="text:alphabetical-index-mark-start">
    <dc:subject xsi:type="text:index">
      <xsl:value-of select="@text:string-value"/>
    </dc:subject>
  </xsl:template>
  -->
  <!-- links TODO ! -->
  <!--  bibliography  -->
  <xsl:template match="text:bibliography-mark" mode="dc">
    <dcterms:references xsi:type="text:bibliography-mark">
      <xsl:apply-templates select="@*" mode="dc"/>
      <xsl:apply-templates select="." mode="text-foot"/>
    </dcterms:references>
  </xsl:template>
  <!-- process bibliographic attributes as dc:attributes -->
  <xsl:template match="@*" mode="dc"/>
  <xsl:template match="@text:identifier" mode="dc">
    <xsl:attribute name="dc:identifier">
      <xsl:value-of select="normalize-space(.)"/>
    </xsl:attribute>
  </xsl:template>
  <!-- better than the author identifier ?
  <xsl:template match="@text:isbn" mode="dc">
    <xsl:attribute name="dc:identifier">
      <xsl:value-of select="normalize-space(.)"/>
    </xsl:attribute>
  </xsl:template>
-->
  <xsl:template match="@text:title" mode="dc">
    <xsl:attribute name="dc:title">
      <xsl:value-of select="normalize-space(.)"/>
    </xsl:attribute>
  </xsl:template>
  <xsl:template match="@text:author" mode="dc">
    <xsl:attribute name="dc:creator">
      <xsl:value-of select="normalize-space(.)"/>
    </xsl:attribute>
  </xsl:template>
  <xsl:template match="@text:publisher" mode="dc">
    <xsl:attribute name="dc:publisher">
      <xsl:value-of select="normalize-space(.)"/>
    </xsl:attribute>
  </xsl:template>
  <xsl:template match="@text:year" mode="dc">
    <xsl:attribute name="dc:date">
      <xsl:value-of select="normalize-space(.)"/>
    </xsl:attribute>
  </xsl:template>
  <xsl:template match="@text:url" mode="dc">
    <xsl:attribute name="rdf:resource">
      <xsl:value-of select="normalize-space(.)"/>
    </xsl:attribute>
  </xsl:template>
  <xsl:template match="@text:note" mode="dc">
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
  <!--
give size of a doc in different units, taken from
		<meta:document-statistic meta:table-count="1" meta:image-count="0" meta:object-count="0" meta:page-count="11" meta:paragraph-count="326" meta:word-count="3405" meta:character-count="23617"/>
	-->
  <xsl:template match="meta:document-statistic" mode="dc">
    <dcterms:extent pages="{@meta:page-count}" words="{@meta:word-count}" signs="{@meta:character-count}" images="{@meta:image-count}" xsi:type="chars">
      <xsl:value-of select="format-number(@meta:character-count, '00000000')"/>
    </dcterms:extent>
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
    <xsl:apply-templates mode="text"/>
    <xsl:text>" &lt;</xsl:text>
    <xsl:apply-templates select="@xlink:href" mode="text"/>
    <xsl:text>&gt;</xsl:text>
  </xsl:template>
  <!--
A centralized template to add @xml:lang attribute
-->
  <xsl:template name="lang">
    <xsl:if test="normalize-space($lang) != ''">
      <xsl:attribute namespace="http://www.w3.org/XML/1998/namespace" name="xml:lang">
        <xsl:value-of select="$lang"/>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>
</xsl:transform>
