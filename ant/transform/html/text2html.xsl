<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="xsl2html.xsl"?>
<?js html.js?>
<?demo?>
<!--

                 text2html


rights:Copyright 2003-2004 ADNX <http://adnx.org>
creator:[FG] "Frédéric Glorieux" <frederic.glorieux@ajlsm.com>



. What

    Parse text to produce some well-formed XML (here, HTML).

. Features

.. Titles

    !JSPWiki titles (starts with "!")

    === Moin Moin titles === 

.. Lists

   * item 1
   * item 2
      oo item 2a is marked by "oo"
      ** item 2b
      ** item 2c
   - item 3 is marked by an '-'
      ** item 3a is writtent on multiple line
  without specific formatting 
      (except no marker at start)
      ** item 3b
          ### item 3b1, an ordered list marked by "###"
          3.2.2) item 3b2 is marked as ordered by "3.2.2)"
          1.1.1. item 3b3, works also with "1.1.1." 
                 but don't forget the last point.
      ** item 3c
   * item 4

Definition list
  A definition list is a serie of terms and definitions.
  This parser understand a definition list as a block (blank line separated)
Block
  This parser understand a block as a text portion between two
  blank lines (with the exception of "horizontal rule", hr)
horizontal rule
hr
  An horizontal rule like "==== ..." is very useful to format text.
  This parser try to render them , but they have no semantic value.
Term:
     In a definition list, a term is a line without indentation.
     Some people like the semi-colon ':' to say it's a "term:", 
     and see the definition after.
     This may be a problem for future extraction of terms, so the last
     ':' of a term is stripped.



.. Code

    <xsl:when test="starts-with($text, '  ')">
      <pre>
        <xsl:value-of select="$text"/>
With a really long line to see what to do with. It's possible to wrap it for a better layout but isn't it dangerous ? Should think about it, but it's possible, work is prepared somewhere.
      </pre>
    </xsl:when>

/* take code like it is in the source */
pre.code, pre.xml, pre.java {
    font-family: "Lucida Console", Courier, "MS Courier New", monospace; 
    padding-left:2em;
    padding-top:1ex;
    padding-right:1ex;
    line-height: 110%;
    font-size:80%;
    color:#000000;
    background-color:#F5F5F0;
}

.. fields

Licence   : http://www.fsf.org/copyleft/gpl.html
    Copyright : (C) 2004 ADNX <http://adnx.org>
    Date: Wed, 27 Oct 2004 12:47:34 +0200
    From: Paul Terray <terray@4dconcept.fr>
    To: Nader Boutros - Strabon <boutros@msh-paris.fr>
    Cc: =?ISO-8859-1?Q?Fr=E9d=E9ric_Glorieux?= <frederic.glorieux@ajlsm.com>,
      Andre Del <andre.del@evcau.archi.fr>,
      Pierrick Brihaye <pierrick.brihaye@wanadoo.fr>,
      Pierrick Brihaye <pierrick.brihaye@culture.gouv.fr>
    Subject: Re: Serveurs MSH et CR =?ISO-8859-1?Q?r=E9union_tech?=



. TODO

.. Inlines

  A simple blocks with different *emphase*, especially the
  classical _like underline_. Links policy will focus first on
  "Active text" <URI>. 

.. Simple tables



. Issues

..  mails

>
> hello
> how are you ?
>
Hi all, it's me.
This is a level 0 block. 
There's problems in string templates with XSL.
I can't understand where is the bug 
(in the templates, or in XSL implementation ?)
Conclusion is, use it only to display, other usage
of outputs may create problems.
>>>
>>> Is it possible to drop directly to the third level ?
>>>
  
>
> This is level 1 original message
> On a level 1, a line 2 
>
>=20
>>
>> Reply to level 2 excerpt (marked '>>')
>> This is a sample mail to test text2html.xsl.
  >
  > This a level 1 phrase with a problematic indent
  > 
Maybe very useful to publish fastly a full mailbox ? But careful with 
performances issues, XSL is not the fastest language in the world.

 
>> 
>> This sample test will try different things especially the problem of 
>> answers, and encoding of special letters. This will not be perfect, 
>> and for now focussed on ISO-8859-1 letters.
>>
>>>
>>> A level 3 phrase
>>>
>>
>   - =E9crans de pr=E9sentation 
>   - d=E9mo : bient=F4t, il y aura la n=F4tre
> - =AB limit of decoding "2*20=40 2*20= 40"
  
