<?xml version="1.0" encoding="UTF-8"?>
<!--
(c) 2003, 2004; ADNX <http://adnx.org>

 = WHAT =

provide an easy and clean xhtml, handling most of the structuration that
a word processor is able to provide.

 = WHO =

[FG] "Frédéric Glorieux" <frederic.glorieux@ajlsm.com>

 = HOW =

All style classes handle in this xsl are standard openOffice. To
define specific styles to handle, best is import this xsl. If possible, 
modify only for better rendering of standard oo.

 = CHANGES =

The original xsl was designed for docbook.
This work is continued, in the xhtml 
syntax. Most of the comments are from the author
to help xsl developpers to understand some tricks.

 = MAYDO =

Mozilla compatible
media links
footnotes
split on section ?
index terms ?
  -->
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:style="http://openoffice.org/2000/style" xmlns:text="http://openoffice.org/2000/text" xmlns:office="http://openoffice.org/2000/office" xmlns:table="http://openoffice.org/2000/table" xmlns:draw="http://openoffice.org/2000/drawing" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:meta="http://openoffice.org/2000/meta" xmlns:number="http://openoffice.org/2000/datastyle" xmlns:svg="http://www.w3.org/2000/svg" xmlns:chart="http://openoffice.org/2000/chart" xmlns:dr3d="http://openoffice.org/2000/dr3d" xmlns:math="http://www.w3.org/1998/Math/MathML" xmlns:form="http://openoffice.org/2000/form" xmlns:script="http://openoffice.org/2000/script" xmlns:config="http://openoffice.org/2001/config" office:class="text" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:i18n="http://apache.org/cocoon/i18n/2.1" exclude-result-prefixes="office meta  table number dc fo xlink chart math script xsl draw svg dr3d form config text style i18n">
  <xsl:import href="sxw-common.xsl"/>
  <!-- may be indent for xhtml but not html (some layout) -->
  <xsl:output method="xml" indent="yes" omit-xml-declaration="yes" encoding="UTF-8"/>
  <!-- encoding, default is the one specified in xsl:output -->
  <xsl:param name="encoding" select="document('')/*/xsl:output/@encoding"/>
  <!-- ?? parameter provided by the xhtml xsl pack of sun -->
  <xsl:param name="dpi" select="120"/>
  <!-- link to a css file -->
  <xsl:param name="css"/>
  <xsl:param name="css-">
    <xsl:call-template name="getRelative">
      <xsl:with-param name="from" select="$path"/>
      <xsl:with-param name="to" select="$css"/>
    </xsl:call-template>
  </xsl:param>
  <!-- link to a js file -->
  <xsl:param name="js"/>
  <!-- validation -->
  <xsl:param name="validation"/>
  <!-- title numbering -->
  <xsl:param name="numbering" select="true()"/>
  <!-- language from outside -->
  <xsl:param name="lang"/>
  <!-- important handle in doc -->
  <xsl:variable name="office:meta" select=".//office:meta"/>
  <xsl:variable name="office:automatic-styles" select=".//office:automatic-styles"/>
  <xsl:variable name="office:body" select=".//office:body"/>
  <!--
  root template for an oo the document
-->
  <xsl:template match="/">
    <html>
      <head>
        <meta http-equiv="Content-type">
          <xsl:attribute name="content">
            <xsl:text>text/html; charset=</xsl:text>
            <xsl:value-of select="$encoding"/>
          </xsl:attribute>
        </meta>
        <xsl:if test="$css-">
          <link rel="stylesheet" href="{$css-}"/>
        </xsl:if>
        <style type="text/css">
	table.img { border:1px solid; }
	img.oo {clear:both;}
	.bibliorecord {text-indent:-4em; margin-left:4em;}
	.bibliorecord * {text-indent:0;}

				</style>
      </head>
      <!-- default js functions on body if available onload property -->
      <!-- all layout is provide on CSS to keep a completely clean HTML -->
      <body>
        <div>
          <xsl:if test="contains($lang, 'ar')">
            <xsl:attribute name="dir">rtl</xsl:attribute>
          </xsl:if>
          <a name="0">
            <xsl:comment> &#160; </xsl:comment>
          </a>
          <xsl:apply-templates select="$office:body" mode="html"/>
          <xsl:if test="$office:body//text:footnote or $office:body//text:bibliography-mark">
            <hr width="30%" align="left"/>
            <div id="footnotes">
              <xsl:apply-templates select="$office:body//text:footnote" mode="html-foot"/>
            </div>
            <div id="bibliography">
              <!-- TOD, get a title from document -->
              <xsl:apply-templates select="$office:body//text:bibliography-mark[not(@text:identifier = following::text:bibliography-mark/@text:identifier)]" mode="html-foot">
                <xsl:sort select="@text:identifier"/>
              </xsl:apply-templates>
            </div>
          </xsl:if>
        </div>
      </body>
    </html>
  </xsl:template>
  <!-- default css -->
  <xsl:template name="css"/>
  <!-- default script -->
  <xsl:template name="js"/>
  <!-- stop elements -->
  <xsl:template match="text:h[normalize-space(.)='']" mode="html"/>
  <xsl:template match="text:bibliography | text:bibliography-source" mode="html"/>
  <xsl:template match="office:script" mode="html"/>
  <xsl:template match="office:settings" mode="html"/>
  <xsl:template match="office:font-decls" mode="html"/>
  <xsl:template match="text:bookmark-end" mode="html"/>
  <xsl:template match="text:reference-mark-start" mode="html"/>
  <xsl:template match="text:reference-mark-end" mode="html"/>
  <xsl:template match="office:styles | office:master-styles | office:automatic-styles" mode="html"/>
  <xsl:template match="text:tracked-changes" mode="html"/>
  <xsl:template match="office:forms | text:sequence-decls" mode="html"/>
  <xsl:template match="office:annotation/text:p" mode="html"/>
  <!-- pass elements -->
  <xsl:template match="text()" mode="html">
    <xsl:choose>
      <!-- for inline -->
      <xsl:when test="normalize-space(.) =''"/>
      <xsl:otherwise>
        <xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="
  text:ordered-list//text:h
