<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="text2html.xsl"?>
<?js html.js?>
<?demo?>
<!--

                 text2html


Copyright 2003-2004 ADNX <http://adnx.org>
[FG] "Frédéric Glorieux" <frederic.glorieux@ajlsm.com>



. What

    Parse text to produce some well-formed XML (here, HTML).

. Features

.. Titles

    !JSPWiki titles

    === Moin Moin titles ===

.. Lists

     * item
     * item
     * item
     * item

    o disc
    o disc

    # coucou
    # beuh
    # salut


Block
  This parser understand a block as a text portion between two
  blank lines (with the exception of "horizontal rule", hr)
horizontal rule
hr
  An horizontal rule like "==== ..." is very useful to format text.
  This parser try to render them , but they have no semantic value.
Definition list
  A definition list is a serie of terms and definitions.
  This parser understand a definition list as a block (blank line separated)
Term:
     In a definition list, a term is a line without indentation.
     Some people like the semi-colon ':' to say it's a "term:", 
     and see the definition after.
     This may be a problem for future extraction of terms, so the last
     ':' of a term is stripped.


.. Preformatted blocks

    Some code

    <xsl:when test="starts-with($text, '  ')">
      <pre>
        <xsl:value-of select="$text"/>
With a really long line to see what to do with. It's possible to wrap it for a better layout but isn't it dangerous ? Should think about it, but it's possible, work is prepared somewhere.
      </pre>
    </xsl:when>


    A poem

  UN COUP DE DÉS
  
    JAMAIS
  
  QUAND BIEN MÊME LANCÉ DANS DES CIRCONSTANCES
ÉTERNELLES
  
            DU FOND D'UN NAUFRAGE
                                     [...]
N'ABOLIRA
            [...]
                  LE HASARD     [...]
  
Stéphane Mallarmé, "Un coup de dés"




. TODO

.. hierarchical list

o 1.
oo 1.1. (level2)
oo 1.2. level2
ooo 1.2.1 level3
    continue level 3
  o 1.2.2 level 3, item 2 (recognize by indent)


..  mails

    > Il giorno 29/ott/04, alle 14:36, Jeremy Quinn ha scritto:
    >>
    >> On 29 Oct 2004, at 13:23, Ugo Cei wrote:
    >>
    >>> Il giorno 29/ott/04, alle 12:41, Jeremy Quinn ha scritto:
    >>>
    >>>> What I hope to do is to make the Queries persistable in HSQLDB via 
    >>>> ORO and add this to Cocoon as a new Block, both as a sample and as 
    >>>> a useful module that should be easy to add to your own project.
    >>>
    >>> I'm sure you meant OJB instead of ORO here, right?
    >>
    >> Yeah, sorry :)
    >>
    >> OJB, OJB OJB ..... that is even worse than your OBJ mistake ;)
    >
    > No, it was Bertrand's mistake, not mine ;-)

.. fields

    Date: Wed, 27 Oct 2004 12:47:34 +0200
    From: Paul Terray <terray@4dconcept.fr>
    To: Nader Boutros - Strabon <boutros@msh-paris.fr>
    Cc: =?ISO-8859-1?Q?Fr=E9d=E9ric_Glorieux?= <frederic.glorieux@ajlsm.com>,
      Andre Del <andre.del@evcau.archi.fr>,
      Pierrick Brihaye <pierrick.brihaye@wanadoo.fr>,
      Pierrick Brihaye <pierrick.brihaye@culture.gouv.fr>
    Subject: Re: Serveurs MSH et CR =?ISO-8859-1?Q?r=E9union_tech?=

. Issues

    Because it's not separated by an empty line
    these "=======" are not considered as a graphic line
    ===================================================

    !This title is linked to the second
    
    === because of trailing spaces ===


. Changes

    * 2004-11-05 [FG] for browser compatibility reason, sxw xml is named sxw.xml
    * 2004-11-01 [FG] creation

. References


-->
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" 
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
 