A little normal block
which should not be indented.
  
>> * this list will not be parsed
>> * nor this item
>> * sad ? 

  
> Could you imagine to keep all mail in one block ?
> 

.. Trailing spaces

    !This title is linked to the second
    
    === because of trailing spaces ===


.. Horizontal rules

    Because it's not separated by an empty line
    these "=======" are not considered as a graphic line
    ===================================================


. Changes

    * 2004-11-09 [FG] Lots of work, quite all
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
  <xsl:param name="LF" select="'&#10;'"/>
  <xsl:param name="TAB" select="'&#9;'"/>

  <!-- demo means this applied to  -->
  <xsl:param name="demo">
    <xsl:if test="processing-instruction('demo')">
      <xsl:value-of select="true()"/>
    </xsl:if>
  </xsl:param>
  <!-- seems to be useful -->
  <xsl:variable name="gt" select="'>'"/>
  <!-- chars accepted for bullet list -->
  <xsl:variable name="bullets" select="'*o-'"/>
  <!-- chars accepted for ordered list -->
  <xsl:variable name="numbers" select="'0123456789#'"/>
  <!-- a long string of spaces -->
  <xsl:variable name="spaces" select="'                                            '"/>
  <!-- The root template -->
  <xsl:template match="/">
    <html>
      <head>
        <title> TODO </title>
        <xsl:call-template name="head-common"/>
      </head>
      <xsl:choose>
        <xsl:when test="$demo and comment()">
          <xsl:call-template name="demo">
            <xsl:with-param name="text" select="comment()"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="$demo">
          <xsl:call-template name="demo"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="text2html"/>
        </xsl:otherwise>
      </xsl:choose>
    </html>
  </xsl:template>

  <xsl:template name="demo">
    <xsl:param name="text" select="."/>
    <!-- onload is an hack for Mozilla to show the generated code -->
    <body id="body" onresize="fit(80)" onload="
      init(80);
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
        <xsl:with-param name="text" select="$text"/>
      </xsl:call-template>
    </xsl:variable>
    <div id="text2html">
      <xsl:copy-of select="$html"/>
    </div>
    <h1>Text source</h1>
    <pre class="code" style="background:#EEEEFF">
      <span style="background:#FFFFFF">
        <xsl:value-of select="$text"/>
      </span>
    </pre>
    <h1>Generated HTML</h1>

    <p>A very light view-source</p>
    <textarea id="xml" style="background:#FFFFEE; width:100%;" rows="25" cols="100">
      <!-- will not work in Mozilla, a javascript workaround is possible -->
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
    <xsl:variable name="line" select="substring-before($text, $LF)"/>

    <xsl:choose>
      <!-- don't forget to stop -->
      <xsl:when test="normalize-space($text) =''"/>
      <!-- if only one line, give hand directly to inlines -->
      <xsl:when test="not(contains($text, $LF)) and not($more)">
        <xsl:call-template name="inlines">
          <xsl:with-param name="text" select="$text"/>
        </xsl:call-template>
      </xsl:when>
      <!-- add a blank line at the end for lighter testing, should be first call -->
      <xsl:when test="substring($text, string-length($text)-1) != concat($LF, $LF)">
        <xsl:call-template name="text2html">
          <xsl:with-param name="text" select="concat($text, $LF, $LF)"/>
        </xsl:call-template>
      </xsl:when>
      <!-- whash empty lines at the begining -->
      <xsl:when test="contains($text, $LF) and normalize-space(substring-before($text, $LF))=''">
        <xsl:call-template name="text2html">
          <xsl:with-param name="text" select="substring-after($text, $LF)"/>
          <xsl:with-param name="more" select="$more"/>
        </xsl:call-template>
      </xsl:when>
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
) = '' and string-length(normalize-space($line)) &gt; 4
">
        
        <hr/>
        <xsl:value-of select="concat($LF, $LF)"/>
        <xsl:call-template name="text2html">
          <xsl:with-param name="text" select="substring-after($text, $LF)"/>
          <xsl:with-param name="more" select="$more"/>
        </xsl:call-template>
      </xsl:when>
      <!--  what about trailing spaces ? bug if 2 CR are separated by spaces or tab -->
      <xsl:when test="contains($text, concat($LF, $LF))">
        <xsl:call-template name="block">
          <xsl:with-param name="text" select="substring-before($text, concat($LF, $LF))"/>
        </xsl:call-template>
        <xsl:value-of select="concat($LF, $LF)"/>
        <xsl:call-template name="text2html">
          <xsl:with-param name="text" select="substring-after($text, concat($LF, $LF))"/>
          <xsl:with-param name="more" select="true()"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <h1> SHOULD NEVER ARRIVE </h1>
        <xsl:value-of select="$text"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!-- 

