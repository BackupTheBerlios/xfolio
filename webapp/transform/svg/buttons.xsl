<?xml version="1.0" encoding="UTF-8"?>
<!--

	creation:
		2002
	modified:
		2004-04-05
	creator:
		frederic.glorieux@ajlsm.com
	goal:
		Try to find a generic way to produce SVG buttons from a single SVG origin
	usage:
		May be be use as a splitter with saxon7 or as a pipe in cocoon
	history:
		The original xsl was a test never used
		Will be now part of XFolio
  rights :
    (c)ajlsm.com
    http://www.gnu.org/copyleft/gpl.html
  TODO:
    The splitter have not be tested for months.
	  Isolate a separate split xsl template tested with different processors.
-->
<xsl:stylesheet version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:svg="http://www.w3.org/2000/svg">
  <xsl:output indent="no" method="xml"/>
  <!-- -->
  <xsl:param name="mode" select="'split'"/>
  <!-- symbol@id of the button -->
  <xsl:param name="symbol"/>
  <!-- change class of the button (over, etc) -->
  <xsl:param name="class"/>
  <!-- folder where to find the CSS for all buttons (depends on URI policy upper) -->
  <xsl:param name="skin"/>
  <!-- size of button -->
  <xsl:param name="size" select="25"/>
  <!--   -->
  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="$mode='index'">
        <html>
          <head>
            <title>Buttons</title>
          </head>
          <body>
            <h1>Buttons</h1>
            <xsl:for-each select="/svg:svg/svg:defs/svg:symbol">
              <img onload="id='{@id}';var imgover=new Image(); imgover.src= id + '-over.png';var imgclick=new Image(); imgclick.src= id + '-click.png';" style="cursor:pointer" src="{@id}.png" onmouseover="this.src='{@id}-over.png'" onmouseout="this.src='{@id}.png'" onmousedown="this.src='{@id}-click.png'"/>
            </xsl:for-each>
          </body>
        </html>
      </xsl:when>
      <!-- use in split mode -->
      <xsl:when test="$mode='split'">
        <!--
				<xsl:document href="index.html">
					<html>
						<head/>
						<body>
							<h1>buttons</h1>
							<xsl:apply-templates select="//symbol"/>
						</body>
					</html>
				</xsl:document>
				-->
        <html>
          <head/>
          <body>Processus terminé
            </body>
        </html>
      </xsl:when>
      <!-- output a single SVG button -->
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!--
	
	templates for split
	-->
  <!--
		<xsl:document href="{@id}.svg">
			<svg width="20" height="20" viewBox="0 0 120 120" xmlns:xlink="http://www.w3.org/1999/xlink">
				<defs>
					<xsl:copy-of select="."/>
					<xsl:copy-of select="/svg/defs/filter[@id='bump']"/>
					<xsl:copy-of select="/svg/defs/filter[@id='inset']"/>
					<xsl:copy-of select="/svg/defs/filter[@id='ridge']"/>
				</defs>
				<rect fill="Beige" x="10" y="10" width="100" height="100" rx="10" ry="20" stroke-linecap="round" stroke-linejoin="round" stroke="none" filter="url(#bump)"/>
				<rect filter="url(#ridge)" stroke="green" fill="none" stroke-width="4" x="10" y="10" width="100" height="100" rx="10" ry="20" stroke-linecap="round" stroke-linejoin="round"/>
				<use fill="black" xlink:href="#{@id}" x="25" y="25" width="70" height="70" filter="url(#inset)"/>
			</svg>
		</xsl:document>
		<xsl:document href="{@id}1.svg">
			<svg width="20" height="20" viewBox="0 0 120 120" xmlns:xlink="http://www.w3.org/1999/xlink">
				<defs>
					<xsl:copy-of select="."/>
					<xsl:copy-of select="/svg/defs/filter[@id='bump']"/>
					<xsl:copy-of select="/svg/defs/filter[@id='inset']"/>
					<xsl:copy-of select="/svg/defs/filter[@id='ridge']"/>
				</defs>
				<rect fill="beige" x="10" y="10" width="100" height="100" rx="10" ry="20" stroke-linecap="round" stroke-linejoin="round" stroke="none" filter="url(#bump)"/>
				<rect filter="url(#ridge)" stroke="red" fill="none" stroke-width="4" x="10" y="10" width="100" height="100" rx="10" ry="20" stroke-linecap="round" stroke-linejoin="round"/>
				<use fill="red" xlink:href="#{@id}" x="25" y="25" width="70" height="70" filter="url(#inset)"/>
			</svg>
		</xsl:document>
		<xsl:document href="{@id}2.svg">
			<svg width="20" height="20" viewBox="0 0 120 120" xmlns:xlink="http://www.w3.org/1999/xlink">
				<defs>
					<xsl:copy-of select="."/>
					<xsl:copy-of select="/svg/defs/filter[@id='bump']"/>
					<xsl:copy-of select="/svg/defs/filter[@id='inset']"/>
					<xsl:copy-of select="/svg/defs/filter[@id='ridge']"/>
				</defs>
				<rect fill="red" x="10" y="10" width="100" height="100" rx="10" ry="20" stroke-linecap="round" stroke-linejoin="round" stroke="none" filter="url(#bump)"/>
				<use fill="white" xlink:href="#{@id}" x="25" y="25" width="70" height="70" filter="url(#inset)"/>
				<rect filter="url(#ridge)" stroke="green" fill="none" stroke-width="4" x="10" y="10" width="100" height="100" rx="10" ry="20" stroke-linecap="round" stroke-linejoin="round"/>
			</svg>
		</xsl:document>