| text:unordered-list//text:h
| text:list-item//text:h
| text:list-item//text:h
" mode="html">
    <xsl:apply-templates mode="html"/>
  </xsl:template>
  <xsl:template match="*" mode="html">
    <xsl:apply-templates mode="html"/>
  </xsl:template>
  <!-- 
2003-09-30 FG : nested sections on matched level titles it works, I will understand one day
2003-11-18 FG : don't works, drastic simplification without keys, used also to build a toc
-->
  <xsl:template match="office:body" mode="html">
    <xsl:apply-templates mode="html"/>
  </xsl:template>
  <!--
	TOCs

This good logic may be tested on section
-->
  <!-- process a table of contents only if requested in the source 

Should 

	-->
  <xsl:template match="text:table-of-content" mode="html">
    <xsl:apply-templates select="$office:body" mode="html-toc"/>
  </xsl:template>
  <xsl:template match="node()" mode="html-toc"/>
  <xsl:template match="office:body" mode="html-toc">
    <xsl:if test=".//text:h[normalize-space(.)!='']">
      <dl class="toc" id="toc">
        <!-- sections may bug -->
        <xsl:apply-templates select=".//text:h[@text:level='1'][normalize-space(.)!='']" mode="html-toc"/>
      </dl>
    </xsl:if>
  </xsl:template>
  <xsl:template match="text:h[normalize-space(.)='']" mode="html-toc"/>
  <xsl:template match="text:h" mode="html-toc">
    <xsl:variable name="number">
      <xsl:apply-templates select="." mode="number"/>
    </xsl:variable>
    <dt>
      <!--  -->
      <xsl:if test="$numbering">
        <xsl:value-of select="$number"/>
        <xsl:text>) </xsl:text>
      </xsl:if>
      <a href="#{$number}">
        <xsl:apply-templates mode="html"/>
      </a>
    </dt>
    <xsl:variable name="level" select="number(@text:level)"/>
    <xsl:variable name="next" select="following-sibling::text:h[normalize-space(.)!=''][number(@text:level)=$level][1]"/>
    <!--
Get all following level-1 before the next level
Thanks Jenny
http://www.biglist.com/lists/xsl-list/archives/200008/msg01102.html
-->
    <xsl:choose>
      <xsl:when test="
following-sibling::text:h[normalize-space(.)!=''][number(@text:level) = $level +1]
[generate-id(following-sibling::text:h[normalize-space(.)!=''][number(@text:level) = $level][1]) = generate-id($next)]
">
        <dd>
          <dl>
            <xsl:apply-templates select="
following-sibling::text:h[normalize-space(.)!=''][number(@text:level) = $level +1]
[generate-id(following-sibling::text:h[normalize-space(.)!=''][number(@text:level) = $level][1]) = generate-id($next)]
" mode="html-toc"/>
          </dl>
        </dd>
      </xsl:when>
      <xsl:when test="
following-sibling::text:h[normalize-space(.)!=''][number(@text:level) = $level +1]
and not(following-sibling::text:h[normalize-space(.)!=''][number(@text:level) = $level])
">
        <dd>
          <dl>
            <xsl:apply-templates select="