>
  <!-- different interesting tools for the fast test view -->
  <xsl:import href="html-common.xsl"/>
  <xsl:import href="xml2html.xsl"/>
  <!-- the output declaration -->
  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
  <!-- the break line, tested on IE, Mozilla, XMLSpy -->
  <xsl:param name="CR" select="'&#10;'"/>
  <!-- demo means this applied to  -->
  <xsl:param name="demo">
    <xsl:if test="processing-instruction('demo')">
      <xsl:value-of select="true()"/>
    </xsl:if>
  </xsl:param>
  <!-- chars accepted for bullet list -->
  <xsl:variable name="bullets" select="'*o-'"/>
  <!-- chars accepted for ordered list -->
  <xsl:variable name="numbers" select="'0123456789#'"/>

  <xsl:template match="/">
    <html>
      <head>
        <title> TODO </title>
        <xsl:call-template name="head-common"/>
      </head>
      <xsl:call-template name="demo"/>
    </html>
  </xsl:template>
  <!--



  -->
  <xsl:template name="demo">
    <!-- onload is an hack for Mozilla to show the generated code -->
    <body onload="
      if (!document.getElementById) return true; 
      var textarea=document.getElementById('xml');
      html=textarea.innerHTML;
      if (html.search('/') != -1) return;
      html=document.getElementById('text2html').innerHTML;
      textarea.value=html;
      return true;
    ">
    <xsl:variable name="html">
      <xsl:call-template name="text2html">
        <xsl:with-param name="text" select="document('', .)//comment()"/>
      </xsl:call-template>
    </xsl:variable>
    <div id="text2html">
      <xsl:copy-of select="$html"/>
    </div>
    <hr /><hr />
    <h1>Text source</h1>
    <pre class="code" style="background:#EEEEFF">
      <span style="background:#FFFFFF">
        <xsl:value-of select="document('', .)//comment()"/>
      </span>
    </pre>
    <h1>Generated HTML</h1>

    <p>A very light view-source</p>
    <textarea id="xml" style="background:#FFFFEE; width:100%;" rows="25" cols="100">
      <!-- will not work in Mozilla -->
      <xsl:copy-of select="$html"/>
    </textarea>
    </body>
  </xsl:template>
  <!--

split a string in blocks on empty lines

  -->
  <xsl:template match="node()" name="text2html" mode="text2html">
    <!-- the text to pass -->
    <xsl:param name="text" select="."/>
    <!-- if it's not the first block -->
    <xsl:param name="more"/>
    <xsl:variable name="line" select="substring-before($text, $CR)"/>

    <xsl:choose>
      <!-- don't forget to stop -->
      <xsl:when test="normalize-space($text) =''"/>
      <!-- if only one line, give hand directly to inlines -->
      <xsl:when test="not(contains($text, $CR)) and not($more)">
        <xsl:call-template name="inlines">
          <xsl:with-param name="text" select="$text"/>
        </xsl:call-template>
      </xsl:when>
      <!-- add a blank line at the end for lighter testing, should be first call -->
      <xsl:when test="substring($text, string-length($text)-1) != concat($CR, $CR)">
        <xsl:call-template name="text2html">
          <xsl:with-param name="text" select="concat($text, $CR, $CR)"/>
        </xsl:call-template>
      </xsl:when>
      <!-- whash empty lines at the begining -->
      <xsl:when test="contains($text, $CR) and normalize-space(substring-before($text, $CR))=''">
        <xsl:call-template name="text2html">
          <xsl:with-param name="text" select="substring-after($text, $CR)"/>
          <xsl:with-param name="more" select="$more"/>
        </xsl:call-template>
      </xsl:when>
      <!--  -->
      
      <!-- repeated pattern, may be an horizontal line -->
      <xsl:when test="
