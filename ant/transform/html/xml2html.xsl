<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="xml2html.xsl"?>
<!--
SDX: Documentary System in XML.
Copyright : (C) 2000, 2001, 2002, 2003, 2004 Ministere de la culture et de la communication (France), AJLSM
Licence   : http://www.fsf.org/copyleft/gpl.html

 history
	Have been part of SDX distrib

 goal
	 displaying xml source in various format (html, text)

 author
	 frederic.glorieux@ajlsm.com


 usage :
	 fast test, apply this to itself, look at that in a xsl browse compliant
   as a root xsl matching all elements
   as an import xsl to format some xml
     with <xsl:apply-templates select="node()" mode="xml:html"/>
     in this case you need to copy css and js somewhere to link with

 features :
   DOM compatible hide/show
   double click to expand all
   old browser compatible
   no extra characters to easy copy/paste code
   html formatting oriented for logical css
   commented to easier adaptation
   all xmlns:*="uri" attributes in root node
   text reformating ( xml entities )

 problems :
   <![CDATA[ node ]]> can't be shown (processed by xml parser before xsl transformation)

 TODOs

 - FIX edit mode

 +-->
<xsl:stylesheet version="1.1" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" exclude-result-prefixes="xsl">
  <xsl:output indent="no" method="xml" encoding="UTF-8" cdata-section-elements="cdata"/>
  <xsl:param name="pre" select="false()"/>
  <!-- load this document, to be sure it will only one time -->
  <xsl:variable name="document" select="document('')"/>
  <!-- encoding of the HTML output, default is the one specified in xsl:output -->
  <xsl:param name="encoding" select="$document/*/xsl:output/@encoding"/>
  <!-- 
not used, but could be interesting to show content in <![CDATA[ declaration ]]> 
especially for script where no chars should be expected
  -->
  <xsl:param name="cdatas" select="concat(' cdata ', normalize-space(/*/*/@cdata-section-elements), ' ')"/>
  <!-- elements with preformated content -->
  <xsl:param name="pres" select="' style script litterallayout pre text '"/>
  <!-- a break line, tested on IE, Mozilla, XMLSpy. For long attribute value -->
  <xsl:param name="CR" select="'&#10;'"/>
  <!-- pattern for xml entities -->
  <xsl:variable name="xmlents" select="'&amp;:&amp;amp;,&gt;:&amp;gt;,&lt;:&amp;lt;'"/>
  <!-- 

namespace documentation URI


