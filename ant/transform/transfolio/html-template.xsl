<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="../html/xsl2html.xsl"?>
<!--

Title     : from a thin directory to a metadata tree
Label     : toc2rdf.xsl
Copyright : © 2004, "ADNX" <http://adnx.org>.
Licence   : "CeCILL" <http://www.cecill.info/licences/Licence_CeCILL_V1.1-US.html> 
            ("GPL" <http://www.gnu.org/copyleft/gpl.html> like)
Creator   : [FG] "Frédéric Glorieux" <frederic.glorieux@ajlsm.com> 
            ("AJLSM" <http://ajlsm.org>)


This transformation 
process an xhtml template, 
to insert xhtml content, 
and insert information from an RDF tree.



-->
<xsl:stylesheet version="1.0" 
  xmlns:html="http://www.w3.org/1999/xhtml" 
  xmlns="http://www.w3.org/1999/xhtml" 
  xmlns:i18n="http://apache.org/cocoon/i18n/2.1" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:dc="http://purl.org/dc/elements/1.1/" 
  xmlns:dcterms="http://purl.org/dc/terms/"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
  exclude-result-prefixes="xsl dc dcterms html rdf i18n">
  <!-- to resolve some path -->
  <xsl:import href="../explorer/path.xsl"/>
  <!-- for navigation views -->
  <xsl:import href="../explorer/explorer.xsl"/>
  <!-- override an explorer param to send links to a frame -->
  <xsl:param name="target"/>
  <!-- override an explorer param on extension -->
  <xsl:param name="extension" select="'html'"/>
  <!-- extension able to be htmlisable, overide an explorer param -->
  <xsl:param name="htmlizable" select="' sxw xhtml '"/>
  <!-- path of the directory theme, 
where to find template and resolve links of the template
will be resolved from the path of the document to be relative
 -->
  <xsl:param name="theme-path" select="'/theme/'"/>
  <!-- relative URI to the theme directory -->
  <xsl:param name="theme">
    <xsl:call-template name="getRelative">
      <xsl:with-param name="from" select="$path"/>
      <xsl:with-param name="to" select="$theme-path"/>
    </xsl:call-template>
  </xsl:param>
  <!-- path of the file (to resolve links and display URI) -->
  <xsl:param name="path"/>
  <!-- server, for absolute URI -->
  <xsl:param name="server"/>
  <!-- identifier of the doc (without extension) -->
  <xsl:param name="identifier">
    <xsl:value-of select="$server"/>
    <xsl:call-template name="getParent">
      <xsl:with-param name="path" select="$path"/>
    </xsl:call-template>
    <xsl:call-template name="getBasename">
      <xsl:with-param name="path" select="$path"/>
    </xsl:call-template>
  </xsl:param>
  <!-- uri of the template.xhtml to process, probably in theme directory -->
  <xsl:param name="template.xhtml" select="concat($theme, 'template.xhtml')"/>
  <!-- the variable where the template is stored -->
  <xsl:variable name="template" select="document($template.xhtml, .)"/>
  <!-- variable to store content (the document to be processed -->
  <xsl:variable name="content" select="/"/>
  <!-- address toc.rdf where metadatas are stored -->
  <xsl:param name="toc-path" select="'/toc.rdf'"/>
  <!-- get an uri for toc.rdf -->
  <xsl:variable name="toc.rdf">
    <xsl:call-template name="getRelative">
      <xsl:with-param name="from" select="$path"/>
      <xsl:with-param name="to" select="$toc-path"/>
    </xsl:call-template>
  </xsl:variable>
  <!-- store the toc -->
  <xsl:variable name="toc" select="document($toc.rdf, .)"/>
  <!-- should be the metadatas from the resource to be processed -->
  <xsl:variable name="resource" select="$toc//resource[@href=substring-after($path,'/')]"/>
  <!-- no indent, let original indentation of source (especially for spaces) -->
  <xsl:output method="xml" indent="no" encoding="UTF-8"/>
  <!-- get a lang to follow for relative links -->
  <xsl:param name="lang" select="$toc//resource[contains(@href, substring-after($path,'/'))]/@xml:lang"/>
  <!-- 

  <xsl:value-of select="$path"/>
  <xsl:variable name="resource" select="$toc//resource[@href=substring-after($path,'/')]"/>
  <xsl:variable name="lang" select="$resource/@xml:lang"/>
  lang:<xsl:value-of select="$lang"/>
  <xsl:variable name="prev-rad" 
  select="$resource/preceding::resource[@radical != $resource/@radical][1]/@radical"/>
prev-rad  <xsl:value-of select="$prev-rad"/>
  <xsl:variable name="prev-path" 
  select="concat(
$resource/preceding::resource[@radical =$prev-rad]/../@href,
$prev-rad)"/>
prev-path  <xsl:value-of select="$prev-path"/>
  <xsl:choose>
    <xsl:when test="
$resource/preceding::resource[@radical = $prev-rad][@xml:lang=$lang]
    ">
      <xsl:value-of select="
$resource/preceding::resource[@radical = $prev-rad][@xml:lang=$lang]//dc:title
    "/>
    
    </xsl:when>

    <xsl:otherwise>
      <xsl:value-of select="
$resource/preceding::resource[@radical != $resource/@radical][not(@xml:lang)]//dc:title
    "/>
    </xsl:otherwise>
  </xsl:choose>
  <h1>
    <xsl:value-of select="$resource/preceding::resource[1]"/>
  
  </h1>

 -->
  <xsl:template match="/">
    <xsl:apply-templates select="$template/*" mode="template"/>
  </xsl:template>
  <!-- no output of template comments -->
  <xsl:template match="comment()" mode="template"/>
  <!-- rewrite links from template to be relative to the theme directory -->
  <xsl:template match="html:script" mode="template">
    <script>
      <xsl:apply-templates select="@*" mode="template"/>
      <xsl:text> &#160; </xsl:text>
      <xsl:apply-templates/>
    </script>
  </xsl:template>
  <!-- rewrite links in template -->
  <xsl:template match="
	  html:img/@src[not(contains(., ':'))] 
	| html:script/@src[not(contains(., ':'))] 
	| html:link[@rel='stylesheet']/@href[not(contains(., ':'))]
	| */@background[not(contains(., ':'))]
	
	" mode="template">
    <xsl:attribute name="{name()}">
      <xsl:value-of select="$theme"/>
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>
  <!-- 
rewrite links in xhtml source for
 * email hiding
 * *.xhtml > .html
 -->
     <!-- template for link resolution -->
  <xsl:template name="href" match="@href" mode="content">
    <xsl:param name="href" select="."/>
    <xsl:variable name="destExtension">
      <xsl:call-template name="getExtension">
        <xsl:with-param name="path" select="$href"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <!-- hide emails -->
      <xsl:when test="contains($href, '@')">
        <xsl:attribute name="href">#</xsl:attribute>
        <xsl:attribute name="onclick">
          <xsl:text>this.href='mailto:</xsl:text>
          <xsl:value-of select="substring-before($href, '@')"/>
          <xsl:text>'+'\x40'+'</xsl:text>
          <xsl:value-of select="substring-after($href, '@')"/>
          <xsl:text>'</xsl:text>
        </xsl:attribute>
      </xsl:when>
      <!-- relative link to xhtml ? point on html -->
      <xsl:when test="
  not(contains($href, ':')) and
  $destExtension = 'xhtml'">
        <xsl:attribute name="href">
          <xsl:call-template name="getBasepath">
            <xsl:with-param name="path" select="."/>
          </xsl:call-template>
          <!-- TODO ? more generic -->
          <xsl:text>.html</xsl:text>
          <xsl:if test="contains($href, '#')">
            <xsl:text>#</xsl:text>
            <xsl:value-of select="substring-after($href, '#')"/>
          </xsl:if>
        </xsl:attribute>
      </xsl:when>
      <!-- let it -->
      <xsl:otherwise>
        <xsl:attribute name="href">
          <xsl:value-of select="$href"/>
        </xsl:attribute>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  
  
  <!-- take title from template if there's not in the source -->
  <xsl:template match="html:head/html:title[1]" mode="template">
    <xsl:if test="not($content/html:html/html:head/html:title)">
      <xsl:copy-of select="."/>
    </xsl:if>
  </xsl:template>
  <!-- strip other titles -->
  <xsl:template match="html:head/html:title[position() &gt; 1]" mode="template"/>
  <!-- replace home link by a relative link to an existing file -->

  <!--
2004-05-08
Here is defined the template for images
Especially the way to display metadata around it
MAYDO:put in xhtml template layout of images (after tests here)

Problems waited because of relative links
-->
  <xsl:template match="html:img" mode="content">
    <xsl:variable name="parent">
      <xsl:call-template name="getParent">
        <xsl:with-param name="path" select="@src"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="radical">
      <xsl:call-template name="getRadical">
        <xsl:with-param name="path" select="@src"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="extension">
      <xsl:call-template name="getExtension">
        <xsl:with-param name="path" select="@src"/>
      </xsl:call-template>
    </xsl:variable>
    <!-- TODO may bug in some contexts, test under different contexts -->
    <!-- server specific with problems to resolve links from documen() function

    <xsl:variable name="uri">
      <xsl:value-of select="$server"/>
      <xsl:value-of select="$context"/>
      <xsl:value-of select="$parent"/>
      <xsl:value-of select="$radical"/>
      <xsl:text>.rdf</xsl:text>
    </xsl:variable>
-->
    <xsl:variable name="uri">
      <xsl:value-of select="$parent"/>
      <xsl:value-of select="$radical"/>
      <xsl:text>.rdf</xsl:text>
    </xsl:variable>
    <!--
javax.xml.transform.TransformerException: Impossible de charger le document demandé : unknown protocol: cocoon

-->
    <xsl:variable name="rdf" select="document($uri, .)"/>
    <xsl:choose>
      <xsl:when test="@class='nolayout'">
        <xsl:copy-of select="."/>
      </xsl:when>
      <!--
record available on this image
rewrite it

width:', substring-after(@src, 'size=') ,'px ;
 -->
      <xsl:when test="$rdf">
        <div class="img">
          <xsl:attribute name="style">
            <xsl:value-of select="
concat( 'float: ',@align, ' ; clear:', @align,' ; margin:1ex; ')"/>
            <!-- TODO verify  -->
            <xsl:if test="@width != ''">
              <xsl:text> width:</xsl:text>
              <xsl:value-of select="@width"/>
            </xsl:if>
            <!--
            <xsl:choose>
              <xsl:when test="@align = 'left'">; clear:right;</xsl:when>
              <xsl:when test="@align = 'right'">; clear:left;</xsl:when>
            </xsl:choose>
-->
          </xsl:attribute>
          <h6>
            <xsl:comment>  - </xsl:comment>
            <!-- TODO: localize title -->
            <xsl:value-of select="$rdf/*/*/dc:title[1]"/>
          </h6>
          <small>
              <xsl:comment>  - </xsl:comment>
              <xsl:value-of select="$rdf/*/*/dc:creator"/>
          </small>
          <a href="{$parent}{$radical}.html">
            <img width="100%">
              <xsl:copy-of select="@*[name() != 'width']"/>
              <!-- 
fast patch to show image without resizing 
(size defined by div) 

bug in IE
<xsl:attribute name="width">100%</xsl:attribute>

-->
            </img>
          </a>
          <!-- can't understand why, but text here will be under image in IE -->
        </div>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- should be head of the template, from which copy head of xhtml -->
  <xsl:template match="html:head" mode="template">
    <head>
      <xsl:apply-templates mode="template"/>
      <xsl:apply-templates select="$content/html:html/html:head/node()" mode="content"/>
    </head>
  </xsl:template>
  <!-- catch css links from content to avoid breaking of layout -->
  <xsl:template match="html:head/html:link[@rel='stylesheet']" mode="content"/>
  <!-- match the article substitute -->
  <xsl:template match="html:*[@id='article']" mode="template">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="$content/html:html/html:body/node()" mode="content"/>
    </xsl:copy>
  </xsl:template>
  <!-- handle possible tocs -->
  <!-- let tocs where authors decide to have
	<xsl:template match="foo:toc">
		<xsl:copy-of select="/*/content//*[@class='toc']"/>
	</xsl:template>
	<xsl:template match="content//*[@class='toc']"/>
	-->
  <xsl:template match="html:*[@id='navbar']" mode="template">
<!--
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="/aggregate/dir:navigation" mode="navbar"/>
    </xsl:copy>
-->
  </xsl:template>
  <!-- put a toc inside the block from template  -->
  <xsl:template match="html:*[@id='toc']" mode="template">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="template"/>
        <ul id="explorer">  
          <xsl:apply-templates select="$toc/rdf:RDF/collection/*"/>
        </ul>
    </xsl:copy>
  </xsl:template>
  <!-- languages available for this doc -->
  <xsl:template match="html:*[@id='langs']" mode="template">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="/aggregate/rdf:RDF/rdf:Description[1]" mode="langs"/>
    </xsl:copy>
  </xsl:template>
  <!-- 
formats of this doc
TODO ? localize name of documents by mime types ?
A localized label ? Or from theme ?
 -->
  <xsl:template match="html:*[@id='formats']" mode="template">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:if test="$resource//dcterms:hasFormat">
        <select onchange="window.location.href=this.options[this.selectedIndex].value;">
          <option/>
          <xsl:for-each select="$resource//dcterms:hasFormat">
            <option title="{@dc:format}" value="{.}">
              <xsl:choose>
                <xsl:when test="@dc:title">
                  <xsl:value-of select="@dc:title"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:call-template name="getExtension">
                    <xsl:with-param name="path" select="."/>
                  </xsl:call-template>
                </xsl:otherwise>
              </xsl:choose>
            </option>
          </xsl:for-each>
        </select>
      </xsl:if>
    </xsl:copy>
  </xsl:template>
  <!-- match the clickable uri substitute -->
  <xsl:template match="html:*[@id='path']" mode="template">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:call-template name="path-links"/>
    </xsl:copy>
  </xsl:template>
  <!-- match a skin selector -->
  <!-- specific to a server implementation like cocoon
  <xsl:template match="html:*[@id='skin']">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <form name="skin" action="" method="post" style="display:inline">
        <select onchange="this.form.submit()" name="skin">
          <option/>
          <xsl:for-each select="$skins">
            <option>
              <xsl:value-of select="@name"/>
            </option>
          </xsl:for-each>
        </select>
      </form>
    </xsl:copy>
  </xsl:template>
-->
  <!-- write a clickable uri 
2004-04-02 frederic.glorieux@ajlsm.com

This template seems to work with different kind of paths,
may be interesting to test more.
	-->
  <xsl:template name="path-links">
    <xsl:for-each select="$resource/ancestor::collection">
      <xsl:value-of select="@name"/> 
      <span class="slash">/</span> 
    </xsl:for-each>
  </xsl:template>
  <!-- relative upper path -->
  <xsl:template name="path-upper">
    <xsl:param name="path"/>
    <xsl:param name="count" select="string-length($path) - string-length(translate($path, '/\', ''))"/>
    <xsl:choose>
      <xsl:when test="$count &lt; 2"/>
      <xsl:otherwise>
        <xsl:text>../</xsl:text>
        <xsl:call-template name="path-upper">
          <xsl:with-param name="count" select="$count - 1"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- default, copy all for template -->
  <xsl:template match="node()|@*" priority="-1" mode="template">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="template"/>
    </xsl:copy>
  </xsl:template>
  <!-- default, copy all for content -->
  <xsl:template match="node()|@*" priority="-1" mode="content">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="content"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
