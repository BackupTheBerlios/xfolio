<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="../html/xsl2html.xsl"?>
<!--

Title     : Transform OpenOffice.org Writer XML in simple text
Label     : sxw2txt.xsl
Copyright : © 2003, 2004, "ADNX" <http://adnx.org>.
Licence   : "CeCILL" <http://www.cecill.info/licences/Licence_CeCILL_V1.1-US.html> 
            ("GPL" <http://www.gnu.org/copyleft/gpl.html> like)
Creator   : [FG] "Frédéric Glorieux" <frederic.glorieux@ajlsm.com> 
            ("AJLSM" <http://ajlsm.org>)


 = What =

provide a  text version of an sxw XML, 
displayable in a mail, and parsable like a wiki.

 = How =

Style classes handle in this xsl are first standard openOffice. To
define specific styles to handle, best is import this xsl. If possible, 
modify only for better rendering of standard oo.

 = Changes =

 * 2004-07-15 [FG] Wrapping
 * 2004-06-11 [FG] Start for text
 * 2003-11-12 [FG] This work is continued, in the xhtml 
 * 2003-02-12 [FG] The original xsl was designed for docbook.

 =	Bugs =

teletype style is not handled
what to do with placeholder and definition styles ?
the $props of inline template have strange behavior

 =	TODO =

tables, links, preformating, title bar
center ?

 = MAYDO =
What about numerated titles ?
justify right to left ?

 = References =

 * <http://docutils.sourceforge.net/docs/ref/rst/restructuredtext.html>
 * <http://txt2html.sourceforge.net/>
 * <http://www.triptico.com/software/grutatxt.html>
 * <http://snipsnap.org/space/snipsnap-help>

  -->
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:style="http://openoffice.org/2000/style" xmlns:text="http://openoffice.org/2000/text" xmlns:office="http://openoffice.org/2000/office" xmlns:table="http://openoffice.org/2000/table" xmlns:draw="http://openoffice.org/2000/drawing" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:meta="http://openoffice.org/2000/meta" xmlns:number="http://openoffice.org/2000/datastyle" xmlns:svg="http://www.w3.org/2000/svg" xmlns:chart="http://openoffice.org/2000/chart" xmlns:dr3d="http://openoffice.org/2000/dr3d" xmlns:math="http://www.w3.org/1998/Math/MathML" xmlns:form="http://openoffice.org/2000/form" xmlns:script="http://openoffice.org/2000/script" xmlns:config="http://openoffice.org/2001/config" office:class="text" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:i18n="http://apache.org/cocoon/i18n/2.1" exclude-result-prefixes="office meta  table number dc fo xlink chart math script xsl draw svg dr3d form config text style i18n">
  <!-- to get some centralized resolutions (styleNames, links) -->
  <xsl:import href="sxw-common.xsl"/>
  <!-- text version -->
  <xsl:output encoding="UTF-8" method="text"/>
  <!-- Carriage return -->
  <xsl:param name="CR" select="'&#13;'"/>
  <!-- global width -->
  <xsl:param name="width" select="72"/>
  <xsl:variable name="office:meta" select=".//office:meta"/>
  <xsl:variable name="office:automatic-styles" select=".//office:automatic-styles"/>
  <xsl:variable name="office:body" select=".//office:body"/>
  <!-- 
These variables are used to normalize names of styles
-->
  <xsl:variable name="majs" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZÀÁÂÃÄÅÆÈÉÊËÌÍÎÏÐÑÒÓÔÕÖÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõöùúûüýÿþ .()/\?'"/>
  <xsl:variable name="mins" select="'abcdefghijklmnopqrstuvwxyzaaaaaaaeeeeiiiidnooooouuuuybbaaaaaaaceeeeiiiionooooouuuuyyb------'"/>
  <xsl:variable name="spaces" select="'                                                                                                    '"/>
  <xsl:variable name="hr">--------------------------------------------------------------------------------------------------------------</xsl:variable>
  <xsl:variable name="hr1">====================================================================================================</xsl:variable>
  <xsl:variable name="hr2">-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=</xsl:variable>
  <xsl:variable name="hr4">~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~</xsl:variable>
  <xsl:variable name="hr5">++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++</xsl:variable>
  <!--

  root template for an oo the document

-->
  <xsl:template match="/">
    <root>
      <xsl:apply-templates select="$office:body" mode="text"/>
      <!-- foot refernces -->
      <xsl:if test="$office:body//text:footnote or $office:body//text:bibliography-mark">
        <xsl:value-of select="$CR"/>
        <xsl:value-of select="$CR"/>
        <xsl:value-of select="substring($hr, 1,$width)"/>
        <xsl:value-of select="$CR"/>
        <xsl:apply-templates select="$office:body//text:footnote" mode="text-foot"/>
        <xsl:value-of select="$CR"/>
        <xsl:value-of select="$CR"/>
        <xsl:apply-templates select="$office:body//text:bibliography-mark[not(@text:identifier = following::text:bibliography-mark/@text:identifier)]" mode="text-foot">
          <xsl:sort select="@text:identifier"/>
        </xsl:apply-templates>
      </xsl:if>
    </root>
  </xsl:template>
  <!-- stop elements -->
  <xsl:template match="text:h[normalize-space(.)='']" mode="text"/>  
  <xsl:template match="text:bibliography | text:bibliography-source" mode="text"/>
  <xsl:template match="office:script" mode="text"/>
  <xsl:template match="office:settings" mode="text"/>
  <xsl:template match="office:font-decls" mode="text"/>
  <xsl:template match="text:bookmark-end" mode="text"/>
  <xsl:template match="text:reference-mark-start" mode="text"/>
  <xsl:template match="text:reference-mark-end" mode="text"/>
  <xsl:template match="office:styles | office:master-styles | office:automatic-styles" mode="text"/>
  <xsl:template match="text:tracked-changes" mode="text"/>
  <xsl:template match="office:forms | text:sequence-decls" mode="text"/>
  <!-- pass elements -->
  <xsl:template match="text()" mode="text">
    <xsl:choose>
      <!-- for inline -->
      <xsl:when test="normalize-space(.) =''"/>
      <xsl:otherwise>
        <xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="*" mode="text">
    <xsl:apply-templates mode="text"/>
  </xsl:template>
  <xsl:template match="text:section | office:body" mode="text">
    <xsl:apply-templates mode="text"/>
  </xsl:template>
  <!-- 

process a table of contents only if requested in the source 

	-->
  <xsl:template match="text:table-of-content" mode="text">
    <xsl:apply-templates select="$office:body/text:h" mode="text-toc"/>
  </xsl:template>
  <xsl:template match="text:h" mode="text-toc">
    <xsl:value-of select="$CR"/>
    <xsl:value-of select="substring('                         ', 1, number(@text:level) * 2)"/>
    <xsl:variable name="number">
      <xsl:apply-templates select="." mode="text-number"/>
    </xsl:variable>
    <xsl:value-of select="normalize-space($number)"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="."/>
  </xsl:template>
  <!-- get title number for anchor and links 
recursive numbering
-->
  <xsl:template match="text:h" name="count-h" mode="text-number">
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
        <xsl:text>.</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$count"/>
        <xsl:text>.</xsl:text>
        <xsl:call-template name="count-h">
          <xsl:with-param name="level" select="$level+1"/>
          <xsl:with-param name="number" select="concat($number, $count, '.')"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!--
	sectionning
	-->
  <xsl:template match="text:h" mode="text">
    <xsl:value-of select="$CR"/>
    <xsl:value-of select="$CR"/>
    <xsl:value-of select="substring('==========', 1, @text:level)"/>
    <xsl:text> </xsl:text>
    <xsl:apply-templates mode="text"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="substring('==========', 1, @text:level)"/>
    <xsl:value-of select="$CR"/>
    <xsl:value-of select="$CR"/>
  </xsl:template>
  <!--


	 handle blocks, give them an HTML form on semantic styles 


-->
  <xsl:template match="text:p" mode="text">
    <xsl:param name="indent"/>
    <xsl:param name="first-line"/>
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
    <!-- store the block in a variable to process it later -->
    <xsl:variable name="text">
      <xsl:apply-templates mode="text"/>
    </xsl:variable>
    <xsl:choose>
      <!--  empty block -->
      <xsl:when test="normalize-space(.)='' and not(*[name()!='text:change'])"/>
      <xsl:when test="ancestor::text:list-item">
        <xsl:call-template name="wrap">
          <xsl:with-param name="text" select="$text"/>
          <xsl:with-param name="indent" select="3"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$style='standard' or $style='default' or $style='text-body'">
        <xsl:call-template name="wrap">
          <xsl:with-param name="text" select="$text"/>
        </xsl:call-template>
        <xsl:value-of select="$CR"/>
      </xsl:when>
      <xsl:when test="$style='first-line-indent'">
        <xsl:value-of select="$CR"/>
        <xsl:call-template name="wrap">
          <xsl:with-param name="text" select="$text"/>
          <xsl:with-param name="first-line" select="4"/>
        </xsl:call-template>
      </xsl:when>
      <!-- handling of fields -->
      <xsl:when test="(text:title or $style='title') and normalize-space(.)!=''">
        <xsl:value-of select="$CR"/>
        <xsl:call-template name="wrap">
          <xsl:with-param name="text" select="$text"/>
        </xsl:call-template>
        <xsl:value-of select="concat(substring($hr1, 1,$width), $CR)"/>
      </xsl:when>
      <xsl:when test="($style='subtitle' or text:subject) and normalize-space(.)!=''">
        <xsl:value-of select="$CR"/>
        <xsl:call-template name="wrap">
          <xsl:with-param name="text" select="$text"/>
        </xsl:call-template>
        <xsl:value-of select="$CR"/>
      </xsl:when>
      <!-- Definition list -->
      <xsl:when test="$style='list-heading' or $style='dt'">
        <xsl:value-of select="$CR"/>
        <xsl:value-of select="."/>
      </xsl:when>
      <xsl:when test="$style = 'list-contents' or $style = 'dd'">
        <xsl:value-of select="$CR"/>
        <xsl:call-template name="wrap">
          <xsl:with-param name="text" select="$text"/>
          <xsl:with-param name="indent" select="4"/>
        </xsl:call-template>
      </xsl:when>
      <!--  -->
      <xsl:when test="contains($style, 'bibliography')">
        <xsl:value-of select="$CR"/>
        <!-- don't process inline in biblio record -->
        <xsl:call-template name="wrap">
          <xsl:with-param name="text" select="."/>
          <xsl:with-param name="indent" select="4"/>
          <xsl:with-param name="first-line" select="-4"/>
        </xsl:call-template>
      </xsl:when>
      <!-- abstract -->
      <xsl:when test="text:description or $style='abstract'">
        <xsl:if test="not ($prev='abstract')">
          <xsl:value-of select="concat($CR, substring($hr, 1,$width - 1), ' ')"/>
          <xsl:value-of select="$CR"/>
        </xsl:if>
        <xsl:call-template name="wrap">
          <xsl:with-param name="text" select="$text"/>
        </xsl:call-template>
        <xsl:if test="not ($next='abstract')">
          <xsl:value-of select="concat($CR, substring($hr, 1 , $width), ' ')"/>
          <xsl:value-of select="$CR"/>
        </xsl:if>
      </xsl:when>
      <!-- indent ? -->
      <xsl:when test="$style='quotations' or contains($style, 'blockquote')">
        <xsl:call-template name="wrap">
          <xsl:with-param name="text" select="$text"/>
          <xsl:with-param name="indent" select="4"/>
        </xsl:call-template>
      </xsl:when>
      <!-- TODO, better format here, prev-next and no wrap -->
      <xsl:when test="$style='preformatted-text'">
        <xsl:value-of select="$CR"/>
        <xsl:value-of select="$CR"/>
        <xsl:text>{{{</xsl:text>
        <xsl:value-of select="$CR"/>
        <xsl:apply-templates mode="text"/>
        <xsl:value-of select="$CR"/>
        <xsl:text>}}}</xsl:text>
        <xsl:value-of select="$CR"/>
        <xsl:value-of select="$CR"/>
      </xsl:when>
      <xsl:when test="$style='horizontal-line'">
        <xsl:value-of select="$CR"/>
        <xsl:value-of select="$CR"/>
        <xsl:value-of select="substring($hr, 1,$width)"/>
        <xsl:value-of select="$CR"/>
        <xsl:value-of select="$CR"/>
      </xsl:when>
      <xsl:when test="$style='comment'">
        <xsl:value-of select="$CR"/>
        <xsl:value-of select="$CR"/>
        <xsl:text>;:''</xsl:text>
        <xsl:apply-templates mode="text"/>
        <xsl:text>''</xsl:text>
        <xsl:value-of select="$CR"/>
        <xsl:value-of select="$CR"/>
      </xsl:when>
      <!-- ??? addressee, sender, salutation, signature -->
      <xsl:otherwise>
        <xsl:call-template name="wrap">
          <xsl:with-param name="text" select="$text"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- an anchor, what about renaming anchors ? -->
  <xsl:template match="text:bookmark-start | text:bookmark" mode="text">
    <xsl:value-of select="$CR"/>
    <xsl:text>[</xsl:text>
    <xsl:value-of select="@text:name"/>
    <xsl:text>] </xsl:text>
  </xsl:template>
  <!-- whats annotation ? -->
  <xsl:template match="office:annotation/text:p" mode="text"/>
  <!--
TODO table 


-->
  <!-- 

lists 

-->
  <xsl:template match="text:ordered-list | text:unordered-list" mode="text">
    <xsl:apply-templates mode="text"/>
    <!-- workaround for bad oo XML output -->
    <xsl:if test="not(contains (name(following-sibling::*[1]) , 'list')) 
 and not(ancestor::text:unordered-list | ancestor::text:ordered-list)">
      <xsl:value-of select="$CR"/>
    </xsl:if>
  </xsl:template>
  <!-- item -->
  <xsl:template match="text:list-item" mode="text">
    <!-- TODO, should be better -->
    <xsl:if test="not(text:h)">
      <xsl:for-each select="ancestor::text:ordered-list">
        <xsl:text>#</xsl:text>
      </xsl:for-each>
      <xsl:for-each select="ancestor::text:unordered-list">
        <xsl:text>*</xsl:text>
      </xsl:for-each>
    </xsl:if>
    <!-- ?? is it the best for formatting ?? -->
    <xsl:variable name="text">
      <xsl:apply-templates select="*[not(contains(local-name(), 'list'))]" mode="text">
        <xsl:with-param name="indent" select="count(ancestor::text:unordered-list | ancestor::text:ordered-list) * 2"/>
        <xsl:with-param name="first-line" select="count(ancestor::text:unordered-list | ancestor::text:ordered-list) * 1"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:value-of select="$text"/>
    <!-- process nested list-item -->
    <xsl:apply-templates select="*[contains(local-name(), 'list')]" mode="text"/>
  </xsl:template>
  <!--
  
  TODO media links
  
  
  -->
  <!-- do something with those frames ? -->
  <xsl:template match="draw:*" mode="text">
    <xsl:value-of select="$CR"/>
    <xsl:value-of select="$CR"/>
    <xsl:text>----</xsl:text>
    <xsl:value-of select="$CR"/>
    <xsl:apply-templates mode="text"/>
    <xsl:value-of select="$CR"/>
    <xsl:text>----</xsl:text>
    <xsl:value-of select="$CR"/>
    <xsl:value-of select="$CR"/>
  </xsl:template>
  <!-- 

handle inline, and give an html form to each default style 

-->
  <xsl:template match="text:span" mode="text">
    <xsl:variable name="style-att" select="@text:style-name"/>
    <xsl:variable name="style">
      <xsl:choose>
        <xsl:when test="starts-with($style-att, 'T')">
          <xsl:value-of select="$office:automatic-styles/style:style[@style:name=$style-att]/@style:parent-style-name"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="translate($style-att, $majs, $mins)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- get bold and other CSS properties from automatic style -->
    <xsl:variable name="props" select="//style:style[@style:name=$style-att]"/>
    <xsl:choose>
      <!-- handle empty nodes to avoid strange behavior of browsers on xhtml -->
      <xsl:when test="normalize-space(.)='' and not(*)"/>
      <xsl:when test="$style='emphasis'">
        <xsl:text>''</xsl:text>
        <xsl:apply-templates mode="text"/>
        <xsl:text>''</xsl:text>
      </xsl:when>
      <xsl:when test="$style='citation'">
        <xsl:text>''</xsl:text>
        <xsl:apply-templates mode="text"/>
        <xsl:text>''</xsl:text>
      </xsl:when>
      <!-- ??
      <xsl:when test="$style='sub'">
        <sub>
          <xsl:apply-templates mode="text"/>
        </sub>
      </xsl:when>
      <xsl:when test="$style='sup'">
        <sup>
          <xsl:apply-templates mode="text"/>
        </sup>
      </xsl:when>
-->
      <xsl:when test="$style='example'">
        <xsl:text>{{</xsl:text>
        <xsl:apply-templates mode="text"/>
        <xsl:text>}}</xsl:text>
      </xsl:when>
      <xsl:when test="$style='teletype'">
        <xsl:text>{{</xsl:text>
        <xsl:apply-templates mode="text"/>
        <xsl:text>}}</xsl:text>
      </xsl:when>
      <xsl:when test="$style='user-entry'">
        <xsl:text>{{''</xsl:text>
        <xsl:apply-templates mode="text"/>
        <xsl:text>''}}</xsl:text>
      </xsl:when>
      <xsl:when test="$style='source-text'">
        <xsl:text>{{</xsl:text>
        <xsl:apply-templates mode="text"/>
        <xsl:text>}}</xsl:text>
      </xsl:when>
      <xsl:when test="$style='definition'">
        <xsl:apply-templates mode="text"/>
      </xsl:when>
      <xsl:when test="$style='placeholder'">
        <xsl:apply-templates mode="text"/>
      </xsl:when>
      <xsl:when test="$style='emphasis-bold'">
        <xsl:text>*</xsl:text>
        <xsl:apply-templates mode="text"/>
        <xsl:text>*</xsl:text>
      </xsl:when>
      <xsl:when test="$props">
        <xsl:choose>
          <xsl:when test="$props/style:properties/@fo:font-weight = 'bold'
and $props/style:properties/@fo:font-style='italic'">
            <xsl:text>__''</xsl:text>
            <xsl:apply-templates mode="text"/>
            <xsl:text>''__</xsl:text>
          </xsl:when>
          <xsl:when test="$props/style:properties/@fo:font-weight = 'bold'">
            <xsl:text>*</xsl:text>
            <xsl:apply-templates mode="text"/>
            <xsl:text>*</xsl:text>
          </xsl:when>
          <xsl:when test="$props/style:properties/@fo:font-style='italic'">
            <xsl:text>''</xsl:text>
            <xsl:apply-templates mode="text"/>
            <xsl:text>''</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates mode="text"/>
          </xsl:otherwise>
          <!--
          <xsl:when test="$props/style:properties/@style:text-underline">
              <xsl:apply-templates mode="text"/>
          </xsl:when>
-->
        </xsl:choose>
      </xsl:when>
      <!-- FG:2004-06-10, never used, why ? -->
      <xsl:otherwise>
        <xsl:apply-templates mode="text"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- line break -->
  <xsl:template match="text:line-break" mode="text">
    <xsl:value-of select="$CR"/>
  </xsl:template>
  <xsl:template match="text:tab-stop" mode="text">
    <xsl:text>&#160;&#160;&#160;&#160;</xsl:text>
  </xsl:template>
  <!--    
        <text:h text:level="1">Part One Title
            <text:reference-mark-start text:name="part"/>
            <text:p text:style-name="Text body">
                <text:span text:style-name="XrefLabel">xreflabel_part</text:span>
            </text:p>
            <text:reference-mark-end text:name="part"/>
        </text:h>
-->
  <xsl:template match="comment" mode="text">
    <xsl:value-of select="$CR"/>
    <xsl:value-of select="$CR"/>
    <xsl:text>;:''</xsl:text>
    <xsl:apply-templates select="." mode="text"/>
    <xsl:text>''</xsl:text>
    <xsl:value-of select="$CR"/>
    <xsl:value-of select="$CR"/>
  </xsl:template>
  <!--

 Notes


-->
  <!-- footnotes -->
  <xsl:template match="text:footnote" mode="text">
    <xsl:text>[</xsl:text>
    <xsl:value-of select="text:footnote-citation"/>
    <xsl:text>]</xsl:text>
  </xsl:template>
  <!-- default, pass it -->
  <xsl:template match="*" mode="text-foot">
    <xsl:apply-templates mode="text-foot"/>
  </xsl:template>
  <!-- write nothing -->
  <xsl:template match="text()" mode="text-foot"/>
  <xsl:template match="text:footnote" mode="text-foot">
    <xsl:value-of select="$CR"/>
    <xsl:value-of select="$CR"/>
    <xsl:text> [</xsl:text>
    <xsl:value-of select="text:footnote-citation"/>
    <xsl:text>] </xsl:text>
    <xsl:apply-templates select="text:footnote-body" mode="text"/>
  </xsl:template>
  <!-- first para of a footnote -->
  <xsl:template match="text:footnote-body/text:p[1]" mode="text">
    <xsl:apply-templates mode="text"/>
    <xsl:value-of select="$CR"/>
  </xsl:template>
  <!--
images
[alternate text|http://example.com/example.png]
image works only for absolute links
-->
  <xsl:template match="draw:image" mode="text">
    <xsl:choose>
      <xsl:when test="starts-with(@xlink:href, 'http://')">
        <xsl:text>[</xsl:text>
        <!-- alternate text -->
        <xsl:choose>
          <xsl:when test="normalize-space(svg:desc) != ''">
            <xsl:value-of select="svg:desc"/>
            <xsl:text>|</xsl:text>
          </xsl:when>
          <xsl:when test="normalize-space(@draw:name) != ''">
            <xsl:value-of select="@draw:name"/>
            <xsl:text>|</xsl:text>
          </xsl:when>
        </xsl:choose>
        <xsl:value-of select="@xlink:href"/>
        <xsl:text>]</xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <!-- 
	template to resolve internal image links 

-->
  <xsl:template match="draw:image/@xlink:href" mode="text">
    <!--
What should I do there ? 
   <xsl:variable name="path" select="."/>
    <xsl:choose>
      <xsl:when test="contains($path, '#Pictures/')">
        <xsl:value-of select="concat($pictures, substring-after($path, '#'))"/>
      </xsl:when>
      <xsl:when test="not(contains($path, 'http://'))">
        <xsl:value-of select="$path"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
-->
  </xsl:template>
  <!--
bibliography
  -->
  <!-- process bibliographic attributes as pure text -->
  <xsl:template match="text:bibliography-mark" mode="text-foot">
    <xsl:variable name="text">
      <xsl:apply-templates select="@text:identifier" mode="text"/>
      <xsl:apply-templates select="@text:author" mode="text"/>
      <xsl:apply-templates select="@text:title" mode="text"/>
      <xsl:apply-templates select="@text:year" mode="text"/>
      <xsl:apply-templates select="@text:publisher" mode="text"/>
      <xsl:apply-templates select="@text:url" mode="text"/>
    </xsl:variable>
    <xsl:call-template name="wrap">
        <xsl:with-param name="text" select="$text"/>
        <xsl:with-param name="indent" select="4"/>
        <xsl:with-param name="first-line" select="-4"/>
    </xsl:call-template>
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
  <!--

a text word wrap


-->
  <xsl:template name="wrap">
    <!-- reduce it at each line -->
    <xsl:param name="text" select="."/>
    <!-- keep it it on loop -->
    <xsl:param name="indent" select="0"/>
    <!-- forget it after first line -->
    <xsl:param name="first-line" select="0"/>
    <!-- global width of para, don't forget to keep it on loops ! -->
    <xsl:param name="width" select="$width"/>
    <!-- index to run on -->
    <xsl:param name="i" select="$width - $first-line - $indent"/>
    <xsl:choose>
      <!-- stop -->
      <xsl:when test="normalize-space($text) =''"/>
      <!-- write a line on a break space, or last line -->
      <xsl:when test="
(string-length($text) &lt;= $i) or (substring($text, $i, 1) = ' ') or (not(contains($text, ' ')))">
        <!--
        <xsl:choose>
          <xsl:when test="number($first-line)">
            <xsl:value-of select="substring($spaces, 1, $first-line)"/>
          </xsl:when>
          <xsl:when test="number($indent)">
            <xsl:value-of select="substring($spaces, 1, $indent)"/>
          </xsl:when>
        </xsl:choose>
-->
        <xsl:value-of select="substring($spaces, 1, $first-line + $indent)"/>
        <!-- right or center align ? -->
        <xsl:value-of select="substring($text, 1, $i)"/>
        <xsl:value-of select="$CR"/>
        <xsl:call-template name="wrap">
          <xsl:with-param name="text" select="substring($text, $i+1)"/>
          <xsl:with-param name="indent" select="$indent"/>
          <xsl:with-param name="width" select="$width"/>
        </xsl:call-template>
      </xsl:when>
      <!-- keep break lines ? -->
      <!--
      <xsl:when test="contains($text, $break)">
        <xsl:value-of select="substring-before($text, $break)"/>
        <xsl:value-of select="$break"/>
        <xsl:call-template name="wrap">
          <xsl:with-param name="text" select="substring-after($text, $break)"/>
        </xsl:call-template>
      </xsl:when>
-->
      <!-- a long non breaking line, cut after, !! careful of infinite loop -->
      <xsl:when test="not(contains(substring($text, 1, $i), ' '))">
        <xsl:call-template name="wrap">
          <xsl:with-param name="i" select="$i+1"/>
          <xsl:with-param name="text" select="$text"/>
          <xsl:with-param name="indent" select="$indent"/>
          <xsl:with-param name="first-line" select="$first-line"/>
          <xsl:with-param name="width" select="$width"/>
        </xsl:call-template>
      </xsl:when>
      <!-- not on the break space, cut before -->
      <xsl:when test="substring($text, $i, 1) != ' '">
        <xsl:call-template name="wrap">
          <xsl:with-param name="i" select="$i - 1"/>
          <xsl:with-param name="text" select="$text"/>
          <xsl:with-param name="indent" select="$indent"/>
          <xsl:with-param name="first-line" select="$first-line"/>
          <xsl:with-param name="width" select="$width"/>
        </xsl:call-template>
      </xsl:when>
      <!-- should never arrive -->
      <xsl:otherwise>
        <xsl:text> textwrap, unhandled case </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
