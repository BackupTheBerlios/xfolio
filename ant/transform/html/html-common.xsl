<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="xsl2html.xsl"?>
<?js html.js?>
<!--
Copyright : 2004, "ADNX" <http://adnx.org>
Licence   : "GPL" <http://www.fsf.org/copyleft/gpl.html>
Creator   : [FG] "Frédéric Glorieux" <frederic.glorieux@ajlsm.com>

  = WHAT =

Different templates maybe useful when generating html
This sheet have to been imported to take advantage.



-->
<xsl:transform 
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:html="http://www.w3.org/1999/xhtml"
version="1.0" xmlns="http://www.w3.org/1999/xhtml">
    <!-- avoid indent for xhtml (some layout) -->
    <xsl:output method="xml" indent="no" omit-xml-declaration="yes" encoding="UTF-8"/>
    <!-- load the XSL only one time -->
    <xsl:param name="document" select="document('')"/>
    <!-- encoding, default is the one specified in xsl:output -->
    <xsl:param name="encoding">
      <xsl:choose>
        <xsl:when test="$document/*/xsl:output/@encoding">
          <xsl:value-of select="$document/*/xsl:output/@encoding"/>
        </xsl:when>
        <xsl:otherwise>UTF-8</xsl:otherwise>
      </xsl:choose>
    </xsl:param>
  <!-- 
provide a link to a css file, 
maybe overrided by the caller
or a processing-instruction in the source like this

  -->
  <xsl:param name="css">
    <xsl:choose>
      <xsl:when test="processing-instruction('css')">
        <xsl:value-of select="processing-instruction('css')"/>
      </xsl:when>
      <xsl:otherwise>../html/html.css</xsl:otherwise>
    </xsl:choose>
  </xsl:param>
  <!-- 
same logic as css for a js file, but without default value
  -->
  <xsl:param name="js">
    <xsl:choose>
      <xsl:when test="processing-instruction('js')">
        <xsl:value-of select="processing-instruction('js')"/>
      </xsl:when>
      <!-- no default value ! -->
    </xsl:choose>
  </xsl:param>
  <!--
Different useful declarations for head in an html doc
-->
  <xsl:template name="html-metas">
    <!-- encoding declaration from output of the xsl -->
    <meta http-equiv="Content-type">
      <xsl:attribute name="content">
        <xsl:text>text/html; charset=</xsl:text>
        <xsl:value-of select="$encoding"/>
      </xsl:attribute>
    </meta>
    <xsl:if test="normalize-space($css) != ''">
      <link rel="stylesheet">
        <xsl:attribute name="href">
        <!-- 
could be interesting in some contexts when you have only absolute paths
rely on a namin.xsl
          <xsl:call-template name="getRelative">
            <xsl:with-param name="from" select="$path"/>
            <xsl:with-param name="to" select="$css"/>
          </xsl:call-template>
        -->
          <xsl:value-of select="$css"/>
        </xsl:attribute>
      </link>
    </xsl:if>
    <xsl:if test="normalize-space($js) != ''">
      <script type="text/javascript">
        <xsl:attribute name="src">
        <!-- 
could be interesting in some contexts when you have only absolute paths
rely on a naming.xsl
          <xsl:call-template name="getRelative">
            <xsl:with-param name="from" select="$path"/>
            <xsl:with-param name="to" select="$css"/>
          </xsl:call-template>
        -->
          <xsl:value-of select="$js"/>
        </xsl:attribute> 
          <!-- don't let the script tag empty, may bug in some browsers -->
        &#160;
      </script>
    </xsl:if>
  </xsl:template>
  <!-- template for link resolution -->
  <xsl:template name="href">
    <xsl:param name="uri"/>
    <xsl:choose>
      <!-- hide mails -->
      <xsl:when test="contains($uri, '@')">
        <xsl:attribute name="href">
        </xsl:attribute>
        <xsl:attribute name="onclick">
          <xsl:text>this.href='mailto:</xsl:text>
          <xsl:value-of select="substring-before($uri, '@')"/>
          <xsl:text>'+'\x40'+'</xsl:text>
          <xsl:value-of select="substring-after($uri, '@')"/>
          <xsl:text>'</xsl:text>
        </xsl:attribute>
      </xsl:when>
      <xsl:otherwise>
          <xsl:attribute name="href">
            <xsl:value-of select="$uri"/>
          </xsl:attribute>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


</xsl:transform>