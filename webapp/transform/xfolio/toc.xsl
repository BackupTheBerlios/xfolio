<?xml version="1.0" encoding="UTF-8"?>
<!--
(c) 2003, 2004 [xfolio.org], [ajlsm.com], [strabon.org], [eumedis.net]
Licence :  [http://www.gnu.org/copyleft/gpl.html GPL]

= WHAT =

This transformation take a documented directory as input,
and give some HTML views on it.

= WHO =

 *[FG] FredericGlorieux frederic.glorieux@xfolio.org

= CHANGES =

 * 2004-07-14:FG  "write site" in real time

= WHY =

I had implemented the same functionalities in pure XSL, and I'm now glad
to forget all that stuff for an easier solution to maintain (cause now 
most of the logic is done by a JAVA generator).

= TODO =

Everything.

-->
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dir="http://apache.org/cocoon/directory/2.0" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:i18n="http://apache.org/cocoon/i18n/2.1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" exclude-result-prefixes="xsl rdf dc xsi dir i18n">
  <xsl:output method="xml" encoding="UTF-8"/>
  <!-- encoding, default is the one specified in xsl:output -->
  <xsl:param name="encoding" select="document('')/*/xsl:output/@encoding"/>
  <!-- lang requested -->
  <xsl:param name="lang"/>
  <!-- default language -->
  <xsl:param name="langDefault" select="'en'"/>
  <!-- for "you are here highlight" -->
  <xsl:param name="radicalHere"/>
  <!-- skin, a folder where to find resources -->
  <xsl:param name="skin"/>
  <!-- size of buttons -->
  <xsl:param name="size" select="12"/>
  <!-- target -->
  <xsl:param name="target"/>
  <!-- mode -->
  <xsl:param name="mode"/>
  <!-- resize -->
  <xsl:param name="resize" select="'yes'"/>
  <!-- extensions transformed by server -->
  <xsl:param name="htmlizable" select="' dbx sxw jpg '"/>
  <!--

Root template
-->
  <xsl:template match="/*">
    <xsl:choose>
      <xsl:when test="$mode='table'">
        <xsl:apply-templates mode="table"/>
      </xsl:when>
      <xsl:otherwise>
        <html>
          <head>
            <title>&#160;</title>
            <meta http-equiv="Content-type" content="text/html; charset=UTF-8"/>
            <script type="text/javascript">
function expand(button, action) {
  if (!document.getElementById) return false; 
  if (!button || !button.id) return false;
  id=button.id;
  var o=document.getElementById('_'+id);
  if (!o || !o.style) return false;
  if (action == "open") o.style.display="";
  else if (action == "close") o.style.display="none";
  else o.style.display=(o.style.display == 'none')?'':'none';
  if (!button.alt || !button.src) {}
  else if (action == "open") { 
    button.alt="-";
    // could be not safe if more than one "_" or no size
    button.src=button.src.replace(/\/[^\/]*_/, '/minus_')
  }
  else if (action == "close") {
    button.alt="+";
    // could be not safe if more than one "_" or no size
    button.src=button.src.replace(/\/[^\/]*_/, '/plus_')
  }
  else {
    button.alt=(button.alt == '+')?'-':'+';
    button.src=(button.src.search('plus') != -1)?button.src.replace('plus', 'minus'):button.src.replace('minus', 'plus');
  }
  return false;
}



function init() {

  // close all clicks
  if (!document.getElementById) return false; 
  var toc=document.getElementById('toc');
  if (!toc) return false;
  imgs=toc.getElementsByTagName('IMG');
  var i=0;
  while(imgs[i]) {
    expand(imgs[i]);
    i++;
  }
  var i=0;
  // set index of 
  while(document.links[i]) {
    document.links[i].index=i;
    i++;
  }
}

function goLang(select) {
  var s=new String(window.location); 
  var lang=select.options[select.selectedIndex].text;
  var sharp="";
  var query="";
  if (s.indexOf('#') != -1) {
    sharp=s.substring(s.indexOf('#'));
    s=s.substring(0,s.indexOf('#')) ;
  }
  if (s.indexOf('?') != -1) {
    query=s.substring(s.indexOf('?'));
    s=s.substring(0,s.indexOf('?')) ;
  }
  if( s.lastIndexOf('.') - s.search(/_..\./) == 3) s=s.replace(/_..\./, '.');
  s=s.substring(0, s.lastIndexOf('.')) + '_'+lang + s.substring(s.lastIndexOf('.')); 
  window.location=s+query+sharp;
}

function getKey(e) {
  if (document.all) e = window.event;
  if(!e)return;
  if (e.keyCode) return e.keyCode;
  else if (e.which) return e.which;
  else return;
}

function tocKeyDown(o, e) {
  key=getKey(e);
  // previous
  if (key==38) {
    if (o.index == 0) return;
    previous=document.links[o.index - 1];
    while (previous &amp;&amp; previous.index &gt; 0 &amp;&amp; !isVisible(previous)) {
      previous=document.links[previous.index - 1];
    }
    if (!previous || !isVisible(previous)) return;
    previous.focus();
    return false;
  }
  // next
  else if (key==40) {
    if (o.index == document.links.length - 1) return;
    next=document.links[o.index + 1];
    while (next &amp;&amp; !isVisible(next) &amp;&amp; next.index &lt; document.links.length - 2 ) {
      next=document.links[next.index + 1];
    }
    if (!next || !isVisible(next)) return;
    next.focus();
    return false;
  }
  // open
  else if (key==39) {
    if (o.previousSibling) expand(o.previousSibling, "open"); 
  }
  // close
  else if (key==37) {
    if (o.previousSibling) expand(o.previousSibling, "close"); 
  }
  // page up
  else if(key==33) {
    diff=10;
    if (o.index - diff &lt; 0) return;
    previous=document.links[o.index - diff];
    while (previous &amp;&amp; previous.index &gt; 0 &amp;&amp; !isVisible(previous)) {
      previous=document.links[previous.index - 1];
    }
    if (!previous || !isVisible(previous)) return;
    previous.focus();
    return false;
  }
  // page down
  else if(key==34) {
    diff=10;
    if (o.index + diff &gt; document.links.length - 1) return;
    next=document.links[o.index + diff];
    while (next &amp;&amp; !isVisible(next) &amp;&amp; next.index &lt; document.links.length - 2 ) {
      next=document.links[next.index + 1];
    }
    if (!next || !isVisible(next)) return;
    next.focus();
    return false;
  }
  
}

function isVisible (o) {
  while (o &amp;&amp; o.style) {
    if (o.style.display == "none") return false;
    o=o.parentNode;
  }
  return true;
}
    </script>
            <style type="text/css">
body {
  margin:0;
}
img.plus {
  margin-left:-<xsl:value-of select="$size + 5"/>px; 
  margin-right:5px;
}
#toc {
  font-size:9pt;
  font-family:Arial, sans-serif;
  white-space:nowrap;
}
#toc a {
  text-decoration:none;
  color:#000000;
}
#toc a:active,
#toc a:focus {
  color:white; 
  background:#000080;
  text-decoration:none;
}
#toc a:hover {
  text-decoration:underline;
}