-->
  <xsl:template match="node() | @*" mode="xml:uri"/>
  <xsl:template match="node()" mode="xml:uri">
    <xsl:variable name="namespace-uri" select="namespace-uri()"/>
    <xsl:value-of select="$namespace-uri"/>
    <xsl:if test="substring($namespace-uri, string-length($namespace-uri)) != '#'">#</xsl:if>
    <xsl:value-of select="local-name()"/>
  </xsl:template>
  <xsl:template match="*[namespace-uri()='http://www.w3.org/1999/XSL/Transform']" mode="xml:uri">
    <xsl:text>http://www.w3.org/TR/xslt#element-</xsl:text>
    <xsl:value-of select="local-name()"/>
  </xsl:template>
  <!-- link HTML elements to the elements index of W3C site -->
  <xsl:template match="*[namespace-uri()='http://www.w3.org/1999/xhtml']" mode="xml:uri">
    <xsl:text>http://www.w3.org/TR/REC-html40/index/elements.html</xsl:text>
  </xsl:template>
  <!-- link HTML attributes to the elements index of W3C site -->
  <xsl:template match="*[namespace-uri()='http://www.w3.org/1999/xhtml']/@*" mode="xml:uri">
    <xsl:text>http://www.w3.org/TR/REC-html40/index/attributes.html</xsl:text>
  </xsl:template>
  <!-- HTML style attribute, link to CSS -->
  <xsl:template match="@style | style" mode="xml:uri">
    <xsl:text>http://www.w3.org/TR/REC-CSS2/propidx.html</xsl:text>
  </xsl:template>
  <!-- XSL @match attribute, linked to xpath -->
  <xsl:template match="@match" mode="xml:uri">
    <xsl:text>http://www.w3.org/TR/xpath#path-abbrev</xsl:text>
  </xsl:template>
  <!--
     |    ROOT ? to verify in cas of imports
     |-->
  <xsl:template match="/">
    <xsl:call-template name="xml:html"/>
  </xsl:template>
  <!-- template to call from everywhere with a nodeset compatible processor -->
  <xsl:template name="xml2html">
    <xsl:param name="xml" select="."/>
    <xsl:apply-templates select="$xml" mode="xml:html"/>
  </xsl:template>
  <!-- no match here for import -->
  <xsl:template name="xml:html">
    <xsl:param name="content" select="/node()"/>
    <xsl:param name="title" select="'XML - source'"/>
    <html>
      <head>
        <title>
          <xsl:value-of select="$title"/>
        </title>
        <meta http-equiv="Content-type">
          <xsl:attribute name="content">
            <xsl:text>text/html; charset=</xsl:text>
            <xsl:value-of select="$encoding"/>
          </xsl:attribute>
        </meta>
        <xsl:call-template name="xml:css"/>
        <xsl:call-template name="xml:swap"/>
      </head>
      <body ondblclick="if(window.swap_all)swap_all(this)">
        <div class="xml">
          <div class="xml_pi">
            <xsl:text>&lt;?xml version="1.0" encoding="</xsl:text>
            <xsl:value-of select="$encoding"/>
            <xsl:text>"?&gt;</xsl:text>
          </div>
          <xsl:apply-templates select="$content" mode="xml:html"/>
        </div>
      </body>
    </html>
  </xsl:template>
  <!-- script -->
  <xsl:template name="xml:swap">
    <script type="text/javascript"><![CDATA[
    function swap(id) {
      if (!document.getElementById) return true; 
      if (!id) return true;
      var o=document.getElementById(id); 
      if (!o || !o.style) return true; 
      o.style.display=(o.style.display == 'none')?'':'none'; 
      return false;
    }
]]></script>
  </xsl:template>
  <!-- PI -->
  <xsl:template match="processing-instruction()" mode="xml:html">
    <span class="xml_pi">
      <xsl:apply-templates select="." mode="xml:text"/>
    </span>
  </xsl:template>
  <!-- add xmlns declarations, probably better only for the root -->
  <xsl:template name="xml:ns">
    <xsl:value-of select="name()"/>
    <xsl:variable name="ns" select="../namespace::*"/>
    <xsl:for-each select="namespace::*">
      <xsl:if test="
            name() != 'xml' 
            and (
                not(. = $ns) 
                or not($ns[name()=name(current())])
            )">
        <xsl:value-of select="' '"/>
        <span class="att">
          <xsl:text>xmlns</xsl:text>
          <xsl:if test="normalize-space(name())!=''">
            <xsl:text>:</xsl:text>
            <span class="ns">
              <xsl:value-of select="name()"/>
            </span>
          </xsl:if>
        </span>
        <xsl:text>="</xsl:text>
        <span class="val">
          <xsl:value-of select="."/>
        </span>
        <xsl:text>"</xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
  <!-- matching attribute -->
  <xsl:template match="@*" mode="xml:html">
    <!-- try to get an uri for this attribute name -->
    <xsl:variable name="uri">
      <xsl:apply-templates select="." mode="xml:uri"/>
    </xsl:variable>
    <xsl:value-of select="' '"/>
    <xsl:choose>
      <xsl:when test="normalize-space($uri) != ''">
        <a href="{$uri}" class="att">
          <xsl:value-of select="name()"/>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <span>
          <xsl:value-of select="name()"/>
        </span>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>=&quot;</xsl:text>
    <xsl:apply-templates select="." mode="xml:value"/>
    <xsl:text>"</xsl:text>
  </xsl:template>
  <!-- matching attribute value, may be overided -->
  <xsl:template match="@*" mode="xml:value">
  <!-- value of an attribute should be inline, 
except the case of very long values where a preformatted block is more readable -->
    <xsl:choose>
      <xsl:when test="string-length(normalize-space(.)) &gt; 30">
        <pre class="val">
          <xsl:call-template name="xml:value"/>
        </pre>
      </xsl:when>
      <xsl:otherwise>
        <span class="val">
          <xsl:call-template name="xml:value"/>
        </span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- provide the value of an attribute, with some text escaping -->
  <xsl:template name="xml:value">
    <xsl:param name="text" select="."/>
      <!--
    <xsl:variable name="br">
      <br/>
    </xsl:variable>
    <xsl:variable name="value">
       <xsl:choose>
        <xsl:when test="contains(., $CR)">
          
        </xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
      -->
      <xsl:choose>
        <xsl:when test="
                    (contains(., '&amp;') 
                    or contains(., '&lt;')
                    or contains(., '&gt;')
                    or contains(., '&quot;'))
                    ">
          <xsl:call-template name="replace">
            <xsl:with-param name="text" select="."/>
            <xsl:with-param name="pattern" select="concat($xmlents, '&quot;:&amp;quot')"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="."/>
        </xsl:otherwise>
      </xsl:choose>
  </xsl:template>
  <!--  text -->
  <!--
    <xsl:template match="text()[normalize-space(.)='']" mode="xml:html">
    </xsl:template>
    ? -->
  <!--
    <xsl:template match="text()[normalize-space(.)='']" mode="xml:html"/>