choose an element name on begining of a string 
  
  -->

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
      <xsl:when test="not(contains($text, $LF))">
        <xsl:variable name="level" select="string-length($prefix) - string-length(translate($prefix, '.)', ''))"/>
        <xsl:choose>
          <xsl:when test="$level &lt; 1 or $level &gt; 6">
            <h4>
              <xsl:call-template name="inlines">
                <xsl:with-param name="text" select="$text"/>
              </xsl:call-template>
            </h4>
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
      <!-- lists -->
      <!-- TODO better matching of lists -->
      <xsl:when test="
    translate($prefix, '0123456789.)*#o-&gt;', '') = ''
">
        <xsl:call-template name="list">
          <xsl:with-param name="text" select="$text"/>
        </xsl:call-template>
      </xsl:when>
      <!-- mail answer -->
      <xsl:when test="contains($text, concat($LF, '>'))">
        <div class="mail">
          <xsl:call-template name="hierarchy">
            <xsl:with-param name="text">
              <xsl:call-template name="mail-norm">
                <xsl:with-param name="text" select="$text"/>
              </xsl:call-template>
              <!-- TODO add concat($LF, ' ') is not a nice limit of hirarchy template -->
              <xsl:value-of select="concat($LF, ' ')"/>
            </xsl:with-param>
          </xsl:call-template>
        </div>
      </xsl:when>
      <!-- 
preformated of code block
marker should be clever and to test a lot
this is XML-WEB-JAVA centric
Maybe they should have

 * indentation
 * '</' and '">' for XML
 * '{' or '&&' for JAVA


  between two empty lines, if first line begins with 2 spaces
  without any markers (like '*' or '#' for lists)
-->
      <xsl:when test="
    (contains($text, '  ') or contains($text, $TAB))
and (contains($text, '&lt;/') and contains($text, '&quot;&gt;') )
">
        <pre class="xml">
          <xsl:value-of select="$text"/>
        </pre>
      </xsl:when>
      <xsl:when test="
    (contains($text, '  ') or contains($text, $TAB))and 
(
    ( contains($text, '/*') and contains($text, '*/') )
or ( contains($text, '{') and contains($text, '}') )
)
">
        <pre class="code">
          <xsl:value-of select="$text"/>
        </pre>
      </xsl:when>
      <!-- list of fields, should come after preform -->
      <!-- TOTEST perhaps this a too large match -->
      <xsl:when test="
        normalize-space(substring-before($text, ':')) != '' 
and not(contains(normalize-space(substring-before($text, ':')), ' '))
">
        <table>
          <xsl:call-template name="fields-rows">
            <xsl:with-param name="text">
              <xsl:call-template name="fields-norm">
                <xsl:with-param name="text" select="$text"/>
              </xsl:call-template>
            </xsl:with-param>
          </xsl:call-template>
        </table>

      </xsl:when>
      <!-- list of terms -->
      <xsl:when test="contains($text, concat($LF, '  '))">
        <dl>
          <xsl:call-template name="dl">
            <xsl:with-param name="text" select="$text"/>
          </xsl:call-template>
        </dl>
      </xsl:when>
      <xsl:otherwise>
        <p>
          <xsl:if test="contains($text, $LF)">
            <xsl:value-of select="$LF"/>
          </xsl:if>
          <xsl:value-of select="$text"/>
          <xsl:if test="contains($text, $LF)">
            <xsl:value-of select="$LF"/>
          </xsl:if>
        </p>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- 

handle list like block of lines

-->
  <xsl:template name="list">
    <xsl:param name="text"/>
    <xsl:variable name="norm">
       <xsl:call-template name="indent-norm">
         <xsl:with-param name="text" select="$text"/>
       </xsl:call-template>
    </xsl:variable>
    <xsl:call-template name="hierarchy">
       <xsl:with-param name="text" select="concat($norm, $LF, ' ')"/>
    </xsl:call-template>
  </xsl:template>
  <!-- 