following-sibling::text:h[normalize-space(.)!=''][number(@text:level) = $level +1]
" mode="html-toc"/>
          </dl>
        </dd>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <!--
	sectionning
	-->
  <!-- should not be useful but ... -->
  <xsl:template name="section" match="text:h" mode="html">
    <xsl:variable name="number">
      <xsl:apply-templates select="." mode="number"/>
    </xsl:variable>
    <a name="{$number}" class="anchor">
      <xsl:comment>
        <xsl:value-of select="$number"/>
      </xsl:comment>
    </a>
    <xsl:element name="h{@text:level}">
      <xsl:attribute name="id">
        <xsl:value-of select="$number"/>
      </xsl:attribute>
      <xsl:if test="$numbering">
        <span class="no">
          <xsl:copy-of select="$number"/>
        </span>
        <xsl:text> </xsl:text>
      </xsl:if>
      <xsl:apply-templates mode="html"/>
    </xsl:element>
  </xsl:template>
  <!-- a little nav  -->
  <xsl:template name="navigation">
    <xsl:variable name="prev" select="preceding-sibling::text:h[1][normalize-space(.)!='']"/>
    <xsl:variable name="next" select="following-sibling::text:h[1][normalize-space(.)!='']"/>
    <small class="nav">
      <a title="{$prev}" class="button" rel="prev" tabindex="-1">
        <xsl:attribute name="href">
          <xsl:text>#</xsl:text>
          <xsl:variable name="prev-num">
            <xsl:apply-templates select="$prev" mode="number"/>
          </xsl:variable>
          <xsl:value-of select="$prev-num"/>
        </xsl:attribute>
        <xsl:text>&lt;</xsl:text>
      </a>
      <a class="button" rel="sup" tabindex="-2" href="#top">
        <xsl:text>^</xsl:text>
      </a>
      <a title="{$next}" class="button" rel="next" tabindex="1">
        <xsl:attribute name="href">
          <xsl:text>#</xsl:text>
          <xsl:variable name="next-num">
            <xsl:apply-templates select="$next" mode="number"/>
          </xsl:variable>
          <xsl:value-of select="$next-num"/>
        </xsl:attribute>
        <xsl:text>&gt;</xsl:text>
      </a>
    </small>
  </xsl:template>
  <!--


	 handle blocks, give them an HTML form on semantic styles 


-->
  <xsl:template match="text:p" mode="html">
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
      <!--
FG:2004-06-17  careful when strip empty blocks, some can contain images
-->
      <!-- bad semantic practice but efficient spacer -->
      <xsl:when test="normalize-space(.)='' and not(*[name()!='text:change'])
">
        <p class="spacer"> &#160; </p>
      </xsl:when>
      <xsl:when test="$style='standard' or $style='first-line-indent' or $style='text-body' or $style='hanging-indent'">
        <p class="{$style}">
          <xsl:apply-templates mode="html"/>
        </p>
      </xsl:when>
      <xsl:when test="text:title | text:subject">
        <center>
          <h1 class="{$style}">
            <xsl:apply-templates mode="html"/>
          </h1>
        </center>
      </xsl:when>
      <xsl:when test="$style='title' and normalize-space(.)!=''">
        <center>
          <h1 class="{$style}">
            <xsl:apply-templates mode="html"/>
          </h1>
        </center>
      </xsl:when>
      <xsl:when test="$style='subtitle'">
        <center>
          <em>
            <h1 class="subtitle">
              <xsl:apply-templates mode="html"/>
            </h1>
          </em>
        </center>
      </xsl:when>
      <!-- Definition list -->
      <!-- match the first term to open the list, let level2 work on the logic -->
      <xsl:when test="
($style='list-heading' or $style='dt')
and ($prev != 'list-heading' and $prev != 'dt' and $prev != 'list-contents' and $prev != 'dd')">
        <dl>
          <xsl:apply-templates select="." mode="html-level2"/>
        </dl>
      </xsl:when>
      <!-- let all following definition list styles to level2 -->
      <xsl:when test="$style = 'list-heading' or $style = 'dt' or
			 $style = 'list-contents' or $style = 'dd'"/>
      <xsl:when test="$style='quotations'">
        <blockquote>
          <xsl:apply-templates mode="html"/>
        </blockquote>
      </xsl:when>
      <xsl:when test="$style='preformatted-text'">
        <pre>
          <xsl:apply-templates mode="html"/>
        </pre>
      </xsl:when>
      <xsl:when test="$style='person'">
        <p class="person">
          <xsl:apply-templates mode="html"/>
        </p>
      </xsl:when>
      <xsl:when test="$style='horizontal-line'">
        <hr/>
      </xsl:when>
      <xsl:when test="$style='comment'">
        <xsl:comment>
          <xsl:value-of select="."/>
        </xsl:comment>
      </xsl:when>
      <xsl:otherwise>
        <div class="{$style}">
          <xsl:apply-templates mode="html"/>
        </div>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- 

This level process nodes to be nested in the ones opened in the blocks upper,
 to restore some hierarchy. Essentially used for definition lists.

-->
  <xsl:template match="text:p" name="level2" mode="html-level2">
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
    <!-- choices -->
    <xsl:choose>
      <xsl:when test="
($style = 'list-heading' or $style ='dt')">
        <dt>
          <xsl:apply-templates mode="html"/>
        </dt>
        <xsl:if test="
$next = 'list-heading' or $next='dt' or $next='list-contents' or $next='dd'">
          <xsl:apply-templates select="following-sibling::*[1]" mode="html-level2"/>
        </xsl:if>
      </xsl:when>
      <!-- on all definition list styles, continue level2 -->
      <xsl:when test="
($style = 'list-contents' or $style ='dd') 
">
        <dd>
          <xsl:apply-templates mode="html"/>
        </dd>
        <xsl:if test="