-->
  <!--
   change the symbol to display in a style group
-->
  <xsl:template match="svg:use[@class='symbol']/@xlink:href">
    <xsl:attribute name="xlink:href">
      <xsl:value-of select="concat('#', $symbol)"/>
    </xsl:attribute>
  </xsl:template>
  <!--
change class of the button
-->
  <xsl:template match="/svg:svg/svg:g">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="class">
        <xsl:value-of select="$class"/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  <!--
strip unuseful symbols
-->
  <xsl:template match="svg:defs//svg:symbol">
    <xsl:choose>
      <xsl:when test="$symbol != '' and @id !='' and $symbol != @id"/>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- set global size, better should be by CSS 	-->
  <xsl:template match="/svg:svg">
    <xsl:comment>
symbol=<xsl:value-of select="$symbol"/>    
class=<xsl:value-of select="$class"/>    
skin=<xsl:value-of select="$skin"/>    
size=<xsl:value-of select="$size"/>    
    </xsl:comment>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="width">
        <xsl:choose>
          <xsl:when test="number($size)">
            <xsl:value-of select="$size"/>
          </xsl:when>
          <xsl:otherwise>25</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:attribute name="height">
        <xsl:choose>
          <xsl:when test="number($size)">
            <xsl:value-of select="$size"/>
          </xsl:when>
          <xsl:otherwise>25</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  <!--
  if there's a CSS link, rewrite it with a prefix
<?xml-stylesheet type="text/css" href="buttons.css" ?>
  -->
  <xsl:template match="processing-instruction('xml-stylesheet')">
    <xsl:processing-instruction name="xml-stylesheet">
      <xsl:text>type="text/css" href="</xsl:text>
      <xsl:value-of select="$skin"/>
      <xsl:value-of select="substring-before( substring-after(., 'href=&quot;'), '&quot;')"/>
      <xsl:text>"</xsl:text>
    </xsl:processing-instruction>
  </xsl:template>
  <!--
  strip comments ?
  -->
  <xsl:template match="comment()"/>
  <xsl:template match="text()[normalize-space(.)='']"/>
  <!--
Default, copy all from SVG source
-->
  <xsl:template match="@*|node()" priority="-1">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
