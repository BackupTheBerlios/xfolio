<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="../html/xsl2html.xsl"?>
<!--
title   : xsl2html.xsl
rights  : Copyright 2003-2004 ADNX <http://adnx.org>
licence : GPL
creator : [FG] "Frédéric Glorieux" <frederic.glorieux@ajlsm.com> (documentation dev)

  = What =

This is an XSL to transform XSL, for documentation (a kind of "xsldoc").
This tool is designed for

 1) produce human readable paper for activities report (bad reason)
 2) have real time view to improve XSL design (real usage)
 3) help reusability of XSL (good wish)

  = How =

Add a stylesheet declaration to you XSL
<?xml-stylesheet type="text/xsl" href="xsl2html.xsl"?>
and see the result in an XSL browser compatible.
So, you can work an XSL in your favorite editor,
and reload the documentation view after each save.

The value added come also from imported resources
 * <text2html.xsl> provide HTML from text comments
 * <xml2html.xsl> provide HTML pretty-print of XML
   with as much as possible linking


  = Features =

 * Textual readable introduction for public (first XML comment)
 * A table summary for collaborative efficiency, and good design
 * Documented list of templates
 * Index of generated elements
 * Index of generated texts
 * Index of templates ordered by name, mode, match, priority
 * List of TODOs
 * XSL compact view (without XML, unplugged)
 * hidden email address

 = Ideas =

 * Index of matched elements
 * Usage of named templates
 * Clickable xpath expressions (matched elements, functions)
 * An autotoc on <h1/>

 = Changes = 

 * 2004-11-15 [FG] presentation for comments
 * 2004-11-07 [FG] creation

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
      <p>&#160;</p>
      <p>&#160;</p>
    </body>
  </xsl:template>
  
  <!-- 
call this template in xsl:transform to get a table header about it 

TODO attribute-set, 
-->
  <xsl:template name="xsl:summary">
      <h1>XSL Summary</h1>
      <table class="table" width="100%">
        <xsl:apply-templates select="xsl:include | xsl:import"/>
        <xsl:if test="xsl:param">
            <tr>
              <td>Parameter</td>
              <th>description</th>
              <th>value</th>
              <th>usage</th>
            </tr>
            <xsl:apply-templates select="xsl:param"/>
        </xsl:if>
        <xsl:if test="xsl:param">
            <tr>
                <td>Variable</td>
                <th>description</th>
                <th>value</th>
                <th>usage</th>
            </tr>
            <xsl:apply-templates select="xsl:variable"/>
        </xsl:if>
          <tr>
            <td>Generated elements</td>
            <td colspan="4">
              <!-- this tricky xpath expression is done to get only one elemnt with same name by template -->
              <xsl:for-each select="

.//*[namespace-uri() != 'http://www.w3.org/1999/XSL/Transform']
    [not(ancestor::xsl:template[@name='xsl:input'])]
">
                <xsl:sort select="name()"/>
                <xsl:if test="
   generate-id(ancestor::xsl:template) != 
   generate-id(preceding::*[namespace-uri() != 'http://www.w3.org/1999/XSL/Transform']
                           [name()=name(current())][1]
                           /ancestor::xsl:template)
">
                  <xsl:if test="position() != 1">, </xsl:if>
                  <a class="el">
                    <xsl:attribute name="href">
                      <xsl:text>#</xsl:text>
                      <xsl:apply-templates select="ancestor::xsl:template[1]" mode="id"/>
                    </xsl:attribute>
                    <xsl:value-of select="name()"/>
                  </a>
                </xsl:if>
              </xsl:for-each>
            </td>
          </tr>
          <tr>
            <td>Messages</td>
            <td colspan="4">

              <xsl:for-each select="
.//text()[normalize-space(.)!= '']
    [name(./..) != 'xsl:variable']
    [not(ancestor::xsl:template[@name='xsl:input'])]
