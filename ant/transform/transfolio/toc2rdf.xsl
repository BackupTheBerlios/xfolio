<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="../html/xsl2html.xsl"?>
<!--

Title     : from a thin directory to a metadata tree
Label     : toc2rdf.xsl
Copyright : © 2004, "ADNX" <http://adnx.org>.
Licence   : "CeCILL" <http://www.cecill.info/licences/Licence_CeCILL_V1.1-US.html> 
            ("GPL" <http://www.gnu.org/copyleft/gpl.html> like)
Creator   : [FG] "Frédéric Glorieux" <frederic.glorieux@ajlsm.com> 
            ("AJLSM" <http://ajlsm.org>)

-->

<xsl:stylesheet 
  version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:style="http://openoffice.org/2000/style"
  xmlns:text="http://openoffice.org/2000/text"
  xmlns:meta="http://openoffice.org/2000/meta" 
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
  xmlns:dcterms="http://purl.org/dc/terms/"
  xmlns:IIM="http://iptc.org/IIM/"
  >
  <xsl:output indent="yes" method="xml" encoding="UTF-8"/>
  <xsl:variable name="rdfizable" select="' jpg sxw '"/>

  <xsl:template match="/">
    <rdf:RDF>
      <xsl:apply-templates/>
    </rdf:RDF>
  </xsl:template>

  <!-- collection is the  -->
  <xsl:template match="collection">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <!-- resource with a supposed already generated leave -->
  <xsl:template match="resource">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:if test="@extension != '' and contains($rdfizable, concat(' ', @extension, ' '))">
        <xsl:apply-templates select="document(concat(../@href, @basename, '.rdf'), .)/*/rdf:Description"/>
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <!-- strip empty texts -->
  <xsl:template match="text()[normalize-space(.)='']"/>
  <!-- root processing instructions may create problems -->
  <xsl:template match="/processing-instruction()"/>
    
  <!-- a default copy all -->
  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
