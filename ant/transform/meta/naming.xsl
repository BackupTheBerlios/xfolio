<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="../html/xsl2html.xsl"?>
<!--
modified:2004-11-17
creation:2004-01-27
author:frederic.glorieux@ajlsm.com
publisher:ADNX <http://adnx.org>
goal:
  centralize naming policy of files to be shared by RDF ans RSS

-->
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:dcterms="http://purl.org/dc/terms/" exclude-result-prefixes="">
  <xsl:variable name="mimes" select="document('mimes.xml')"/>
  <!-- list of space separated of file extensions 
from which generate dcterms:hasFormat declarations -->
  <xsl:param name="formats"/>
  <!--
from 2 path, http://, or /


TODO wash port :
-->
  <xsl:template name="getRelative">
    <xsl:param name="from"/>
    <xsl:param name="to"/>
    <!-- loop only if start is common -->
    <xsl:choose>
      <!-- windows filepath -->
      <xsl:when test="contains($from, '\') or contains($to, '\')">
        <xsl:call-template name="getRelative">
          <xsl:with-param name="from" select="translate($from, '\', '/')"/>
          <xsl:with-param name="to" select="translate($to, '\', '/')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="starts-with($from, '/') and starts-with($to, '/')">
        <xsl:call-template name="getRelative_">
          <xsl:with-param name="from" select="substring-after($from, '/')"/>
          <xsl:with-param name="to" select="substring-after($to, '/')"/>
        </xsl:call-template>
      </xsl:when>
      <!-- same domain (will bug on file:///) -->
      <xsl:when test="
contains($from, '//') and contains($to, '//')
and
substring-before( substring-after($from, '//'), '/')
= substring-before( substring-after($to, '//'), '/')
">
        <xsl:call-template name="getRelative_">
          <xsl:with-param name="from" select="substring-after($from, '//')"/>
          <xsl:with-param name="to" select="substring-after($to, '//')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$to"/>
      </xsl:otherwise>
    </xsl:choose>
    <!--
    <xsl:choose>
    <xsl:when test="not(contains($from, 'http://') and contains($to, 'http://'))">
      <xsl:value-of select="$to"/>
    </xsl:when>
    <xsl:when test="contains($from, ':80/') or contains($to, ':80/')">
        <xsl:call-template name="getRelative">
          <xsl:with-param name="from">
            <xsl:choose>
              <xsl:when test="contains($from, ':80/')">
                 <xsl:value-of select="substring-before($from, ':80/')"/>
                 <xsl:text>/</xsl:text>
                 <xsl:value-of select="substring-after($from, ':80/')"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$from"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:with-param>
          <xsl:with-param name="to">
            <xsl:choose>
              <xsl:when test="contains($to, ':80/')">
                 <xsl:value-of select="substring-before($to, ':80/')"/>
                 <xsl:text>/</xsl:text>
                 <xsl:value-of select="substring-after($to, ':80/')"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$to"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:with-param>
        </xsl:call-template>
    </xsl:when>
    <xsl:when test="contains($from, '//www.') or contains($to, '//www.')">
        <xsl:call-template name="getRelative">
          <xsl:with-param name="from">
            <xsl:choose>
              <xsl:when test="contains($from, '//www.')">
                 <xsl:value-of select="substring-before($from, '//www.')"/>
                 <xsl:text>//</xsl:text>
                 <xsl:value-of select="substring-after($from, '//www.')"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$from"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:with-param>
          <xsl:with-param name="to">
            <xsl:choose>
              <xsl:when test="contains($to, '//www.')">
                 <xsl:value-of select="substring-before($to, '//www.')"/>
                 <xsl:text>//</xsl:text>
                 <xsl:value-of select="substring-after($to, '//www.')"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$to"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:with-param>
        </xsl:call-template>
    </xsl:when>
    </xsl:choose>
-->
  </xsl:template>
  <!-- loop on clean -->
  <xsl:template name="getRelative_">
    <xsl:param name="from"/>
    <xsl:param name="to"/>
    <xsl:param name="max" select="20"/>
    <xsl:choose>
      <xsl:when test="$max = 0"/>
      <xsl:when test="
contains($from, '/') and  contains($to, '/') and
 substring-before($from, '/') = substring-before($to, '/')">
        <xsl:call-template name="getRelative_">
          <xsl:with-param name="max" select="$max - 1"/>
          <xsl:with-param name="from" select="substring-after($from, '/')"/>
          <xsl:with-param name="to" select="substring-after($to, '/')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="substring(
'../../../../../../../../../../../../../../',
1,
3 * (string-length($from) - string-length( translate($from, '/', '')))
)"/>
        <xsl:value-of select="$to"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!--
  Not sure it works under xalan

-->
  <xsl:template name="getRadical">
    <xsl:param name="path"/>
    <xsl:variable name="name">
      <xsl:call-template name="getName">
        <xsl:with-param name="path" select="$path"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="lang">
      <xsl:call-template name="getLang">
        <xsl:with-param name="path" select="$name"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$lang != ''">
        <xsl:value-of select="substring-before($name, concat('_', $lang))"/>
      </xsl:when>
      <!-- underscore names ? -->
      <xsl:when test="contains($name, '_')">
        <xsl:value-of select="substring-before($name, '_')"/>
      </xsl:when>
      <xsl:when test="contains($name, '.')">
        <xsl:value-of select="substring-before($name, '.')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="normalize-space($name)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!--
name policy of languages

support only filenames in form {radical}_{lang}(_{country}?).{extension}
        not completely perfect

        -->
  <xsl:template name="getLang">
    <xsl:param name="path"/>
    <xsl:choose>
      <!-- windows filepath -->
      <xsl:when test="contains($path, '\')">
        <xsl:call-template name="getLang">
          <xsl:with-param name="path" select="translate($path, '\', '/')"/>
        </xsl:call-template>
      </xsl:when>
      <!-- no lang -->
      <xsl:when test="not(contains($path, '_'))"/>
      <!-- case of a directory, break here -->
      <xsl:when test="contains($path, '/') and normalize-space(substring-after($path, '/')) =''"/>
      <!-- not the end of the path, continue -->
      <xsl:when test="contains($path, '/')">
        <xsl:call-template name="getLang">
          <xsl:with-param name="path" select="substring-after($path, '/')"/>
        </xsl:call-template>
      </xsl:when>
      <!-- more than one '_' -->
      <xsl:when test="contains(substring-after($path, '_'), '_')">
        <xsl:call-template name="getLang">
          <xsl:with-param name="path" select="substring-after($path, '_')"/>
        </xsl:call-template>
      </xsl:when>
      <!-- a dot after last underscore should be extension -->
      <xsl:when test="contains($path, '.')">
        <xsl:call-template name="getLang">
          <xsl:with-param name="path" select="substring-before($path, '.')"/>
        </xsl:call-template>
      </xsl:when>
      <!-- should be something like that
_(lang)?(-country)?
 -->
      <!-- a test could be added on the list of languages -->
      <xsl:otherwise>
        <xsl:value-of select="substring-after($path, '_')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!--
give a file name in a path

Bug in xalan ?
-->
  <xsl:template name="getName">
    <xsl:param name="path" select="'no name'"/>
    <xsl:choose>
      <!-- windows filepath -->
      <xsl:when test="contains($path, '\')">
        <xsl:call-template name="getName">
          <xsl:with-param name="path" select="translate($path, '\', '/')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="contains($path, '/') = false()">
        <xsl:value-of select="$path"/>
      </xsl:when>
      <!-- case of a directory -->
      <xsl:when test="normalize-space(substring-after($path, '/')) =''">
        <xsl:value-of select="substring-before($path, '/')"/>
      </xsl:when>
      <xsl:when test="substring-after($path, '/') != ''">
        <xsl:call-template name="getName">
          <xsl:with-param name="path" select="substring-after($path, '/')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:template>
  <!-- give parent of a path -->
  <xsl:template name="getParent">
    <xsl:param name="path"/>
    <xsl:choose>
      <!-- windows filepath -->
      <xsl:when test="contains($path, '\')">
        <xsl:call-template name="getParent">
          <xsl:with-param name="path" select="translate($path, '\', '/')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="contains($path, '/') and substring-after($path, '/')!=''">
        <xsl:value-of select="substring-before($path, '/')"/>
        <xsl:text>/</xsl:text>
        <xsl:call-template name="getParent">
          <xsl:with-param name="path" select="substring-after($path, '/')"/>
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <!--

give a mime type from a path
need the extension logic

-->
  <xsl:template name="getMime">
    <xsl:param name="path"/>
    <!-- Careful on logic "*.sxw.xml" of GetExtension template -->
    <xsl:variable name="extension">
      <xsl:call-template name="getExtension">
        <xsl:with-param name="path" select="$path"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <!-- direct extension ? -->
      <xsl:when test="not (contains($path, '/') or contains($path, '\') or contains($path, '.') or string-length($path) &gt; 4)">
        <xsl:value-of select="$mimes/*/*[@extension=$path]/@mime-type"/>
      </xsl:when>
      <!-- if last char is '/', probably a directory, break here -->
      <xsl:when test="substring(normalize-space($path), string-length(normalize-space($path))) ='/'">application/directory</xsl:when>
      <!-- extension seems to contain a dot '.' -->
      <xsl:when test="contains($extension, '.')">
        <xsl:value-of select="$mimes/*/*[@extension=substring-after($extension, '.')]/@mime-type"/>
      </xsl:when>
      <!-- extension seems correct -->
      <xsl:otherwise>
        <xsl:value-of select="$mimes/*/*[@extension=$extension]/@mime-type"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!--

get extension from a path

because of passing params from call-template on some parsers,
this code have to be copy/paste for get mime
        -->
  <xsl:template name="getExtension">
    <xsl:param name="path"/>
    <xsl:choose>
      <!-- windows filepath -->
      <xsl:when test="contains($path, '\')">
        <xsl:call-template name="getExtension">
          <xsl:with-param name="path" select="translate($path, '\', '/')"/>
        </xsl:call-template>
      </xsl:when>
      <!-- anchor -->
      <xsl:when test="contains($path, '#')">
        <xsl:call-template name="getExtension">
          <xsl:with-param name="path" select="substring-before($path, '#')"/>
        </xsl:call-template>
      </xsl:when>
      <!-- query -->
      <xsl:when test="contains($path, '?')">
        <xsl:call-template name="getExtension">
          <xsl:with-param name="path" select="substring-before($path, '?')"/>
        </xsl:call-template>
      </xsl:when>
      <!-- case of a directory, break here -->
      <xsl:when test="contains($path, '/') and normalize-space(substring-after($path, '/')) =''"/>
      <!-- not the end of the path -->
      <xsl:when test="contains($path, '/')">
        <xsl:call-template name="getExtension">
          <xsl:with-param name="path" select="substring-after($path, '/')"/>
        </xsl:call-template>
      </xsl:when>
      <!-- no dot, break here -->
      <xsl:when test="not(contains($path, '.'))"/>
      <!-- hidden file -->
      <xsl:when test="starts-with($path, '.')">
        <xsl:call-template name="getExtension">
          <xsl:with-param name="path" select="substring-after($path, '.')"/>
        </xsl:call-template>
      </xsl:when>
      <!-- more than one dot, maybe something in form .sxw.xml ? -->
      <xsl:when test="contains(substring-after($path, '.'), '.')">
        <xsl:value-of select="''"/>
        <xsl:choose>
          <!-- letters between dots is a registred extension -->
          <xsl:when test="$mimes/*/key[@extension=substring-before(substring-after($path, '.'), '.')]">
            <xsl:value-of select="substring-after($path, '.')"/>
          </xsl:when>
          <!-- probably a name coucou.beuh.extension -->
          <xsl:otherwise>
            <xsl:call-template name="getExtension">
              <xsl:with-param name="path" select="substring-after($path, '.')"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <!-- should be an extension -->
      <xsl:otherwise>
        <xsl:value-of select="substring-after($path, '.')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
<!--
A basename is a filename without extension
-->
  <xsl:template name="getBasename">
    <xsl:param name="path"/>
    <xsl:choose>
      <!-- windows filepath -->
      <xsl:when test="contains($path, '\')">
        <xsl:call-template name="getBasename">
          <xsl:with-param name="path" select="translate($path, '\', '/')"/>
        </xsl:call-template>
      </xsl:when>
      <!-- case of a directory, break here -->
      <xsl:when test="contains($path, '/') and normalize-space(substring-after($path, '/')) =''"/>
      <!-- not the end of the path -->
      <xsl:when test="contains($path, '/')">
        <xsl:call-template name="getBasename">
          <xsl:with-param name="path" select="substring-after($path, '/')"/>
        </xsl:call-template>
      </xsl:when>
      <!-- no dot, break here -->
      <xsl:when test="not(contains($path, '.'))">
        <xsl:value-of select="$path"/>
      </xsl:when>
      <!-- hidden file -->
      <xsl:when test="starts-with($path, '.')">
        <xsl:value-of select="$path"/>
      </xsl:when>
      <!-- more than one dot, let it ? -->
      <xsl:when test="contains(substring-after($path, '.'), '.')">
        <xsl:value-of select="$path"/>
      </xsl:when>
      <!-- should be a basename -->
      <xsl:otherwise>
        <xsl:value-of select="substring-before($path, '.')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
<!--
A basepath is a path without extension
-->
  <xsl:template name="getBasepath">
    <xsl:param name="path"/>
    <xsl:choose>
      <!-- windows filepath -->
      <xsl:when test="contains($path, '\')">
        <xsl:call-template name="getBasepath">
          <xsl:with-param name="path" select="translate($path, '\', '/')"/>
        </xsl:call-template>
      </xsl:when>
      <!-- not the end of the path, output first branch and continue -->
      <xsl:when test="contains($path, '/')">
        <xsl:value-of select="substring-before($path, '/')"/>
        <xsl:text>/</xsl:text>
        <xsl:call-template name="getBasepath">
          <xsl:with-param name="path" select="substring-after($path, '/')"/>
        </xsl:call-template>
      </xsl:when>
      <!-- no dot, break here -->
      <xsl:when test="not(contains($path, '.'))">
        <xsl:value-of select="$path"/>
      </xsl:when>
      <!-- hidden file, break here -->
      <xsl:when test="starts-with($path, '.')">
        <xsl:value-of select="$path"/>
      </xsl:when>
      <!-- more than one dot, maybe things like .sxw.xml, but cant do something for coucou.beuh.txt -->
      <xsl:when test="contains(substring-after($path, '.'), '.')">
        <xsl:value-of select="substring-before($path, '.')"/>
      </xsl:when>
      <!-- should be a basename -->
      <xsl:otherwise>
        <xsl:value-of select="substring-before($path, '.')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
    <!--

From a param provide by server of other supported export formats,
<dcterms:hasFormat/> elements are generated
-->
  <xsl:template name="hasFormat">
    <!-- normalize extensions to have always a substring-before ' ' -->
    <xsl:param name="formats" select="concat(normalize-space($formats), ' ')"/>
    <!-- supposed path of the source file -->
    <xsl:param name="path" select="$path"/>
    <!-- -->
    <xsl:choose>
      <!-- no extensions, break here -->
      <xsl:when test="normalize-space($formats) =''"/>
      <!-- more than one extension -->
      <xsl:otherwise>
        <xsl:variable name="extension" select="substring-before($formats, ' ')"/>
        <xsl:variable name="mime">
          <xsl:call-template name="getMime">
            <xsl:with-param name="path" select="$extension"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="name">
          <xsl:call-template name="getName">
            <xsl:with-param name="path" select="$path"/>
          </xsl:call-template>
        </xsl:variable>
        <dcterms:hasFormat dc:format="{$mime}" rdf:resource="{$name}.{$extension}">
          <!-- what should I do ther ?
          <xsl:call-template name="lang"/>
            -->
          <!-- relation maybe relative to identifier ? -->
          <xsl:value-of select="$path"/>
          <xsl:text>.</xsl:text>
          <xsl:value-of select="$extension"/>
        </dcterms:hasFormat>
        <xsl:call-template name="hasFormat">
          <xsl:with-param name="formats" select="substring-after($formats, ' ')"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:transform>