-->
  <xsl:template match="text()" mode="xml:html">
    <xsl:param name="text" select="."/>
    <span class="text">
      <xsl:choose>
        <xsl:when test="
                    contains(., '&amp;') 
                    or contains(., '&lt;')
                    or contains(., '&gt;')
                    ">
          <xsl:call-template name="replace">
            <xsl:with-param name="text" select="$text"/>
            <xsl:with-param name="pattern" select="$xmlents"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </span>
  </xsl:template>
  <!-- comment -->
  <xsl:template match="comment()" mode="xml:html">
    <pre class="comment">
      <a href="#i" class="click" id="src{generate-id()}" onclick="if (window.swap) return swap('{generate-id()}'); ">&lt;</a>
      <xsl:text>!--</xsl:text>
      <i id="{generate-id()}">
        <xsl:value-of select="."/>
      </i>
      <xsl:text>--</xsl:text>
      <a class="click">&gt;</a>
    </pre>
  </xsl:template>
  <!-- 

handling elements

  -->
  <xsl:template match="*" name="xml:tag" mode="xml:html">
    <xsl:param name="id" select="generate-id()"/>
    <xsl:param name="inline" select="normalize-space(../text())!=''"/>
    <xsl:param name="content" select="
text()[normalize-space(.)!=''] 
| comment() | processing-instruction() | *"/>
    <xsl:choose>
      <!-- empty inline -->
      <xsl:when test="$inline and not($content)">
        <span class="tag">
          <xsl:text>&lt;</xsl:text>
          <xsl:call-template name="xml:element"/>
          <xsl:apply-templates select="@*" mode="xml:html"/>
          <xsl:text> /&gt;</xsl:text>
        </span>
      </xsl:when>
      <!-- empty block -->
      <xsl:when test="not($content)">
        <div class="tag">
          <xsl:text>&lt;</xsl:text>
          <xsl:call-template name="xml:element"/>
          <xsl:apply-templates select="@*" mode="xml:html"/>
          <xsl:text> /&gt;</xsl:text>
        </div>
      </xsl:when>
      <!-- inline -->
      <xsl:when test="$inline">
        <span class="tag">
          <xsl:text>&lt;</xsl:text>
          <xsl:call-template name="xml:element"/>
          <xsl:apply-templates select="@*" mode="xml:html"/>
          <xsl:text>&gt;</xsl:text>
        </span>
        <xsl:apply-templates select="node()" mode="xml:html">
          <xsl:with-param name="inline" select="true()"/>
        </xsl:apply-templates>
        <span class="tag">
          <xsl:text>&lt;</xsl:text>
          <xsl:call-template name="xml:element"/>
          <xsl:text>&gt;</xsl:text>
        </span>
      </xsl:when>
      <!-- preformated element -->
      <xsl:when test="@xml:space='preserve' or contains($pres, concat(' ', local-name(), ' '))">
        <pre class="content">
          <span class="tag">
            <a class="click" href="#close{$id}" name="open{$id}" onclick="if (window.swap) return swap('{$id}');">
              <xsl:text>&lt;</xsl:text>
            </a><xsl:call-template name="xml:element"/>
            <xsl:apply-templates select="@*" mode="xml:html"/>
            <xsl:text>&gt;</xsl:text>
          </span><span id="{$id}">
            <xsl:apply-templates select="node()" mode="xml:html">
              <xsl:with-param name="inline" select="true()"/>
            </xsl:apply-templates>
          </span><span class="tag"><a class="click">&lt;</a>
            <xsl:text>/</xsl:text>
            <xsl:call-template name="xml:element"/>
            <xsl:text>&gt;</xsl:text>
          </span>
        </pre>
      </xsl:when>
      <!-- mixed block -->
      <xsl:when test="normalize-space(text())!='' and *">
        <div class="xml_block">
          <span class="tag">
            <a class="click" href="#close{$id}" name="open{$id}" onclick="if (window.swap) return swap('{$id}');">
              <xsl:text>&lt;</xsl:text>
            </a>
            <xsl:call-template name="xml:element"/>
            <xsl:apply-templates select="@*" mode="xml:html"/>
            <xsl:text>&gt;</xsl:text>
          </span>
          <span class="xml_mix" id="{$id}">
            <xsl:apply-templates select="node()" mode="xml:html">
              <xsl:with-param name="inline" select="true()"/>
            </xsl:apply-templates>
          </span>
          <span class="tag">
            <a class="click">&lt;</a>
            <xsl:text>/</xsl:text>
            <xsl:call-template name="xml:element"/>
            <xsl:text>&gt;</xsl:text>
          </span>
        </div>
      </xsl:when>
      <!-- structured block with indent -->
      <xsl:when test="normalize-space(text()) = '' and *">
        <div class="tag">
          <a class="click" href="#close{$id}" name="open{$id}" onclick="if (window.swap) return swap('{$id}');">
            <xsl:text>&lt;</xsl:text>
          </a>
          <xsl:call-template name="xml:element"/>
          <xsl:apply-templates select="@*" mode="xml:html"/>
          <xsl:text>&gt;</xsl:text>
        </div>
        <blockquote class="xml_margin" id="{$id}">
          <xsl:apply-templates select="node()" mode="xml:html"/>
        </blockquote>
        <div class="tag">
          <a class="click" href="#open{$id}" name="close{$id}">&lt;</a>
          <xsl:text>/</xsl:text>
          <xsl:call-template name="xml:element"/>
          <xsl:text>&gt;</xsl:text>
        </div>
      </xsl:when>
      <!-- block or with no children -->
      <xsl:otherwise>
        <div>
          <span class="tag">
            <xsl:text>&lt;</xsl:text>
            <xsl:call-template name="xml:element"/>
            <xsl:apply-templates select="@*" mode="xml:html"/>
            <xsl:text>&gt;</xsl:text>
          </span>
          <xsl:apply-templates select="node()" mode="xml:html"/>
          <span class="tag">
            <xsl:text>&lt;/</xsl:text>
            <xsl:call-template name="xml:element"/>
            <xsl:text>&gt;</xsl:text>
          </span>
        </div>
      </xsl:otherwise>
    </xsl:choose>
    <!-- MAYDO
    <xsl:if test="$hide">
        <xsl:attribute name="style">display:none; {};</xsl:attribute>
    </xsl:if>
    <xsl:if test="$cdata and $content">
        <xsl:text>&lt;![CDATA[</xsl:text>
    </xsl:if>

    <xsl:if test="$cdata">
        <xsl:text>]]&gt;</xsl:text>
    </xsl:if>