This template restore hierarchy on tabs with a text formated as

start..><LF><TAB><Space><marker> .................
        <LF><TAB><TAB><Space><marker>..........what you want without TAB or LF
        <LF><Space><..end

-->
  <xsl:template name="hierarchy">
    <xsl:param name="text"/>
    <!-- only a remembering marker -->
    <xsl:param name="level" select="1"/>
    <!-- name of the item element -->
    <xsl:param name="item" select="'li'"/>
    <!-- the char used as tab, default is ASCII TAB, not tested ! but it could be something else ? -->
    <xsl:param name="tab" select="$TAB"/>
    
    <xsl:choose>
      <xsl:when test="normalize-space($text)=''"/>
      <!--
      <xsl:when test="starts-with($text, $tab)">
        <xsl:element name="{$block}">
        starts with tab
          <xsl:call-template name="hierarchy">
            <xsl:with-param name="text">
              <xsl:call-template name="blockquote-first">
                <xsl:with-param name="text" select="$text"/>
              </xsl:call-template>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:element>
      </xsl:when>
       -->
      <!-- there's a block to indent, try to get the end -->
      <xsl:when test="contains($text, concat($LF, $tab))">
        <!-- before the block to quote -->
        <xsl:call-template name="hierarchy">
          <xsl:with-param name="text" select="substring-before($text, concat($LF, $tab))"/>
          <xsl:with-param name="tab" select="$tab"/>
          <xsl:with-param name="level" select="$level"/>
        </xsl:call-template>
        <!-- define the name of the element -->
        <xsl:variable name="marker" select="substring(normalize-space(substring-after($text, concat($LF, $tab))), 1, 1)"/>
        <!-- get the name of the list from a normalized marker -->
        <xsl:variable name="block">
          <xsl:choose>
            <xsl:when test="$marker = '#'">ol</xsl:when>
            <xsl:when test="$marker = '*'">ul</xsl:when>
            <xsl:otherwise>blockquote</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <!-- some spaces, only to indent code -->
        <xsl:value-of select="concat($LF, substring($spaces, 1, $level * 2))"/>
        <xsl:element name="{$block}">
          <xsl:call-template name="hierarchy">
            <xsl:with-param name="text">
              <xsl:call-template name="blockquote-first">
                <!-- don't forget to restore the tab at tstart -->
                <xsl:with-param name="text" select="concat($tab, substring-after($text, concat($LF, $tab)))"/>
              </xsl:call-template>
            </xsl:with-param>
            <xsl:with-param name="tab" select="$tab"/>
            <xsl:with-param name="level" select="$level + 1"/>
          </xsl:call-template>
          <!-- some spaces, only to indent code -->
          <xsl:value-of select="concat($LF, substring($spaces, 1, $level * 2))"/>
        </xsl:element>
        <!-- after the first block to indent -->
        <xsl:call-template name="hierarchy">
          <xsl:with-param name="text">
            <xsl:call-template name="blockquote-after">
              <xsl:with-param name="tab" select="$tab"/>
              <xsl:with-param name="text" select="concat($tab, substring-after($text, concat($LF, $tab)))"/>
            <xsl:with-param name="level" select="$level"/>
            </xsl:call-template>
          </xsl:with-param>
          <xsl:with-param name="level" select="$level"/>
          <xsl:with-param name="tab" select="$tab"/>
        </xsl:call-template>
      </xsl:when>
      
      <!-- a classic break on $LF -->

      <xsl:when test="contains($text, $LF)">
        <xsl:call-template name="hierarchy">
          <xsl:with-param name="text" select="substring-before($text, $LF)"/>
          <xsl:with-param name="level" select="$level"/>
          <xsl:with-param name="tab" select="$tab"/>
        </xsl:call-template>
        <xsl:call-template name="hierarchy">
          <xsl:with-param name="text" select="substring-after($text, $LF)"/>
          <xsl:with-param name="level" select="$level"/>
          <xsl:with-param name="tab" select="$tab"/>
        </xsl:call-template>
      </xsl:when>

      <!-- where to print a line -->

      <xsl:otherwise>
          <xsl:value-of select="concat($LF, substring($spaces, 1, $level * 2))"/>
          <xsl:variable name="marker" select="substring(normalize-space($text), 1, 1)"/>
          <xsl:choose>
            <xsl:when test="$marker ='*' or $marker = '#'">
              <xsl:element name="{$item}">
                <xsl:call-template name="inlines">
                  <!-- pass to inlines without the char supposed to be list marker -->
                  <xsl:with-param name="text" select="substring(normalize-space($text), 2)"/>
                </xsl:call-template>
              </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <!-- TODO will bug on inlines between 2 lines for mails -->
                <xsl:call-template name="inlines">
                  <xsl:with-param name="text" select="$text"/>
                </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
      </xsl:otherwise>

    </xsl:choose>
  </xsl:template>
  <!--