normalize-space(
    translate(
        $line, 
        concat( 
            substring($line, 1, 1),
            substring($line, 2, 1)
        ), 
        '' 
    )
) = ''
">
        
        <hr/>
        <xsl:call-template name="text2html">
          <xsl:with-param name="text" select="substring-after($text, $CR)"/>
          <xsl:with-param name="more" select="$more"/>
        </xsl:call-template>
      </xsl:when>
      <!-- if 2 CR are separated by spaces or tab, we are in code  -->
      <xsl:when test="contains($text, concat($CR, $CR))">
        <xsl:call-template name="block">
          <xsl:with-param name="text" select="substring-before($text, concat($CR, $CR))"/>
        </xsl:call-template>
        <xsl:value-of select="concat($CR, $CR)"/>
        <xsl:call-template name="text2html">
          <xsl:with-param name="text" select="substring-after($text, concat($CR, $CR))"/>
          <xsl:with-param name="more" select="true()"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <h1> SHOULD NEVER ARRIVE </h1>
        <xsl:call-template name="block">
          <xsl:with-param name="text" select="$text"/>
        </xsl:call-template>
        <xsl:value-of select="concat($CR, $CR)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- choose an element name on begining of a string -->
  <xsl:template name="block">
    <xsl:param name="text" select="."/>
    <xsl:variable name="norm" select="normalize-space($text)"/>
    <xsl:variable name="prefix">
      <xsl:choose>
        <xsl:when test="contains($norm, ' ')">
          <xsl:value-of select="substring-before($norm, ' ')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$norm"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <!-- don't forget to stop -->
      <xsl:when test="$norm = ''"/>
      <!-- begin with '=', maybe a moin moin title -->
      <xsl:when test="starts-with($prefix,'=') and contains($text, $prefix)">
        <xsl:element name="h{string-length(substring($prefix, 1, 6))}">
          <xsl:call-template name="inlines">
            <xsl:with-param name="text" select="normalize-space(translate($norm, '=', ''))"/>
          </xsl:call-template>
        </xsl:element>
      </xsl:when>
      <!-- begin with '!', a JSPWiki title -->
      <xsl:when test="starts-with($prefix, '!')">
        <xsl:variable name="name">
          <xsl:choose>
            <xsl:when test="starts-with($prefix, '!!!')">h1</xsl:when>
            <xsl:when test="starts-with($prefix, '!!')">h2</xsl:when>
            <xsl:when test="starts-with($prefix, '!')">h3</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:element name="{$name}">
          <xsl:call-template name="inlines">
            <xsl:with-param name="text" select="
normalize-space(
  concat( 
    translate($prefix, '!', '')
  , substring-after($text, $prefix)
  )
)"/>
          </xsl:call-template>
        </xsl:element>
      </xsl:when>
      <!-- only one line, probably a title -->
      <xsl:when test="not(contains($text, $CR))">
        <xsl:variable name="level" select="string-length($prefix) - string-length(translate($prefix, '.)', ''))"/>
        <xsl:choose>
          <xsl:when test="$level &lt; 1 or $level &gt; 6">
            <h6>
              <xsl:call-template name="inlines">
                <xsl:with-param name="text" select="$text"/>
              </xsl:call-template>
            </h6>
          </xsl:when>
          <xsl:otherwise>
            <xsl:element name="h{$level}">
              <xsl:call-template name="inlines">
                <xsl:with-param name="text" select="substring-after($text, concat($prefix, ' '))"/>
              </xsl:call-template>
            </xsl:element>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <!-- bullet list -->
      <xsl:when test="contains($bullets, substring($prefix, 1, 1))">
        <ul>
          <xsl:call-template name="list">
            <xsl:with-param name="text" select="$text"/>
          </xsl:call-template>
        </ul>
      </xsl:when>
      <!-- ordered list -->
      <xsl:when test="starts-with($prefix, '#')">
        <ol>
          <xsl:call-template name="list">
            <xsl:with-param name="text" select="$text"/>
          </xsl:call-template>
        </ol>
      </xsl:when>
      <!-- mail answer -->
      <xsl:when test="starts-with($prefix, '>')">
        <pre>
          <xsl:value-of select="$text"/>
        </pre>
      </xsl:when>
      <!-- list of terms -->
      <xsl:when test="contains($text, concat($CR, '  '))">
        <dl>
          <xsl:call-template name="dl">
            <xsl:with-param name="text" select="$text"/>
          </xsl:call-template>
        </dl>
      </xsl:when>
      <!-- 
preformated block
  between two empty lines, if first line begins with 2 spaces
  without any markers (like '*' or '#' for lists)