-->
  </xsl:template>
  <!-- write an xml element name -->
  <xsl:template name="xml:element">
    <xsl:variable name="uri">
      <xsl:apply-templates select="." mode="xml:uri"/>
    </xsl:variable>
    <xsl:variable name="prefix">
      <xsl:choose>
        <xsl:when test="contains(name(), ':')">
          <xsl:value-of select="substring-before(name(), ':')"/>
        </xsl:when>
        <xsl:otherwise>el</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="normalize-space($uri) != ''">
        <a href="{$uri}" class="{$prefix}">
          <xsl:value-of select="name()"/>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <b class="{$prefix}">
          <xsl:value-of select="name()"/>
        </b>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- unplugged because of possible infinite loop -->
  <!--
    <xsl:template match="*[local-name()='include' or local-name()='import']" mode="xml:html">
        <xsl:call-template name="xml:element">
            <xsl:with-param name="element" select="."/>
            <xsl:with-param name="content" select="document(@href, .)"/>
            <xsl:with-param name="hide" select="true()"/>
        </xsl:call-template>
    </xsl:template>
    -->
  <!--
a not too less efficient multiple search/replace
pass a string like "find:replace, search:change ..."
if you want to search/replace ':' or ',', do a "translate()" before using this pattern

thanks to jeni@jenitennison.com for its really clever recursive template
http://www.biglist.com/lists/xsl-list/archives/200110/msg01229.html
But is replacing nodeset by functions a good XSL practice ?
String functions seems more useful.

TOTEST &#xA;:<br/> (may work with a <xsl:param select="//br"/>)


    <xsl:when xmlns:java="java" xmlns:xalan="http://xml.apache.org/xalan" test="function-available('xalan:distinct')">
        <xsl:value-of select="java:org.apache.xalan.xsltc.compiler.util.Util.replace($text, 'a', '__')"/>
    </xsl:when>

  -->
  <xsl:template name="replace">
    <!-- the text to parse -->
    <xsl:param name="text"/>
    <!-- 