$next = 'list-heading' or $next='dt' or $next='list-contents' or $next='dd'">
          <xsl:apply-templates select="following-sibling::*[1]" mode="html-level2"/>
        </xsl:if>
      </xsl:when>
      <!-- not yet used -->
      <xsl:otherwise>
        <div class="{$style}">
          <xsl:apply-templates mode="html"/>
        </div>
        <xsl:if test="$next = $style">
          <xsl:apply-templates select="following-sibling::*[1]" mode="html-level2"/>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!--

	 abstract 

-->
  <xsl:template match="text:description" mode="html">
    <blockquote class="abstract">
      <xsl:apply-templates mode="html"/>
    </blockquote>
  </xsl:template>
  <!-- an anchor, what about renaming anchors ? -->
  <xsl:template match="text:bookmark-start | text:bookmark" mode="html">
    <a name="{@text:name}">
      <xsl:comment> &#160; </xsl:comment>
    </a>
  </xsl:template>
  <!-- table -->
  <xsl:template match="table:table" mode="html">
    <table class="table">
      <xsl:attribute name="id">
        <xsl:value-of select="@table:name"/>
      </xsl:attribute>
      <xsl:call-template name="generictable"/>
    </table>
  </xsl:template>
  <xsl:template name="generictable">
    <xsl:variable name="cells" select="count(descendant::table:table-cell)"/>
    <xsl:variable name="rows">
      <xsl:value-of select="count(descendant::table:table-row) "/>
    </xsl:variable>
    <xsl:variable name="cols">
      <xsl:value-of select="$cells div $rows"/>
    </xsl:variable>
    <xsl:variable name="numcols">
      <xsl:choose>
        <xsl:when test="child::table:table-column/@table:number-columns-repeated">
          <xsl:value-of select="number(table:table-column/@table:number-columns-repeated+1)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$cols"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!--
Work with colspec ?
    <xsl:element name="tgroup">
      <xsl:attribute name="cols">
        <xsl:value-of select="$numcols"/>
      </xsl:attribute>
      <xsl:call-template name="colspec">
        <xsl:with-param name="left" select="1"/>
      </xsl:call-template>
    </xsl:element>