-->
      <xsl:when test="contains($text, '==') or contains($text, '/&gt;')">
        <pre>
          <xsl:if test="contains($text, '==') or contains($text, '/&gt;')">
            <xsl:attribute name="class">code</xsl:attribute>
          </xsl:if>
          <xsl:value-of select="$text"/>
        </pre>
      </xsl:when>
      <xsl:otherwise>
        <p>
          <xsl:value-of select="$text"/>
        </p>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- parse lines (for lists and other things) -->
  <xsl:template name="list">
    <xsl:param name="text"/>
    <!-- should be set only the first time -->
    <xsl:param name="marker" select="substring(normalize-space($text), 1, 1)"/>
    <xsl:choose>
      <xsl:when test="normalize-space($text) =''"/>
      <!-- first time, see after marker -->
      <xsl:when test="substring(normalize-space($text), 1, 1) = $marker">
        <xsl:call-template name="list">
          <xsl:with-param name="marker" select="$marker"/>
          <xsl:with-param name="text" select="
normalize-space(concat(substring-after($text, concat($marker, ' ')), concat(' ', $marker, ' ')))"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <li>
          <xsl:call-template name="inlines">
            <xsl:with-param name="text" select="normalize-space(substring-before($text, concat(' ', $marker)))"/>
          </xsl:call-template>
        </li>
        <xsl:call-template name="list">
          <xsl:with-param name="marker" select="$marker"/>
          <xsl:with-param name="text" select="substring-after($text, concat($marker, ' '))"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- find inlines  -->
  <xsl:template name="inlines">
    <xsl:param name="text"/>
    <xsl:value-of select="$text"/>
  </xsl:template>
  <!-- 

definition list  

-->
  <xsl:template name="dl">
    <xsl:param name="text"/>
    <xsl:choose>
      <xsl:when test="normalize-space($text) = ''"/>
      <!-- term -->
      <xsl:when test="not(starts-with($text, '  '))">
        <xsl:variable name="term">
          <xsl:choose>
            <xsl:when test="contains($text, $CR)">
              <xsl:value-of select="normalize-space(substring-before($text, $CR))"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="normalize-space($text)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="concat($CR, '  ')"/>
        <dt>
          <xsl:call-template name="inlines">
            <xsl:with-param name="text">
              <xsl:choose>
                <!-- case of "xmlns:term:" -->
                <xsl:when test="substring($term, string-length($term)) = ':'">
                  <xsl:value-of select="substring($term, 1, string-length($term) - 1)"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$term"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:with-param>
          </xsl:call-template>
        </dt>
        <xsl:if test="contains($text, $CR)">
          <xsl:call-template name="dl">
            <xsl:with-param name="text" select="substring-after($text, $CR)"/>
          </xsl:call-template>
        </xsl:if>
      </xsl:when>
      <!-- definition -->
      <xsl:otherwise>
        <xsl:variable name="definition">
          <xsl:call-template name="text-align">
            <xsl:with-param name="text" select="$text"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="concat($CR, '  ')"/>
        <dd>
          <xsl:call-template name="inlines">
            <xsl:with-param name="text" select="$definition"/>
          </xsl:call-template>
        </dd>
        <xsl:value-of select="$CR"/>
        <!-- strange loop if no test -->
        <xsl:if test="contains($text, $definition)">
          <xsl:call-template name="dl">
            <xsl:with-param name="text" select="substring-after($text, $definition)"/>
          </xsl:call-template>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- 
this template select the first lines of a text with same alignment 
useful for definitions,
 mail answer may share the logic

 may bug with empty lines
-->
  <xsl:template name="text-align">
    <xsl:param name="text"/>
    <xsl:choose>
      <xsl:when test="normalize-space($text) = ''"/>
      <!-- no margin, stop -->
      <xsl:when test="not(starts-with($text, '  '))"/>
      <!-- with other lines -->
      <xsl:when test="contains($text, $CR)">
        <xsl:value-of select="substring-before($text, $CR)"/>
        <xsl:value-of select="$CR"/>
        <xsl:call-template name="text-align">
          <xsl:with-param name="text" select="substring-after($text, $CR)"/>
        </xsl:call-template>
      </xsl:when>
      <!-- should be last line -->
      <xsl:otherwise>
        <xsl:value-of select="$text"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