a specific template for hierarchy
output after the fisrt block to indent
run till not <LS><TAB>
  -->
  <xsl:template name="blockquote-after">
    <xsl:param name="text"/>
    <xsl:param name="tab" select="$TAB"/>
    <xsl:choose>
      <xsl:when test="normalize-space($text)=''"/>
      <xsl:when test="starts-with($text, $tab)">
        <xsl:call-template name="blockquote-after">
          <xsl:with-param name="tab" select="$tab"/>
          <xsl:with-param name="text" select="substring-after($text, $LF)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$text"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- 
a specific template for hierarchy, 
extract the first block to quote from a tab indent string 
(this string may contains other blockquotes inside or after)

still a bit magic code 
-->  
  <xsl:template name="blockquote-first">
    <xsl:param name="text"/>
    <xsl:choose>
      <xsl:when test="normalize-space($text)=''"/>
      <xsl:when test="not(starts-with($text, $TAB))">
        <xsl:call-template name="blockquote-first">
          <xsl:with-param name="text" select="concat($TAB, substring-after($text, concat($LF, $TAB)))"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="contains($text, $LF)">
        <xsl:call-template name="blockquote-first">
          <xsl:with-param name="text" select="substring-before($text, $LF)"/>
        </xsl:call-template>
        <xsl:if test="starts-with(substring-after($text, $LF), $TAB)">
          <xsl:call-template name="blockquote-first">
            <xsl:with-param name="text" select="substring-after($text, $LF)"/>
          </xsl:call-template>
        </xsl:if>
      </xsl:when>
      <xsl:when test="starts-with($text, $TAB)">
        <xsl:value-of select="substring-after($text, $TAB)"/>
        <xsl:value-of select="$LF"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$text"/>
        <xsl:value-of select="$LF"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!--
normalize mails 
Should let a displayable preformatted text, 
but easier to parse.
 
 1) replace encoded chars
 2) normalize '>' by tabs (problems of escaping with &gt;)
 -->
  <xsl:template name="mail-norm">
    <xsl:param name="text"/>
    <xsl:call-template name="indent-norm">
      <xsl:with-param name="text">
        <xsl:call-template name="decode">
          <xsl:with-param name="text" select="$text"/>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!--

This template normalize a string for lists where markers are replaced by tab

LF TAB TAB Space ..........what you want without TAB or LF


  -->
  <xsl:template name="indent-norm">
    <xsl:param name="text"/>
    <xsl:choose>
      <xsl:when test="normalize-space($text) = ''"/>
      <!-- should split all lines -->
      <xsl:when test="contains($text, $LF)">
        <xsl:call-template name="indent-norm">
          <xsl:with-param name="text" select="substring-before($text, $LF)"/>
        </xsl:call-template>
        <xsl:call-template name="indent-norm">
          <xsl:with-param name="text" select="substring-after($text, $LF)"/>
        </xsl:call-template>
      </xsl:when>
      <!-- strip empty lines ? -->
      <xsl:when test="normalize-space(translate($text, '.)*#o-&gt;', '')) = '' "/>
      <!-- here should work on a line -->
      <xsl:otherwise>
        <xsl:variable name="prefix">
          <xsl:choose>
            <xsl:when test="contains(normalize-space($text), ' ')">
              <xsl:value-of select="substring-before(normalize-space($text), ' ')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="normalize-space($text)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <!-- 
case of lines with no markers, no indent 
for example, level0 mail
-->
          <xsl:when test="
    translate($prefix, '0123456789.)*#o-&gt;', '') != ''
and (starts-with($text, $prefix))
          ">
            <xsl:value-of select="$LF"/>
            <xsl:value-of select="$text"/>
          </xsl:when>
          <!-- 
here, try to add good content to last started line reasons could be
multiple line item in lists (no marker in prefix but indent)