">
                <xsl:if test="position() != 1"> &#160; </xsl:if>
                <code>
                  <a class="message">
                    <xsl:attribute name="href">
                      <xsl:text>#</xsl:text>
                      <xsl:apply-templates select="ancestor::xsl:template" mode="id"/>
                    </xsl:attribute>
                    <xsl:choose>
                      <xsl:when test="string-length(.) &lt; 51">
                        <xsl:value-of select="."/>
                      </xsl:when>
                      <xsl:otherwise>
                         <xsl:value-of select="substring(., 1, 50)"/>
                         <xsl:text> [...]</xsl:text>
                      </xsl:otherwise>
                    </xsl:choose>
                  </a>
                </code>
              </xsl:for-each>

            </td>
          </tr>
          <xsl:if test="contains(.//@select, 'document(')">
            <tr>
              <th>Documents</th>
              <td colspan="4">
                <xsl:for-each select=".//@select[contains(., 'document(')]">
                  <xsl:variable name="uri">
                    <xsl:value-of select="substring-before( substring-after(., 'document(' )   , ')')"/>
                  </xsl:variable>
                  <xsl:if test="position() != 1">, </xsl:if>
                  <a href='{translate($uri, "&apos;", "")}'>
                    <xsl:value-of select="$uri"/>
                  </a>
                </xsl:for-each>
              </td>
            </tr>
            
          </xsl:if>
            <!-- templates -->

        <tr>
          <td>template</td>
          <th>match</th>
          <th>parameters</th>
          <th>mode</th>
        </tr>


        <xsl:apply-templates select="xsl:template" mode="tr">
          <xsl:sort select="@name"/>
          <xsl:sort select="@mode"/>
          <xsl:sort select="normalize-space(@match)"/>
        
        </xsl:apply-templates>

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
          <xsl:call-template name="break-string">
            <xsl:with-param name="text">
              <xsl:apply-templates select="@select"/>
            </xsl:with-param>
          </xsl:call-template>
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
    <!-- description -->
        <xsl:apply-templates select="
preceding-sibling::comment()[1][generate-id(following-sibling::*)=generate-id(current())]
" mode="text2html"/>
    <!-- input >> output -->
    <xsl:apply-templates select="xsl:template[@name='xsl:input']"/>
    <!-- task lists -->
    <xsl:call-template name="tasks"/>
    <!-- header -->
    <xsl:call-template name="xsl:summary"/>
    <!-- templates description -->
    <h1>Template detail</h1>
    <xsl:apply-templates select="xsl:template"/>
  </xsl:template>

  <!-- 
Task list (todo)

Give the list of task marked in comments.
This template may be of general interest for 
XML development like ant build or cocoon sitemap.
The feature lay on a keyword we will not use here,
to avoid this comment to be a new task.
 -->
  <xsl:template name="tasks">
    <xsl:if test=".//comment()[contains(., 'TODO')]">
      <!-- TODO, only to test the feature -->
      <h1>TODOs</h1>
      <ul class="tasks">
        <xsl:for-each select=".//comment()[contains(., 'TODO')]">
          <li class="TODO">
            <xsl:apply-templates select="following-sibling::xsl:template[1]|ancestor::xsl:template" mode="link"/>
            <xsl:call-template name="inlines">
              <xsl:with-param name="text" select="substring-after(., 'TODO')"/>
            </xsl:call-template>
          </li>
        </xsl:for-each>
      </ul>
    </xsl:if>
  </xsl:template>


  <!-- give a fast summary of templates -->
  <xsl:template match="xsl:template" mode="tr">
    <tr>
      <th>
        <xsl:if test="@name">
          <a>
            <xsl:attribute name="href">
              <xsl:text>#</xsl:text>
              <xsl:apply-templates select="." mode="id"/>
             </xsl:attribute>
             <xsl:apply-templates select="@name"/>
          </a>
        </xsl:if>
      </th>
      <!-- match -->
      <td valign="top">
        <xsl:if test="@match">
          <a>
            <xsl:attribute name="href">
              <xsl:text>#</xsl:text>
              <xsl:apply-templates select="." mode="id"/>
             </xsl:attribute>
              <xsl:apply-templates select="@match"/>
          </a>
        </xsl:if>
      </td>
      <!-- parameters -->
      <td>
        <xsl:if test="xsl:param">
          <xsl:text> (</xsl:text>
          <xsl:for-each select="xsl:param">
            <xsl:if test="position() != 1">, </xsl:if>
            <xsl:apply-templates select="@name"/>
          </xsl:for-each>
          <xsl:text>) </xsl:text>
        </xsl:if>
      </td>
      <!-- mode -->
      <td valign="top">
        <xsl:apply-templates select="@mode"/>
      </td>
      <!-- priority ? -->
    </tr>
  </xsl:template>
  
  <!-- @name -->
  <xsl:template match="@name">
    <xsl:value-of select="."/>
  </xsl:template>

  <!-- @test -->
  <xsl:template match="@test">
    <xsl:text> (</xsl:text>
    <xsl:value-of select="."/>
    <xsl:text>)? </xsl:text>
  </xsl:template>

  <!-- @match -->
  <xsl:template match="@match | @select">
    <xsl:text> {</xsl:text>
    <xsl:value-of select="."/>
    <xsl:text>} </xsl:text>
  </xsl:template>

  <!-- @mode -->
  <xsl:template match="@mode">
    <xsl:text> &gt;</xsl:text>
    <xsl:value-of select="."/>
    <xsl:text>&gt; </xsl:text>
  </xsl:template>

  <!-- A documented template (@name or @match) -->
  <xsl:template match="xsl:template">
    <h2>
      <xsl:attribute name="id">
        <xsl:apply-templates select="." mode="id"/>
      </xsl:attribute>
        <xsl:apply-templates select="@name"/>
        <xsl:apply-templates select="@match"/>
        <xsl:apply-templates select="@mode"/>
    </h2>
    <xsl:apply-templates select="