-->
    <xsl:apply-templates mode="html"/>
  </xsl:template>
  <xsl:template name="colspec">
    <xsl:param name="left"/>
    <xsl:if test="number($left &lt; ( table:table-column/@table:number-columns-repeated +2)  )">
      <xsl:element name="colspec">
        <xsl:attribute name="colnum">
          <xsl:value-of select="$left"/>
        </xsl:attribute>
        <xsl:attribute name="colname">c
                    <xsl:value-of select="$left"/>
        </xsl:attribute>
      </xsl:element>
      <xsl:call-template name="colspec">
        <xsl:with-param name="left" select="$left+1"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  <xsl:template match="table:table-column" mode="html">
    <xsl:apply-templates mode="html"/>
  </xsl:template>
  <xsl:template match="table:table-header-rows" mode="html">
    <thead>
      <xsl:apply-templates mode="html"/>
    </thead>
  </xsl:template>
  <xsl:template match="table:table-header-rows/table:table-row" mode="html">
    <tr>
      <xsl:apply-templates mode="html"/>
    </tr>
  </xsl:template>
  <xsl:template match="table:table/table:table-row" mode="html">
    <tr>
      <xsl:apply-templates mode="html"/>
    </tr>
  </xsl:template>
  <xsl:template match="table:table-cell" mode="html">
    <xsl:variable name="element">
      <xsl:choose>
        <xsl:when test="text:p/@text:style-name='Table Heading'">th</xsl:when>
        <xsl:otherwise>td</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:element name="{$element}">
      <!-- ???
      <xsl:if test="@table:number-columns-spanned &gt; 1">
        <xsl:attribute name="namest">
          <xsl:value-of select="concat('c',count(preceding-sibling::table:table-cell[not(@table:number-columns-spanned)]) +sum(preceding-sibling::table:table-cell/@table:number-columns-spanned)+1)"/>
        </xsl:attribute>
        <xsl:attribute name="nameend">
          <xsl:value-of select="concat('c',count(preceding-sibling::table:table-cell[not(@table:number-columns-spanned)]) +sum(preceding-sibling::table:table-cell/@table:number-columns-spanned)+ @table:number-columns-spanned)"/>
        </xsl:attribute>
      </xsl:if>
    -->
      <xsl:choose>
        <!-- if more than one block, process them -->
        <xsl:when test="*[2]">
          <xsl:apply-templates mode="html"/>
        </xsl:when>
        <!-- if only one block, put value directly (without block declarations) -->
        <xsl:otherwise>
          <xsl:apply-templates select="*/node()" mode="html"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>
  <!-- lists -->
  <xsl:template match="text:ordered-list" mode="html">
    <ol>
      <xsl:apply-templates mode="html"/>
    </ol>
  </xsl:template>
  <xsl:template match="text:unordered-list" mode="html">
    <ul>
      <xsl:apply-templates mode="html"/>
    </ul>
  </xsl:template>
  <xsl:template match="text:list-item" mode="html">
    <li>
      <xsl:apply-templates mode="html"/>
    </li>
  </xsl:template>
  <!-- no para for a simple item -->
  <xsl:template match="text:list-item/text:p[not(../text:p[2])]" mode="html">
    <xsl:apply-templates mode="html"/>
  </xsl:template>
  <!--
  
  TODO media links
  
  
  -->
  <!-- do something with those frames ? -->
  <xsl:template match="draw:*" mode="html">
    <div>
      <xsl:apply-templates mode="html"/>
    </div>
  </xsl:template>
  <!-- handle inline, and give an html form to each default style -->
  <xsl:template match="text:span" mode="html">
    <xsl:variable name="style">
      <xsl:apply-templates select="@text:style-name"/>
    </xsl:variable>
    <!-- get bold and other CSS properties from automatic style -->
    <!-- TDO: broken -->
    <xsl:variable name="props" select="//style:style[@style:name=$style]"/>
    <xsl:choose>
      <!-- handle empty nodes to avoid strange behavior of browsers on xhtml -->
      <xsl:when test="normalize-space(.)='' and not(*)"/>
      <xsl:when test="$style='emphasis'">
        <em>
          <xsl:apply-templates mode="html"/>
        </em>
      </xsl:when>
      <!-- Change Made By Kevin Fowlks (fowlks@msu.edu) June 16th, 2003 -->
      <xsl:when test="$style='citation'">
        <cite>
          <xsl:apply-templates mode="html"/>
        </cite>
      </xsl:when>
      <xsl:when test="$style='sub'">
        <sub>
          <xsl:apply-templates mode="html"/>
        </sub>
      </xsl:when>
      <xsl:when test="$style='sup'">
        <sup>
          <xsl:apply-templates mode="html"/>
        </sup>
      </xsl:when>
      <xsl:when test="$style='example'">
        <samp>
          <xsl:apply-templates mode="html"/>
        </samp>
      </xsl:when>
      <xsl:when test="$style='teletype'">
        <tt>
          <xsl:apply-templates mode="html"/>
        </tt>
      </xsl:when>
      <xsl:when test="$style='source-text'">
        <code>
          <xsl:apply-templates mode="html"/>
        </code>
      </xsl:when>
      <xsl:when test="$style='definition'">
        <dfn>
          <xsl:apply-templates mode="html"/>
        </dfn>
      </xsl:when>
      <xsl:when test="$style='emphasis-bold'">
        <strong>
          <xsl:apply-templates mode="html"/>
        </strong>
      </xsl:when>
      <xsl:when test="$props">
        <xsl:choose>
          <xsl:when test="$props/style:properties/@fo:font-weight = 'bold'">
            <b>
              <xsl:apply-templates mode="html"/>
            </b>
          </xsl:when>
          <xsl:when test="$props/style:properties/@fo:font-style='italic'">
            <i>
              <xsl:apply-templates mode="html"/>
            </i>
          </xsl:when>
          <xsl:when test="$props/style:properties/@style:text-underline">
            <u>
              <xsl:apply-templates mode="html"/>
            </u>
          </xsl:when>
          <xsl:when test="$style=''">
            <xsl:apply-templates mode="html"/>
          </xsl:when>
          <xsl:otherwise>
            <span class="{$style}">
              <xsl:apply-templates mode="html"/>
            </span>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="$style=''">
        <xsl:apply-templates mode="html"/>
      </xsl:when>
      <xsl:otherwise>
        <span class="{$style}">
          <xsl:apply-templates mode="html"/>
        </span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="text:line-break" mode="html">
    <br/>
  </xsl:template>
  <xsl:template match="text:tab-stop" mode="html">
    <span class="tab">&#160;&#160;&#160;&#160;</span>
  </xsl:template>
  <xsl:template match="text:expression" mode="html">
    <span class="expression" title="{@text:formula}">
      <xsl:apply-templates mode="html"/>
    </span>
  </xsl:template>
  <xsl:template match="text:drop-down" mode="html">
    <span class="{@text:name}">
      <xsl:apply-templates mode="html"/>
    </span>
  </xsl:template>
  <xsl:template match="text:text-input" mode="html">
    <span class="{@text:description}">
      <xsl:apply-templates mode="html"/>
    </span>
  </xsl:template>
  <xsl:template match="comment" mode="html">
    <xsl:comment>
      <xsl:value-of select="."/>
    </xsl:comment>
  </xsl:template>
  <!--
