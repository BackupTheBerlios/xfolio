<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="xsl2html.xsl"?>
<!--
title   : xsl2html.xsl
rights  : Copyright 2003-2004 ADNX <http://adnx.org>
creator : "Frédéric Glorieux" <frederic.glorieux@ajlsm.com>

  = WHAT =

This is an XSL to transform XSL, for documentation (a kind of "xsldoc").
This tool is designed for

 1) producing vast amount of printable paper for activities report, 
    human readable if possible (bad reason)
 2) have real time view to improve XSL design (real usage)
 3) help reusability of XSL (good wish)

  = HOW =

add a stylesheet declaration to you XSL
<?xml-stylesheet type="text/xsl" href="xsl2html.xsl"?>
and see the result in an XSL browser compatible.
So, you can have a text view in your favorite editor,
and documentation view in your browser.

  = FEATURES =

 * 

 = TODO =

 * full cross refence between XSL elements
 * templates ordered by names
 * 
 * index of generated elements
   with linking  
 * index of generated texts
 * templates ordered by name, 
 * lists of TODO, FIXME (MAYDO, and others ?)
 * lists of dates (calendar)

 = CHANGES = 

2004-11-07 [FG] creation

-->
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
 xmlns="http://www.w3.org/1999/xhtml"

>
  <!-- 
xml2html.xsl

Interesting to format comments.
*import precedence* xml2html.xsl < text2html.xsl < html-common.xsl
 -->
  <xsl:import href="xml2html.xsl"/>
  <!-- the output declaration -->
  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

  <!-- root template -->
  <xsl:template match="/">
    <xsl:call-template name="html"/>
  </xsl:template>
  <!-- the html generated -->
  <xsl:template name="html">
    <html>
      <head>
        <title>XSL Documentation</title>
        <xsl:call-template name="html-metas"/>
        <xsl:call-template name="xml:css"/>
        <xsl:call-template name="xml:swap"/>
      </head>
      <xsl:call-template name="body"/>
    </html>
  </xsl:template>
  
  <!-- generate an html body -->
  <xsl:template name="body">
    <body>
      <xsl:apply-templates select="xsl:stylesheet | xsl:transform"/>
      <p>&#160;</p>
      <xsl:apply-templates select="xsl:stylesheet  | xsl:transform" mode="xml:html"/>
      <!-- some space to help internal links -->
      <p>&#160;</p>
      <p>&#160;</p>
      <p>&#160;</p>
    </body>
  </xsl:template>
  
  <!-- 
call this template in xsl:transform to get a table header about it 

TODO attribute-set, 
-->
  <xsl:template name="xsl:header">
      <table class="table" width="100%">
        <xsl:apply-templates select="xsl:include | xsl:import"/>
        <xsl:if test="xsl:param">
            <tr bgcolor="#EEEEEE">
              <th>Parameters</th>
              <th>description</th>
              <th>value</th>
              <th>usage</th>
            </tr>
            <xsl:apply-templates select="xsl:param"/>
        </xsl:if>
        <xsl:if test="xsl:param">
            <tr bgcolor="#EEEEEE">
                <th>Variables</th>
                <th>description</th>
                <th>value</th>
                <th>usage</th>
            </tr>
            <xsl:apply-templates select="xsl:variable"/>
        </xsl:if>
          <tr>
            <th>Generated elements</th>
            <td colspan="4">
              <xsl:for-each select="
.//*[namespace-uri() != 'http://www.w3.org/1999/XSL/Transform']
    [not(ancestor::xsl:template[@name='xsl:input'])]
">
                <xsl:sort select="name()"/>
                <xsl:if test="position() != 1">, </xsl:if>
                <xsl:text> &lt;</xsl:text>
                <a class="el">
                  <xsl:attribute name="href">
                    <xsl:text>#</xsl:text>
                    <xsl:apply-templates select="ancestor::xsl:template[1]" mode="id"/>
                  </xsl:attribute>
                  <xsl:value-of select="name()"/>
                </a>
                <xsl:text>/&gt;</xsl:text>
              </xsl:for-each>
            </td>
          </tr>
          <tr>
            <th>Messages</th>
            <td colspan="4">

              <xsl:for-each select="
.//text()[normalize-space(.)!= '']
    [name(./..) != 'xsl:variable']
    [not(ancestor::xsl:template[@name='xsl:input'])]