a pattern in form 
"find:replace,?:!,should disapear:, significant spaces  :SignificantSpaces" 
default is for XML entities
-->
    <xsl:param name="pattern" select="$xmlents"/>
    <!-- current simple string to find -->
    <xsl:param name="find" select="substring-before($pattern, ':')"/>
    <!-- current simple string to replace -->
    <xsl:param name="replace" select="substring-after(substring-before($pattern, ','), ':')"/>
    <xsl:choose>
      <!-- perhaps unuseful, I don't know -->
      <xsl:when test="$text=''"/>
      <!-- nothing to do, output and exit -->
      <xsl:when test="normalize-space($pattern)=''">
        <xsl:copy-of select="$text"/>
      </xsl:when>
      <!-- normalize pattern for less tests (last char is a comma ',') -->
      <xsl:when test="substring($pattern, string-length($pattern)) != ','">
        <xsl:call-template name="replace">
          <xsl:with-param name="text" select="$text"/>
          <xsl:with-param name="pattern" select="concat( $pattern, ',')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$find != '' and contains($text, $find)">
        <!-- search before with reduced pattern -->
        <xsl:call-template name="replace">
          <xsl:with-param name="text" select="substring-before($text, $find)"/>
          <xsl:with-param name="pattern" select="substring-after($pattern, ',')"/>
        </xsl:call-template>
        <!-- copy-of current replace -->
        <xsl:copy-of select="$replace"/>
        <!-- search after with complete pattern -->
        <xsl:call-template name="replace">
          <xsl:with-param name="text" select="substring-after($text, $find)"/>
          <xsl:with-param name="pattern" select="$pattern"/>
        </xsl:call-template>
      </xsl:when>
      <!-- current find not found, continue for another -->
      <xsl:when test="substring-after($pattern, ',')!=''">
        <xsl:call-template name="replace">
          <xsl:with-param name="text" select="$text"/>
          <xsl:with-param name="pattern" select="substring-after($pattern, ',')"/>
        </xsl:call-template>
      </xsl:when>
      <!-- infinite loop or something forgotten ? -->
      <xsl:otherwise>
        <xsl:copy-of select="$text"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- style -->
  <xsl:template name="xml:css">
    <style type="text/css"><![CDATA[
  /* global properties */
  .xml { 
    display:block; 
    font-family: Verdana, arial, sans-serif; 
    font-size:14px;
    color:Navy; 
    margin-left:2em; 
  }
  .xml a {
    text-decoration:none;
  }
  .xml a:hover {
    background:#8080FF;
    color:#FFFFFF;
  }

  /* classes are provided for namespace prefix */
  .xsl {
    color:#0000FF;
    font-weight:bold;
  }

  
  /* element names */
  .el { 
    color:#CC3333; 
    font-weight:900; 
  }
  
  /* attribute names */
  .att {
    color:#008000;
    font-weight:100; 
  }
	
  /* tag is what is between brackets */
  .tag { 
    white-space:nowrap;
  }
  
  /* processing instructions */  
  .xml_pi {
    color:#000080; 
    font-weight: bold;
  }
  
  /* textual contents */
  .text ,
  .val,
  .cdata { 
    font-size:115%;
    font-weight:bold;
    color:#000000; 
    margin:0; 
    padding:0;
    font-family:monospace, sans-serif; 
    background:#FFFFFF;
  }

  /* xml comment */

  pre.comment {  
    margin:0; 
    padding:0; 
    white-space:pre;
    font-size:90%;
    font-family: monospace, sans-serif;
    color:#666666; 
    background:#FFFFCC; 
    font-weight: 100; 
  }

  /* button for +/- and margins */

  a.click {
    border:1px dotted #808080;
    color:#000000;
    font-weight:900;
    text-decoration:none;
  }
  a:hover.click {

  }

  .xml_margin, 
  .xml_mix { 
    display:block; 
    margin-left:5px; 
    padding-left:20px; 
    border-left: 1px dotted;
    margin-top:0px; 
    margin-bottom:0px; 
    margin-right:0px; 
  }


  /* preformated content elements */
  pre.content {
    font-family:inherit;
    display:inline;
    margin:0; 
    padding:0; 
  }

  pre.content .text {
    background:#DDDDFF;
    font-family: monospace, sans-serif;
  }
  
  .cdata {
    color:red
  }
    
  .ns { 
    color:#000080; 
    font-weight:100;
  }
  
  /* properties  */
      
  
  dl.xml_block { 
    margin:0; 
    padding:0;
  }
      
  .hide { 
    color:blue; 
    text-decoration:underline; 
  }


]]></style>
  </xsl:template>
</xsl:stylesheet>