TODO : find good HTML form for indexation terms
	<xsl:template match="text:alphabetical-index-mark-start">
		<xsl:element name="indexterm">
			<xsl:attribute name="class">
				<xsl:text disable-output-escaping="yes">startofrange</xsl:text>
			</xsl:attribute>
			<xsl:attribute name="id">
				<xsl:value-of select="@text:id"/>
			</xsl:attribute>

			<xsl:element name="primary">
				<xsl:value-of select="@text:key1"/>
			</xsl:element>

			<xsl:if test="@text:key2">
				<xsl:element name="secondary">
					<xsl:value-of select="@text:key2"/>
				</xsl:element>
			</xsl:if>
		</xsl:element>
	</xsl:template>
	<xsl:template match="text:alphabetical-index-mark-end">
		<xsl:element name="indexterm">
			<xsl:attribute name="startref">
				<xsl:value-of select="@text:id"/>
			</xsl:attribute>
			<xsl:attribute name="class">
				<xsl:text disable-output-escaping="yes">endofrange</xsl:text>
			</xsl:attribute>
		</xsl:element>
	</xsl:template>
	<xsl:template match="text:alphabetical-index">
		<xsl:element name="index">
			<xsl:element name="title">
				<xsl:value-of select="text:index-body/text:index-title/text:p"/>
			</xsl:element>
			<xsl:apply-templates select="text:index-body"/>
		</xsl:element>

	</xsl:template>
	<xsl:template match="text:index-body">

		<xsl:for-each select="text:p[@text:style-name = 'Index 1']">
			<xsl:element name="indexentry">
				<xsl:element name="primaryie">
					<xsl:value-of select="."/>
				</xsl:element>
				<xsl:if test="key('secondary_children', generate-id())">
					<xsl:element name="secondaryie">
						<xsl:value-of select="key('secondary_children', generate-id())"/>
					</xsl:element>
				</xsl:if>
			</xsl:element>
		</xsl:for-each>

	</xsl:template>
-->
  <!-- default handling of unknown tags for debug
  <xsl:template match="*">
    <xsl:comment>
      <xsl:apply-templates select="." mode="path"/>
      <xsl:value-of select="normalize-space(.)"/>
    </xsl:comment>
  </xsl:template>
  -->
  <xsl:template match="*" name="path" mode="path">
    <xsl:param name="current" select="."/>
    <xsl:for-each select="$current/ancestor-or-self::*">
      <xsl:text>/</xsl:text>
      <xsl:variable name="name" select="name()"/>
      <xsl:value-of select="$name"/>
      <xsl:text>[</xsl:text>
      <xsl:value-of select="count(preceding-sibling::*[name()=$name])+1"/>
      <xsl:text>]</xsl:text>
    </xsl:for-each>
  </xsl:template>
  <xsl:template name="debug">
    <xsl:param name="current" select="/"/>
    <xsl:text disable-output-escaping="yes">&lt;!-- </xsl:text>
    <xsl:apply-templates select="$current" mode="debug"/>
    <xsl:text disable-output-escaping="yes"> --&gt;</xsl:text>
  </xsl:template>
  <xsl:template match="node() | @*" mode="debug">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="debug"/>
    </xsl:copy>
  </xsl:template>
  <!--
	 links - may be to handle for redirections 
-->
  <xsl:template match="text:a | draw:a" name="a" mode="html">
    <a>
      <xsl:attribute name="href">
        <xsl:apply-templates select="@xlink:href"/>
      </xsl:attribute>
      <xsl:attribute name="class">
        <xsl:apply-templates select="@text:style-name | @draw:style-name | @draw:text-style-name"/>
      </xsl:attribute>
      <xsl:apply-templates mode="html"/>
    </a>
  </xsl:template>
  <!-- get title number for anchor and links 
recursive numbering
-->
  <xsl:template match="text:h" name="count-h" mode="number">
    <xsl:param name="level" select="1"/>
    <xsl:param name="number"/>
    <!--
Really tricky to find the good counter with no hierarchy.
count all brothers 

  $start    ) try to get the parent title (if not you are at level 1)
  $position ) find a property easy to compare from outside, count of brothers before (position)
  $count    ) count brother title before to same level, but after start
-->
    <xsl:variable name="start" select="
    
preceding-sibling::text:h[@text:level=($level - 1)][normalize-space(.)!=''][1]
"/>
    <xsl:variable name="position" select="count($start/preceding-sibling::*)+1"/>
    <xsl:variable name="count">
      <xsl:choose>
        <xsl:when test="$start">
          <xsl:value-of select="count(preceding-sibling::text:h[normalize-space(.)!=''][@text:level=$level and count(preceding-sibling::*) +1 &gt;$position])
    "/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="count(preceding-sibling::text:h[@text:level=$level][normalize-space(.)!=''])
    "/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="@text:level = $level">
        <xsl:value-of select="$count + 1"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="parent" select="preceding-sibling::text:h[@text:level = $level][normalize-space(.)!=''][1]"/>
        <a tabindex="-1" href="#{$number}{$count}" title="{$parent}">
          <xsl:value-of select="$count"/>
        </a>
        <xsl:text>.</xsl:text>
        <xsl:call-template name="count-h">
          <xsl:with-param name="level" select="$level+1"/>
          <xsl:with-param name="number" select="concat($number, $count, '.')"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!--

 Notes