but this is not 
so no LF, add to the last line started
-->
          <xsl:when test="
    translate($prefix, '0123456789.)*#o-&gt;', '') != '' 
    ">
            <xsl:value-of select="' '"/>
            <xsl:value-of select="normalize-space($text)"/>
          </xsl:when>
          <xsl:otherwise>
            <!-- let LF for now -->
            <xsl:value-of select="$LF"/>
            <!-- normalize prefix with tabs  -->
            <xsl:value-of select="
    translate (
        translate($prefix, '01234567890', '')
      , '.#)o-*&gt;'
      , concat($TAB, $TAB, $TAB, $TAB, $TAB, $TAB, $TAB)
    )          
"/>
            <!-- give here a normalized char for marker -->
            <xsl:variable name="markers" select="
translate (
    translate (
        translate($prefix, '01234567890&gt;', '')
      , '.#)'
      , '###'
    )          
  , 'o-*'
  ,  '***'
)"/>
            <xsl:value-of select="substring($markers, 1, 1)"/>
            <!-- don't forget to normalize content, to clean tabs -->
            <xsl:value-of select="normalize-space(substring-after($text, $prefix))"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
<!--
normalize fields
-->
  <xsl:template name="fields-norm">
    <xsl:param name="text"/>
    <xsl:variable name="field" select="normalize-space(substring-before($text, ':'))"/>
    <xsl:choose>
      <xsl:when test="normalize-space($text) = ''"/>
      <!-- should split all lines -->
      <xsl:when test="contains($text, $LF)">
        <xsl:call-template name="fields-norm">
          <xsl:with-param name="text" select="substring-before($text, $LF)"/>
        </xsl:call-template>
        <xsl:call-template name="fields-norm">
          <xsl:with-param name="text" select="substring-after($text, $LF)"/>
        </xsl:call-template>
      </xsl:when>
      <!-- may be problems if ':' in the value ? -->
      <xsl:when test="$field != ''">
        <xsl:value-of select="$LF"/>
        <xsl:value-of select="$field"/>
        <xsl:text>:</xsl:text>
        <xsl:value-of select="normalize-space(substring-after($text, ':'))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="' '"/>
        <xsl:value-of select="normalize-space($text)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
<!--
present fields as a table
-->
  <xsl:template name="fields-rows">
    <xsl:param name="text"/>
    <xsl:choose>
      <xsl:when test="normalize-space($text)=''"/>
      <!-- split all lines -->
      <xsl:when test="contains($text, $LF)">
          <xsl:call-template name="fields-rows">
            <xsl:with-param name="text" select="substring-before($text, $LF)"/>
          </xsl:call-template>
        <xsl:call-template name="fields-rows">
          <xsl:with-param name="text" select="substring-after($text, $LF)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <tr>
          <th>
            <xsl:value-of select="substring-before($text, ':')"/>
          </th>
          <td>
            <xsl:call-template name="decode">
              <xsl:with-param name="text">
                <xsl:value-of select="substring-after($text, ':')"/>
              </xsl:with-param>
            </xsl:call-template>
          </td>
        </tr>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- TODO find inlines  -->
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
            <xsl:when test="contains($text, $LF)">
              <xsl:value-of select="normalize-space(substring-before($text, $LF))"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="normalize-space($text)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="concat($LF, '  ')"/>
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
        <xsl:if test="contains($text, $LF)">
          <xsl:call-template name="dl">
            <xsl:with-param name="text" select="substring-after($text, $LF)"/>
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
        <xsl:value-of select="concat($LF, '  ')"/>
        <dd>
          <xsl:call-template name="inlines">
            <xsl:with-param name="text" select="$definition"/>
          </xsl:call-template>
        </dd>
        <xsl:value-of select="$LF"/>
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
      <xsl:when test="contains($text, $LF)">
        <xsl:value-of select="substring-before($text, $LF)"/>
        <xsl:value-of select="$LF"/>
        <xsl:call-template name="text-align">
          <xsl:with-param name="text" select="substring-after($text, $LF)"/>
        </xsl:call-template>
      </xsl:when>
      <!-- should be last line -->
      <xsl:otherwise>
        <xsl:value-of select="$text"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!--
a not too less efficient multiple search/replace
pass a string like "find:replace, search:change ..."
if you want to search/replace ':' or ',', do a "translate()" before using this pattern