blockquote.toc {
  margin-top:0px; 
  margin-bottom:0px;
  margin-left:1ex;
  padding-left:<xsl:value-of select="$size div 2 + 5"/>px;
  border-left:dotted 1px;
}
          </style>
          </head>
          <body onload="init()">
            <div id="toc">
              <table width="100%" cellpadding="0" cellspacing="0" border="0">
                <tr>
                  <td width="100%">
                    <select style="width:100%">
                      <option>
                        <i18n:text key="contents">Contents</i18n:text>
                      </option>
                      <option>
                        <i18n:text key="authors">Authors</i18n:text>
                      </option>
                      <option>
                        <i18n:text key="index">Index</i18n:text>
                      </option>
                    </select>
                  </td>
                  <td>
                    <select onchange="goLang(this)">
                      <option/>
                      <xsl:for-each select=".//dir:file/@xml:lang[not(.=preceding::dir:file/@xml:lang)]">
                        <option>
                          <xsl:if test=". = $lang">
                            <xsl:attribute name="selected">selected</xsl:attribute>
                          </xsl:if>
                          <xsl:value-of select="."/>
                        </option>
                      </xsl:for-each>
                    </select>
                  </td>
                </tr>
              </table>
              <blockquote class="toc">
                <xsl:apply-templates mode="toc"/>
              </blockquote>
            </div>
          </body>
        </html>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!--

A simple toc

maybe problems with directories called index ?
-->
  <xsl:template match="dir:directory" mode="toc">
    <!-- only directories -->
    <xsl:variable name="welcome" select="'index'"/>
    <xsl:choose>
      <!-- directory witout a file -->
      <xsl:when test="not(.//dir:file)">
        <!--
        <div>
          <xsl:call-template name="title"/>
        </div>
      -->
      </xsl:when>
      <!-- no welcome file -->
      <xsl:when test="not(dir:file[@radical = $welcome])">
        <div>
          <img align="bottom" class="plus" id="{generate-id()}" style="cursor:pointer" src="{$skin}/buttons/minus_{$size}.png" alt="+" onclick="return expand(this);" onmouseover="this.last=this.src;this.src=this.src.replace('_{$size}.png', '-over_{$size}.png')" onmouseout="if(this.last)this.src=this.last"/>
          <!-- same code in match="dir:file", optimize ? -->
          <a class="toc" onmouseover="this.focus()" onkeydown="return tocKeyDown(this, event);">
            <xsl:if test="$target">
              <xsl:attribute name="target">
                <xsl:value-of select="$target"/>
              </xsl:attribute>
            </xsl:if>
            <xsl:attribute name="href">
              <xsl:call-template name="href"/>
            </xsl:attribute>
            <xsl:call-template name="title"/>
          </a>
        </div>
        <blockquote class="toc" id="_{generate-id()}">
          <xsl:apply-templates mode="toc"/>
        </blockquote>
      </xsl:when>
      <!-- only welcome files -->
      <xsl:when test="not(dir:*[@radical != $welcome])">
        <xsl:apply-templates mode="toc"/>
      </xsl:when>
      <!-- different things and a welcome file to get a title -->
      <xsl:otherwise>
        <xsl:apply-templates select="dir:*[@radical = $welcome]" mode="toc">
          <xsl:with-param name="id" select="generate-id()"/>
        </xsl:apply-templates>
        <blockquote class="toc" id="_{generate-id()}">
          <xsl:apply-templates select="dir:*[@radical != $welcome]" mode="toc"/>
        </blockquote>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- 