-->
  <!-- footnotes -->
  <xsl:template match="text:footnote" mode="html">
    <sup>
      <a href="#{@text:id}" name="_{@text:id}" class="noteref">
        <xsl:apply-templates select="text:footnote-citation" mode="html"/>
      </a>
    </sup>
  </xsl:template>
  <!-- default, pass it -->
  <xsl:template match="*" mode="html-foot">
    <xsl:apply-templates mode="html-foot"/>
  </xsl:template>
  <!-- write nothing -->
  <xsl:template match="text()" mode="html-foot"/>
  <xsl:template match="text:footnote" mode="html-foot">
    <p id="{@text:id}" class="footnote">
      <xsl:apply-templates select="text:footnote-body" mode="html"/>
    </p>
  </xsl:template>
  <!-- put note ref in first paragraph -->
  <xsl:template match="text:footnote-body/text:p[1]" mode="html">
    <div class="footnote">
      <a name="{../../@text:id}" href="#_{../../@text:id}">
        <xsl:apply-templates select="../../text:footnote-citation" mode="html"/>
      </a>
      <xsl:text>&#160;&#160;</xsl:text>
      <xsl:apply-templates mode="html"/>
    </div>
  </xsl:template>
  <!--

bibliography

<text:bibliography-mark text:identifier="html4:meta" text:bibliography-type="manual" text:author="Raggett, Dave (W3C) ; Le Hors, Arnaud (W3C) ; Jacobs, Ian (W3C)" text:note="HTML lets authors specify meta data  information about a document rather than document content - in a variety of ways." text:publisher="W3C (World Wide Web Consortium)" text:title="HTML 4.01 Specification ; 7 The global structure of an HTML document ; 7.4.4 Meta data" text:year="1997" text:url="http://www.w3.org/TR/html4/struct/global.html#h-7.4.4">
-->
  <xsl:template match="text:bibliography-mark" mode="html">
    <a class="bibliomark" href="#{@text:identifier}">
      <xsl:if test="not(@text:identifier = preceding::text:bibliography-mark/@text:identifier)">
        <xsl:attribute name="name">
          <xsl:value-of select="@text:identifier"/>
          <xsl:text>_</xsl:text>
        </xsl:attribute>
      </xsl:if>
      <xsl:text>[</xsl:text>
      <xsl:value-of select="@text:identifier"/>
      <xsl:text>]</xsl:text>
    </a>
  </xsl:template>
  <xsl:template match="text:bibliography-mark" mode="html-foot">
    <p class="bibliorecord">
      <xsl:apply-templates select="@text:identifier" mode="html"/>
      <xsl:apply-templates select="@text:author" mode="html"/>
      <xsl:apply-templates select="@text:title" mode="html"/>
      <xsl:apply-templates select="@text:year" mode="html"/>
      <xsl:apply-templates select="@text:publisher" mode="html"/>
      <xsl:apply-templates select="@text:url" mode="html"/>
      <xsl:apply-templates select="@text:isbn" mode="html"/>
      <xsl:apply-templates select="@text:note" mode="html"/>
    </p>
  </xsl:template>
  <xsl:template match="@text:isbn" mode="html">
    <b class="isbn">
      <xsl:value-of select="."/>
    </b>
  </xsl:template>
  <xsl:template match="@text:url" mode="html">
    <xsl:text>&lt;</xsl:text>
    <a class="identifier" href="{.}">
      <xsl:value-of select="."/>
    </a>
    <xsl:text>&gt; </xsl:text>
  </xsl:template>
  <xsl:template match="@text:note" mode="html">
    <div class="description">
      <xsl:value-of select="."/>
    </div>
  </xsl:template>
  <xsl:template match="@text:publisher" mode="html">
    <span class="publisher">
      <xsl:value-of select="."/>
    </span>
    <xsl:text>. </xsl:text>
  </xsl:template>
  <xsl:template match="@text:year" mode="html">
    <span class="date">
      <xsl:value-of select="."/>
    </span>
    <xsl:text>, </xsl:text>
  </xsl:template>
  <xsl:template match="@text:identifier" mode="html">
    <xsl:text>[</xsl:text>
    <a name="{.}" href="#{.}_" class="identifier">
      <xsl:value-of select="."/>
    </a>
    <xsl:text>] </xsl:text>
  </xsl:template>
  <xsl:template match="@text:author" mode="html">
    <b class="creator">
      <xsl:value-of select="."/>
    </b>
    <xsl:text>. </xsl:text>
  </xsl:template>
  <xsl:template match="@text:title" mode="html">
    <xsl:text>"</xsl:text>
    <a href="{../@text:url}" class="title">
      <xsl:value-of select="."/>
    </a>
    <xsl:text>". </xsl:text>
  </xsl:template>
  <!--


images