thanks to jeni@jenitennison.com for its really clever recursive template
http://www.biglist.com/lists/xsl-list/archives/200110/msg01229.html
But is replacing nodeset by functions a good XSL practice ?
String functions seems more useful.

TOTEST &#xA;:<br/> (may work with a <xsl:param select="//br"/>)


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
    <!-- current simple string to find, no tests about valid pattern -->
    <xsl:param name="find" select="substring-before($pattern, ':')"/>
    <!-- current simple string to replace, no tests about valid pattern -->
    <xsl:param name="replace">
      <xsl:choose>
        <xsl:when test="contains($pattern, ',')">
          <xsl:value-of select="substring-after(substring-before($pattern, ','), ':')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="substring-after($pattern, ':')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <xsl:choose>
      <!-- perhaps unuseful, I don't know -->
      <xsl:when test="$text=''"/>
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
          <xsl:with-param name="find" select="$find"/>
          <xsl:with-param name="replace" select="$replace"/>
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
  <!--
  A template to decode 
-->
  <xsl:variable name="hex" select="'0123456789ABCDEF'"/>
  <xsl:variable name="ascii"> !"#$%&amp;'()*+,-./0123456789:;&lt;=&gt;?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~</xsl:variable>
  <xsl:variable name="latin1">&#160;&#161;&#162;&#163;&#164;&#165;&#166;&#167;&#168;&#169;&#170;&#171;&#172;&#173;&#174;&#175;&#176;&#177;&#178;&#179;&#180;&#181;&#182;&#183;&#184;&#185;&#186;&#187;&#188;&#189;&#190;&#191;&#192;&#193;&#194;&#195;&#196;&#197;&#198;&#199;&#200;&#201;&#202;&#203;&#204;&#205;&#206;&#207;&#208;&#209;&#210;&#211;&#212;&#213;&#214;&#215;&#216;&#217;&#218;&#219;&#220;&#221;&#222;&#223;&#224;&#225;&#226;&#227;&#228;&#229;&#230;&#231;&#232;&#233;&#234;&#235;&#236;&#237;&#238;&#239;&#240;&#241;&#242;&#243;&#244;&#245;&#246;&#247;&#248;&#249;&#250;&#251;&#252;&#253;&#254;&#255;</xsl:variable>
  <xsl:template name="decode">
    <xsl:param name="text"/>
    <xsl:param name="marker" select="'='"/>
    <xsl:choose>
      <xsl:when test="contains($text,$marker)">
        <!-- before the marker -->
        <xsl:value-of select="substring-before($text,$marker)"/>
        <!-- the supposed hex code -->
        <xsl:variable name="code" select="substring(substring-after($text,$marker),1,2)"/>
        <xsl:variable name="hexpair" select="translate($code,'abcdef','ABCDEF')"/>
        <xsl:variable name="decimal" select="(string-length(substring-before($hex,substring($hexpair,1,1))))*16 + string-length(substring-before($hex,substring($hexpair,2,1)))"/>
        <!-- find the supposed char -->
        <xsl:variable name="char">
          <xsl:choose>
            <xsl:when test="$decimal &lt; 127 and $decimal &gt; 31">
              <xsl:value-of select="substring($ascii,$decimal - 31,1)"/>
            </xsl:when>
            <xsl:when test="$decimal &gt; 159">
              <xsl:value-of select="substring($latin1,$decimal - 159,1)"/>
            </xsl:when>
            <xsl:otherwise>??</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <!-- insert (or not) the char -->
        <xsl:choose>
          <!-- something found in french mail headers -->
          <xsl:when test="starts-with(substring-after($text,$marker), '?ISO-8859-1?Q?')">
            <xsl:call-template name="decode">
              <xsl:with-param name="text" select="substring-after(substring-after($text,$marker),'?ISO-8859-1?Q?')"/>
            </xsl:call-template>
          </xsl:when>
          <!-- this is not hex, do nothing -->
          <xsl:when test="$char='??' or translate($code, '0123456789abcdefABCDEFG', '') != ''">
            <xsl:value-of select="$marker"/>
            <xsl:call-template name="decode">
              <xsl:with-param name="text" select="substring-after($text,$marker)"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$char"/>
            <xsl:call-template name="decode">
              <xsl:with-param name="text" select="substring(substring-after($text,$marker),3)"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$text"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  
</xsl:stylesheet>