to display only one file by radical, proceed only the first (and catch others) 
Input should be no too badly ordered, especially for extensions
-->
  <xsl:template match="dir:*[@radical = preceding-sibling::dir:*[1]/@radical]" mode="toc"/>
  <xsl:template match="dir:file" mode="toc">
    <xsl:param name="id"/>
    <xsl:variable name="radical" select="@radical"/>
    <xsl:choose>
      <xsl:when test="../dir:file[@radical=$radical][@xml:lang=$lang]">
        <xsl:apply-templates select="../dir:file[@radical=$radical][@xml:lang=$lang][1]" mode="li">
          <xsl:with-param name="id" select="$id"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="../dir:file[@radical=$radical][@xml:lang=$langDefault]">
        <xsl:apply-templates select="../dir:file[@radical=$radical][@xml:lang=$langDefault][1]" mode="li">
          <xsl:with-param name="id" select="$id"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="../dir:file[@radical=$radical][1]" mode="li">
          <xsl:with-param name="id" select="$id"/>
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- 
display a file in a li for a toc
-->
  <xsl:template match="dir:file" mode="li">
    <xsl:param name="id"/>
    <div>
      <xsl:if test="$id">
        <img align="bottom" class="plus" id="{$id}" style="cursor:pointer" src="{$skin}/buttons/minus_{$size}.png" alt="+" onclick="return expand(this);"/>
      </xsl:if>
      <a class="toc" onmouseover="this.focus()" onkeydown="return tocKeyDown(this, event);">
        <xsl:if test="$target">
          <xsl:attribute name="target">
            <xsl:value-of select="$target"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:attribute name="href">
          <xsl:call-template name="href"/>
        </xsl:attribute>
        <xsl:if test=".//dc:description">
          <xsl:attribute name="title">
            <xsl:value-of select=".//dc:description"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:call-template name="title"/>
      </a>
    </div>
  </xsl:template>
  <!--

A table to navigate

  -->
  <xsl:template match="dir:directory[ dir:file | dir:directory]" mode="table">
    <table id="menu" border="1">
      <xsl:for-each select="dir:file | dir:directory">
        <xsl:apply-templates select="." mode="tr"/>
      </xsl:for-each>
    </table>
  </xsl:template>
  <xsl:template match="dir:file | dir:directory" mode="tr">
    <tr>
      <!-- the "You are here"  -->
      <xsl:if test="contains($radicalHere, @radical)">
        <xsl:attribute name="class">this</xsl:attribute>
        <xsl:attribute name="bgcolor">#FFFFCC</xsl:attribute>
      </xsl:if>
      <xsl:variable name="image" select=".//dc:relation[contains(@xsi:type, 'image/jpeg')][1]"/>
      <xsl:if test="$image and $resize">
        <td class="img" bgcolor="#CCCCCC" width="52px" height="52px" align="center" valign="middle">
          <!-- 
request a thumb by filename, to avoid loading of complete images
if the server is not able to resize.

          <xsl:call-template name="thumb">
            <xsl:with-param name="relation" select="$image"/>
            <xsl:with-param name="size" select="50"/>
          </xsl:call-template>

  -->
        </td>
      </xsl:if>
      <td>
        <xsl:if test="not($image)">
          <xsl:attribute name="colspan">2</xsl:attribute>
        </xsl:if>
        <xsl:call-template name="title"/>
        <!--
            <xsl:apply-templates select="." mode="langs"/>
              -->
      </td>
    </tr>
  </xsl:template>
  <!--
get title
-->
  <xsl:template name="title">
    <!-- if no link ? -->
    <xsl:choose>
      <xsl:when test="name() = 'dir:directory'">
        <xsl:value-of select="@radical"/>
      </xsl:when>
      <xsl:when test=".//dc:title">
        <xsl:apply-templates select=".//dc:title[1]"/>
      </xsl:when>
      <xsl:when test="@radical != 'index'">
        <xsl:value-of select="@radical"/>
      </xsl:when>
      <!-- get the name of directory ? -->
      <xsl:otherwise>
        <xsl:value-of select="ancestor::dir:directory[1]/@radical"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- global redirection of links -->
  <xsl:template name="href">
    <xsl:choose>
      <xsl:when test="false()"/>
      <xsl:when test="contains($htmlizable, concat(' ',@extension,' '))">
        <xsl:value-of select="../@href"/>
        <xsl:value-of select="substring-before(@name, concat('.', @extension))"/>
        <xsl:text>.html</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="@base"/>
        <xsl:value-of select="@name"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:transform>