-->
  <xsl:template match="draw:image" mode="html">
    <xsl:variable name="page-properties" select="//style:page-master/style:properties"/>
    <xsl:variable name="image-width">
      <xsl:call-template name="convert2mm">
        <xsl:with-param name="value" select="@svg:width"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="page-width">
      <xsl:call-template name="convert2mm">
        <xsl:with-param name="value" select="$page-properties/@fo:page-width"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="margin-left">
      <xsl:call-template name="convert2mm">
        <xsl:with-param name="value" select="$page-properties/@fo:margin-left"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="margin-right">
      <xsl:call-template name="convert2mm">
        <xsl:with-param name="value" select="$page-properties/@fo:margin-right"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="left">
      <xsl:call-template name="convert2mm">
        <xsl:with-param name="value" select="$page-properties/@fo:margin-left"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="right">
      <xsl:call-template name="convert2mm">
        <xsl:with-param name="value" select="$page-properties/@fo:margin-left"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="width-tmp" select="round( ( $image-width div ($page-width - $left - $right))*100)"/>
    <xsl:variable name="width">
      <xsl:choose>
        <xsl:when test="$width-tmp &gt; 100">100</xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$width-tmp"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- 
		
	align support: left, center, right
	rule :
	if x < width/2 =>left
-->
    <xsl:variable name="x">
      <xsl:call-template name="convert2mm">
        <xsl:with-param name="value" select="@svg:x"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="x-middle" select="
(($page-width - $margin-left - $margin-right) div 2) - 
($image-width div 2)"/>
    <xsl:variable name="align">
      <xsl:choose>
        <xsl:when test="($x + $x div 2) &lt; ($x-middle)">left</xsl:when>
        <xsl:when test="($x) &gt; ($x-middle + $x-middle div 2)">right</xsl:when>
        <xsl:otherwise>center</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="size">
      <xsl:call-template name="convert2pixel">
        <xsl:with-param name="value" select="@svg:width"/>
      </xsl:call-template>
    </xsl:variable>
    <!--
		<img alt="{svg:desc}" align="{$align}">
			<xsl:attribute name="src">
				<xsl:apply-templates select="@xlink:href">
					<xsl:with-param name="size" select="$size"/>
				</xsl:apply-templates>
			</xsl:attribute>
		</img>
-->
    <img class="oo" alt="{svg:desc}" align="{$align}" width="{$width}%" border="0">
      <!--
	If image is not in frame or table, a width attribute could be add
		width="{$width}%"

to be sure to have enough pixels, a width is set by pixel
-->
      <xsl:choose>
        <xsl:when test="ancestor::table:table-cell">
          <xsl:attribute name="width">
            <xsl:value-of select="$size"/>
            <xsl:text> px</xsl:text>
          </xsl:attribute>
        </xsl:when>
      </xsl:choose>
      <xsl:attribute name="src">
        <xsl:apply-templates select="@xlink:href"/>
        <!--
        <xsl:text>?size=</xsl:text>
        <xsl:value-of select="$size"/>
-->
      </xsl:attribute>
    </img>
  </xsl:template>
  <!-- changing measure to pixel by via parameter provided dpi (dots per inch) standard factor (cp. section comment) -->
  <xsl:template name="convert2pixel">
    <xsl:param name="value"/>
    <xsl:param name="centimeter-in-mm" select="10"/>
    <xsl:param name="inch-in-mm" select="25.4"/>
    <xsl:param name="didot-point-in-mm" select="0.376065"/>
    <xsl:param name="pica-point-in-mm" select="0.35146"/>
    <xsl:param name="pixel-in-mm" select="$inch-in-mm div $dpi"/>
    <xsl:choose>
      <xsl:when test="contains($value, 'mm')">
        <xsl:value-of select="round(number(substring-before($value, 'mm')) div $pixel-in-mm)"/>
      </xsl:when>
      <xsl:when test="contains($value, 'cm')">
        <xsl:value-of select="round(number(substring-before($value, 'cm')) div $pixel-in-mm * $centimeter-in-mm)"/>
      </xsl:when>
      <xsl:when test="contains($value, 'in')">
        <xsl:value-of select="round(number(substring-before($value, 'in')) div $pixel-in-mm * $inch-in-mm)"/>
      </xsl:when>
      <xsl:when test="contains($value, 'dpt')">
        <xsl:value-of select="round(number(substring-before($value,'dpt')) div $pixel-in-mm * $didot-point-in-mm)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$value"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- convert2mm -->
  <xsl:template name="convert2mm">
    <xsl:param name="value"/>
    <xsl:param name="centimeter-in-mm" select="10"/>
    <xsl:param name="inch-in-mm" select="25.4"/>
    <xsl:param name="didot-point-in-mm" select="0.376065"/>
    <xsl:param name="pica-point-in-mm" select="0.35146"/>
    <xsl:param name="pixel-in-mm" select="$inch-in-mm div $dpi"/>
    <xsl:choose>
      <xsl:when test="contains($value, 'mm')">
        <xsl:value-of select="substring-before($value, 'mm')"/>
      </xsl:when>
      <xsl:when test="contains($value, 'cm')">
        <xsl:value-of select="substring-before($value, 'cm') * 10"/>
      </xsl:when>
      <xsl:when test="contains($value, 'in')">
        <xsl:value-of select="round(number(substring-before($value, 'in')) div $pixel-in-mm * $inch-in-mm)"/>
      </xsl:when>
      <xsl:when test="contains($value, 'dpt')">
        <xsl:value-of select="round(number(substring-before($value,'dpt')) div $pixel-in-mm * $didot-point-in-mm)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$value"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