preceding-sibling::comment()[1][generate-id(following-sibling::*)=generate-id(current())]
" mode="text2html"/>
    <p>&#160;</p>
    <xsl:apply-templates select="." mode="xml:html"/>
    <p>&#160;</p>
  </xsl:template>

  <!-- match a specific named template where sample input xml maybe stored -->
  <xsl:template match="xsl:template[@name='xsl:input']">
    <h1>Sample input</h1>
    <xsl:apply-templates mode="xml:html"/>
  </xsl:template>
    
  <!-- xsl:template, generate compact view -->
  <xsl:template name="xsl:template">
    <div class="code">
        <xsl:if test="@match">
          <xsl:apply-templates select="@match" />
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
  
  <!-- xsl:for-each, compact view -->
  <xsl:template match="xsl:for-each">
    <div class="code">
      <xsl:text>(</xsl:text>
      <xsl:apply-templates select="@select"/>
      <xsl:text>) * {</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}; </xsl:text>
    </div>
  </xsl:template>

  <!-- generated messages -->
  <xsl:template match="text() | xsl:text">
    <b>
      <xsl:value-of select="."/>
    </b>
  </xsl:template>

  <!-- apply comments in a compact view -->
  <xsl:template match="comment()">
    <div class="code-comment">
      <xsl:apply-templates select="." mode="text2html"/>
    </div>
  </xsl:template>

  <!-- xsl:if, compact view, may be shown as xsl:when -->
  <xsl:template match="xsl:if" >
    <div class="code">
      <xsl:apply-templates select="@test" />
      <xsl:text> {</xsl:text>
      <xsl:apply-templates />
      <xsl:text>} </xsl:text>
    </div>
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

  <!-- xsl:element, take care of name and generated attributes -->
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


  <!-- xsl:choose, pass to children -->
  <xsl:template match="xsl:choose" >
      <xsl:apply-templates />
  </xsl:template>
  
  <!-- xsl:value-of, xsl:copy-of ; compact view as {@select} -->
  <xsl:template match="xsl:copy-of | xsl:value-of" >
    <xsl:apply-templates select="@select"/>
  </xsl:template>
  
  <!-- xsl:when, a compact view, like a test block -->
  <xsl:template match="xsl:when" >
    <div class="code">
      <xsl:text> : </xsl:text>
      <xsl:apply-templates select="@test"/>
      <xsl:text> {</xsl:text>
      <xsl:apply-templates />
      <xsl:text>}; </xsl:text>
    </div>
  </xsl:template>

  <!-- xsl:otherwise, a compact view -->
  <xsl:template match="xsl:otherwise">
    <div class="code">
      <xsl:text>: {</xsl:text>
      <xsl:apply-templates />
      <xsl:text>}; </xsl:text>
    </div>
  </xsl:template>
  
  <!-- xsl:call-template, a compact view, like a function($param={.}) -->
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
  
  <!-- xsl:with-param, a compact view -->
  <xsl:template match="xsl:with-param" >
    <xsl:value-of select="@name"/>
    <xsl:text>={</xsl:text>
    <xsl:apply-templates select="@select"/>
    <xsl:apply-templates />
    <xsl:text>}</xsl:text>
  </xsl:template>

  <!-- xsl:param, a compact view  -->
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

  <!-- xsl:variable a compact view -->
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
    
    <!-- xsl:copy, a compact view -->
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

    <!-- apply-templates, a compact view -->
    <xsl:template match="xsl:apply-templates" >
      <div class="code">
        <xsl:choose>
          <xsl:when test="@select">
            <xsl:apply-templates select="@select" />
          </xsl:when>
          <xsl:otherwise>{node()}</xsl:otherwise>
        </xsl:choose>
        <xsl:text> &gt;&gt;</xsl:text>
      </div>
    </xsl:template>
        
    
  <!-- strip empty lines -->
  <xsl:template match="text()[normalize-space(.)='']"/>

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
  <!-- link a call-template to its template documentation -->
  <xsl:template match="xsl:call-template/@name" mode="xml:value">
    <a href="#{.}" class="val">
      <xsl:value-of select="."/>
    </a>
  </xsl:template>

</xsl:transform>