">
                <xsl:if test="position() != 1">, </xsl:if>
                <xsl:text>"</xsl:text>
                <a>
                  <xsl:attribute name="href">
                    <xsl:text>#</xsl:text>
                    <xsl:apply-templates select="ancestor::xsl:template" mode="id"/>
                  </xsl:attribute>
                  <xsl:value-of select="."/>
                </a>
                <xsl:text>"</xsl:text>
              </xsl:for-each>

            </td>
          </tr>
      </table>

  </xsl:template>
  
  
  <!-- includes and imports in a table 
TODO rewriting of links for html (see html-common.xsl) -->
  <xsl:template match="xsl:include | xsl:import"> 
    <tr>
      <th>include</th>
      <td>
        <a href="{@href}">
          <xsl:value-of select="@href"/>
        </a>
      </td>
      <td>
        <xsl:apply-templates select="
preceding-sibling::comment()[1][generate-id(following-sibling::*)=generate-id(current())]
" mode="text2html"/>
      </td>
    </tr>
  </xsl:template>
  
  <!-- matching root variable or parameter, appears in a table -->
  <xsl:template match="
  xsl:stylesheet/xsl:param | xsl:transform/xsl:param
|  xsl:stylesheet/xsl:variable | xsl:transform/xsl:variable
  ">
    <xsl:variable name="name" select="@name"/>
    <tr>
      <!-- name -->
      <th>
          <xsl:text>$</xsl:text>
          <xsl:value-of select="@name"/>
      </th>
      <!-- description -->
      <td>
        <xsl:apply-templates select="
preceding-sibling::comment()[1][generate-id(following-sibling::*)=generate-id(current())]
" mode="text2html"/>
      </td>
      <!-- value -->
      <td>
        <samp>
          <xsl:apply-templates select="@select"/>
          <xsl:apply-templates/>
        </samp>
      </td>
      <!-- usage -->
      <td>
        <!--
 this xpath select the first occurence for each template
 of an usage of a variable  
        -->
        <xsl:for-each select="
../xsl:template[.//@*[name()='select' or name()='test'][contains(., concat('$', $name))]]">
            <xsl:if test="position()!=1">, </xsl:if>
            <xsl:apply-templates select="." mode="link"/>
        </xsl:for-each>
      </td>
    </tr>
  </xsl:template>


  <!-- for now, only templates are named and linkable -->
  <xsl:template match="xsl:template" mode="link">
    <a>
      <xsl:attribute name="href">
        <xsl:text>#</xsl:text>
        <xsl:apply-templates select="." mode="id"/>
      </xsl:attribute>
      <xsl:apply-templates select="." mode="id"/>
    </a>
  </xsl:template>
  
  <!-- default generate-id() for a node (used for anchor or target) -->
  <xsl:template match="node()|@*" mode="id">
    <xsl:value-of select="generate-id()"/>
  </xsl:template>
  <!-- id of named template is its name -->
  <xsl:template match="xsl:template[@name]" mode="id">
    <xsl:value-of select="@name"/>
  </xsl:template>
  <!-- id of match template without name -->
  <xsl:template match="xsl:template[not(@name)]" mode="id">
    <xsl:text>template</xsl:text>
    <xsl:number count="xsl:template[not(@name)]" level="any"/>
  </xsl:template>
  
  <!-- global matching of stylesheet -->
  <xsl:template match="xsl:stylesheet | xsl:transform">
    <center>
      <h1>XSL Documentation</h1>
    </center>
    <!-- header -->
    <xsl:call-template name="xsl:header"/>
    <p>&#160;</p>
    <!-- description -->
        <xsl:apply-templates select="
preceding-sibling::comment()[1][generate-id(following-sibling::*)=generate-id(current())]
" mode="text2html"/>
    <!-- input >> output -->
    <xsl:apply-templates select="xsl:template[@name='xsl:input']"/>
    <!-- TODOs -->
    <xsl:if test="contains(.//comment(), ' TODO ')">
      <h1>TODOs</h1>
      
    </xsl:if>
    <!-- templates summary -->
    <p/>
    <xsl:call-template name="xsl:templates"/>
    <!-- templates description -->
    <h1>Template detail</h1>
    <xsl:apply-templates select="xsl:template"/>
  </xsl:template>

  <!-- give a fast summary of templates -->
  <xsl:template name="xsl:templates">
    <!-- templates -->
    <h1>Template Summary</h1>
    <table class="table">
      <thead>
        <tr bgcolor="#CCCCCC">
          <td/>
          <th>name</th>
          <th>mode</th>
          <th>match</th>
          <th>parameters</th>
        </tr>
      </thead>
      <tbody>
        <xsl:for-each select="xsl:template">
          <xsl:sort select="@name"/>
          <xsl:sort select="@mode"/>
          <xsl:sort select="@match"/>
          <tr>
            <td>
              <a>
                <xsl:attribute name="href">
                  <xsl:text>#</xsl:text>
                  <xsl:apply-templates select="." mode="id"/>
                </xsl:attribute>
                <xsl:text>V</xsl:text>
              </a>
            </td>
            <th>
               <xsl:apply-templates select="@name"/>
            </th>
          <!--
            <a>
              <xsl:attribute name="href">
                <xsl:text>#</xsl:text>
                <xsl:apply-templates select="." mode="id"/>
              </xsl:attribute>
              <th valign="top">
                <xsl:choose>
                  <xsl:when test="@name">
                   <xsl:value-of select="@name"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:text>&#160;&#160;</xsl:text>
                  </xsl:otherwise>
                </xsl:choose>
              </th>
            </a>
            -->
            <!-- mode -->
            <td valign="top">
              <xsl:value-of select="@mode"/>
            </td>
            <!-- match -->
            <td valign="top">
              <xsl:value-of select="@match"/>
            </td>
            <!-- parameters -->
        <xsl:if test="xsl:param">
          <td width="50%">
          <xsl:text> (</xsl:text>
          <xsl:for-each select="xsl:param">
            <xsl:if test="position() != 1">, </xsl:if>
            <xsl:apply-templates select="@name"/>
          </xsl:for-each>
          <xsl:text>) </xsl:text>
          </td>
        </xsl:if>
            <!--
            <td>
              <xsl:variable name="id">
                <xsl:apply-templates select="." mode="xml:id"/>
              </xsl:variable>
              <a href="#{$id}" title="Go to source">
                <xsl:apply-templates select="." mode="id"/>
              </a>
            </td>
            -->
          </tr>
        </xsl:for-each>
      </tbody>
    </table>
  </xsl:template>
  
  <!-- @name -->
  <xsl:template match="@name">
    <xsl:value-of select="."/>
    <xsl:text> </xsl:text>
  </xsl:template>
  <!-- @match -->
  <xsl:template match="@match">
    <xsl:text> {</xsl:text>
    <xsl:value-of select="."/>
    <xsl:text>} </xsl:text>
  </xsl:template>
  <!-- @match -->
  <xsl:template match="@mode">
    <xsl:text> &gt;</xsl:text>
    <xsl:value-of select="."/>
    <xsl:text>&gt; </xsl:text>
  </xsl:template>
  <!-- A template (@name or @match), as a line in a table -->
  <xsl:template match="xsl:template">
    <h2>
      <xsl:attribute name="id">
        <xsl:apply-templates select="." mode="id"/>
      </xsl:attribute>
      <a>
        <xsl:attribute name="href">
          <xsl:text>#</xsl:text>
          <xsl:apply-templates select="." mode="xml:id"/>
        </xsl:attribute>
        <xsl:apply-templates select="@name"/>
        <xsl:apply-templates select="@match"/>
        <xsl:apply-templates select="@mode"/>
      </a>
    </h2>
        <xsl:apply-templates select="
preceding-sibling::comment()[1][generate-id(following-sibling::*)=generate-id(current())]
" mode="text2html"/>

     <p>&#160;</p>

          <xsl:call-template name="xsl:template"/>

     <p>&#160;</p>
  </xsl:template>
  <!-- match a specific named template where sample input xml maybe stored -->
  <xsl:template match="xsl:template[@name='xsl:input']">
    <h1>Sample input</h1>
    <xsl:apply-templates mode="xml:html"/>
  
  </xsl:template>
  <!-- no output for the sample input -->
  <xsl:template match="xsl:template[@name='xsl:input']"/>
  
  <!-- xsl:template mode output -->
  <xsl:template name="xsl:template">

    <div class="code">
        <xsl:if test="@match">
          <xsl:text>{</xsl:text>
          <xsl:apply-templates select="@match | @select" />
          <xsl:text>}</xsl:text>
          <xsl:text> &gt;&gt; </xsl:text>
        </xsl:if>
        <xsl:value-of select="@name"/>
        <xsl:if test="xsl:param">
          <xsl:text> (</xsl:text>
        <xsl:apply-templates select="
   xsl:param
 | comment()[name(following-sibling::*)='xsl:param']
        " />
          <xsl:text>)</xsl:text>
        </xsl:if>
        <xsl:text> {</xsl:text>
        <xsl:apply-templates select="
        *[name() != 'xsl:param']
       | comment()[not(name(following-sibling::*)='xsl:param')]
        
        " />
        <xsl:text> }</xsl:text>
    </div>
  </xsl:template>
  
  <!-- xsl:for-each -->
  <xsl:template match="xsl:for-each">
    <div class="code">
      <xsl:text>(</xsl:text>
      <xsl:apply-templates select="@select"/>
      <xsl:text>) * {</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}; </xsl:text>
    </div>
  </xsl:template>

  <!-- apply comments -->
  <xsl:template match="comment()">
    <div class="code-comment">
      <xsl:apply-templates select="." mode="text2html"/>
    </div>
  </xsl:template>

  <!-- if may be shown as when -->
  <xsl:template match="xsl:if" >
    <div class="code">
      <xsl:text>(</xsl:text>
      <xsl:apply-templates select="@test" />
      <xsl:text>)? {</xsl:text>
      <xsl:apply-templates />
      <xsl:text>} </xsl:text>
    </div>
  </xsl:template>

  <!-- do better ? -->
  <xsl:template match="xsl:text" >
    <xsl:text>"</xsl:text>
    <b>
      <xsl:apply-templates />
    </b>
    <xsl:text>"</xsl:text>
  </xsl:template>

  <!-- attribute -->
  <xsl:template match="xsl:attribute">
    <xsl:text> </xsl:text>
    <b class="att">
      <xsl:value-of select="@name"/>
    </b>  
    <xsl:text>="</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>" </xsl:text>
  </xsl:template>

  <!-- xsl attribute -->
  <xsl:template match="xsl:*/@*">
    <xsl:value-of select="."/>
  </xsl:template>

  <!-- generated attribute -->
  <xsl:template match="@*">
    <xsl:text> </xsl:text>
    <b class="att">
      <xsl:value-of select="name()"/>
    </b>
    <xsl:text>="</xsl:text>
    <xsl:value-of select="."/>
    <xsl:text>" </xsl:text>
  </xsl:template>
  


  <!-- generated element -->
  <xsl:template match="*">
    <div class="code">
      <xsl:text>&lt;</xsl:text>
      <b class="el">
        <xsl:value-of select="name()"/>
      </b>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="*[.//xsl:attribute] | xsl:attribute"/>
      <xsl:text>&gt;</xsl:text>
      <xsl:apply-templates select="node()[not(.//xsl:attribute or name()='xsl:attribute')]"/>
      <xsl:text>&lt;/</xsl:text>
      <b class="el">
        <xsl:value-of select="name()"/>
      </b>
      <xsl:text>&gt;</xsl:text>

    </div>
  </xsl:template>

  <!-- generated element -->
  <xsl:template match="xsl:element">
    <div class="code">
      <xsl:text>&lt;</xsl:text>
      <b class="el">
        <xsl:value-of select="@name"/>
      </b>
      <xsl:apply-templates select="*[.//xsl:attribute] | xsl:attribute"/>
      <xsl:text>&gt;</xsl:text>
      <xsl:apply-templates select="node()[not(.//xsl:attribute or name()='xsl:attribute')]"/>
      <xsl:text>&lt;/</xsl:text>
      <b class="el">
        <xsl:value-of select="@name"/>
      </b>
      <xsl:text>&gt;</xsl:text>

    </div>
  </xsl:template>


  <!-- consider a choose as an ordered list of outputs -->
  <xsl:template match="xsl:choose" >
      <xsl:apply-templates />
  </xsl:template>
  
  <!-- output copy-of or value-of as {select} -->
  <xsl:template match="xsl:copy-of | xsl:value-of" >
    <div class="code">
      <xsl:text>{</xsl:text>
      <xsl:apply-templates select="@select"/>
      <xsl:text>}</xsl:text>
    </div>
  </xsl:template>
  
  <!-- consider a when as list-item -->
  <xsl:template match="xsl:when" >
    <div class="code">
      <xsl:text> : (</xsl:text>
      <xsl:apply-templates select="@test"/>
      <xsl:text>)? </xsl:text>
      <xsl:text> {</xsl:text>
      <xsl:apply-templates />
      <xsl:text>}; </xsl:text>
    </div>
  </xsl:template>
  
  <xsl:template match="xsl:otherwise">
    <div class="code">
      <xsl:text>: {</xsl:text>
      <xsl:apply-templates />
      <xsl:text>}; </xsl:text>
    </div>
  
  </xsl:template>
  
  <!-- a "function" -->
  <xsl:template match="xsl:call-template" >
    <div class="code">
      <a href="#{@name}">
        <xsl:value-of select="@name"/>
      </a>
      <xsl:text> (</xsl:text>
      <xsl:for-each select="xsl:with-param">
        <xsl:if test="position() != 1">, </xsl:if>
        <xsl:apply-templates select="." />
      </xsl:for-each>
      <xsl:text>); </xsl:text>
    </div>
  </xsl:template>
  <!-- a parameter -->
  <xsl:template match="xsl:with-param" >
    <xsl:value-of select="@name"/>
    <xsl:text>={</xsl:text>
    <xsl:apply-templates select="@select"/>
    <xsl:apply-templates />
    <xsl:text>}</xsl:text>
  </xsl:template>
  <!-- 
parameters 
<xsl:param name="?" select="?"/>
-->
  <xsl:template match="xsl:param">
    <div class="code">
      <xsl:text>$</xsl:text>
      <xsl:value-of select="@name"/>
      <xsl:text>={</xsl:text>
      <xsl:apply-templates select="@select"/>
      <xsl:apply-templates/>
      <xsl:text>}; </xsl:text>
    </div>
  </xsl:template>
<!-- match a variable -->
    <xsl:template match="xsl:variable" >
      <div class="code">
        <xsl:text>$</xsl:text>
        <xsl:value-of select="@name"/>
        <xsl:text>={</xsl:text>
        <xsl:apply-templates select="@select"/>
        <xsl:apply-templates />
        <xsl:text>}; </xsl:text>
      </div>  
    </xsl:template>
    
  <!-- copy -->
    <xsl:template match="xsl:copy" >
      <!-- TOTEST, may bu -->
      <xsl:variable name="name" select="ancestor::xsl:template/@match | ancestor::xsl:for-each/@select"/>
      <span class="tag">
        <xsl:text>&lt;</xsl:text>
        <span class="el">
          <xsl:text>{</xsl:text>
          <xsl:value-of select="$name"/>
          <xsl:text>}</xsl:text>
        </span>
        <xsl:text>&gt;</xsl:text>
      </span>
      <xsl:apply-templates />
      <span class="tag">
        <xsl:text>&lt;/</xsl:text>
        <span class="el">
          <xsl:text>{</xsl:text>
          <xsl:value-of select="$name"/>
          <xsl:text>}</xsl:text>
        </span>
        <xsl:text>&gt;</xsl:text>
      </span>
    </xsl:template>

    <!-- apply-templates, show only select -->
    <xsl:template match="xsl:apply-templates" >
      <div>
        <xsl:text>{</xsl:text>
        <xsl:choose>
          <xsl:when test="@select">
            <xsl:apply-templates select="@select" />
          </xsl:when>
          <xsl:otherwise>node()</xsl:otherwise>
        </xsl:choose>
        <xsl:text>} &gt;&gt;</xsl:text>
      </div>
    </xsl:template>
        
    
    <!-- element -->
  

  <xsl:template match="text()[normalize-space(.)='']"/>
  <!-- behavior of source display -->
  <xsl:template match="comment()" mode="xml:html"/>
  <!-- output only templates for source display -->
  <xsl:template match="/*/xsl:template" mode="xml:html">
    <p class="hr"/>
    <xsl:call-template name="xml:element"/>
  </xsl:template>
  <!-- no view-source for the sample input -->
  <xsl:template match="/*/xsl:template[@name='xsl:input']" mode="xml:html"/>
  
  
  <!-- link source of a template to its doc on @name -->
  <xsl:template match="xsl:template/@name | xsl:template/@match" mode="xml:value">
    <xsl:variable name="id">
      <xsl:apply-templates select=".." mode="id"/>
    </xsl:variable>
    <a href="#{$id}" class="val">
      <xsl:value-of select="."/>
    </a>
  </xsl:template>

</xsl:transform>
