<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="../html/xsl2html.xsl"?>
<!--

Copyright : (c) 2003, 2004, "ADNX" <http://adnx.org>
Licence   : "GPL" <http://www.fsf.org/copyleft/gpl.html>
Creator   : [FG] "Frédéric Glorieux" <frederic.glorieux@ajlsm.com>

= What =

http://cvs.berlios.de/cgi-bin/viewcvs.cgi/xfolio/webapp/transform/meta/xmp2dc.xsl

AdobeTM applications (and some other freewares like [pixvue])
promote an XML schema of metadatas (title, author, description...)
embed in binary files (jpeg, pdf, and other proprietary format).
The info is interesting, using a semantic knowed as [IPTC/IMM],
but the XML is ugly. This transformation try to extract most of
the fields in a flat XML record conforming to dublincore
recommandations. This becomes interesting when you can get some xmp.
It's usually possible with some tricks in AdobeTM apps, 
but hopefully, a cocoon generator is also exposed here for jpeg images
[XfolioXMPGenerator]

There's a specific feature in this transformation. In our context, we expect
multilingual records (title and description in more than one language).
You can imagine the interest. If you have an image with a tree,
if the content is indexed in a search engine, you can find the images
documented with the term "tree". If you are waiting for other langs public,
it's also nice to have the term "arbre", or "baum".
A very simple text rule is supported, precised in the HOW section. 
This transformation have been tested on some hundred of jpeg images.


= Output =

{{{
<rdf:RDF 
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
  xmlns:IIM="http://iptc.org/IIM/" 
  xmlns:dc="http://purl.org/dc/elements/1.1/" 
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <rdf:Description>
    <dc:creator xsi:type="IIM:Author">Kalayan, Haroutune (Ingénieur civil)</dc:creator>
    <dc:title xsi:type="IIM:Title">FAQRA - Eglise d'époque byzantine</dc:title>
    <dc:title xsi:type="IIM:Description" xml:lang="fr"
>Vue de la nef centrale de l'église bordée par ses deux rangées de colonnes.</dc:title>
    <dc:title xsi:type="IIM:Description" xml:lang="en"
>View of the chief nave of the church, bordered by its two rows of columns.</dc:title>
    <dc:rights xsi:type="IIM:Copyright" 
     rdf:resource="http://creativecommons.org/licenses/by-nc-sa/2.0/"
>©1962. Direction Générale des Antiquités.Liban</dc:rights>
    <dc:subject xsi:type="IIM:Keywords">1962</dc:subject>
    <dc:subject xsi:type="IIM:Keywords">Archéologie</dc:subject>
    <dc:subject xsi:type="IIM:Keywords">Architecture</dc:subject>
    <dc:subject xsi:type="IIM:Keywords">Colonne</dc:subject>
    <dc:subject xsi:type="IIM:Keywords">Eglise</dc:subject>
    <dc:subject xsi:type="IIM:Keywords">Fakra</dc:subject>
    <dc:subject xsi:type="IIM:Keywords">Faqra</dc:subject>
    <dc:subject xsi:type="IIM:Keywords">Kalayan, Haroutune</dc:subject>
    <dc:subject xsi:type="IIM:Keywords">Nef</dc:subject>
    <dc:subject xsi:type="IIM:Keywords">Période byzantine</dc:subject>
    <dc:subject xsi:type="IIM:Keywords">Restauration</dc:subject>
    <dc:coverage xsi:type="iptc">FAQRA (LIBAN, KESROUAN)</dc:coverage>
    <dc:date xsi:type="IIM:ReleaseDate">2003-12-15</dc:date>
    <dc:contributor xsi:type="IIM:CaptionWriter"
>S.D., H.K-J. Equipe Strabon</dc:contributor>
  </rdf:Description>
</rdf:RDF>
}}}


= How =

Multilingual description are formatted in the description field like that

{{{
default 
description

[lang] title on one line
description
multiline

[other lang] title in another lang
description in this lang...
}}}


= CHANGES =

 * 2004-10-08:[FG] a bug with photoshop XMP
 * 2004-10-07:[FG] Licence URI (<xapRights:WebStatement/>)
 * 2004-10-06:[FG] more precise "IIM:" namespace
 * 2004-10-05:[FG] multilingual descriptions, bug corrected
 * 2004-09   :[FG] creation


= REFERENCES =

[pixvue] Colemenan, Eamon. 
http://pixvue.com/ 
An MS.Windows Image Organizer, XMP compatible 

[IPTC/IMM] "IPTC - NAA INFORMATION INTERCHANGE MODEL" 
http://www.iptc.org/IIM/
http://www.iptc.org/download/download.php?fn=IIMV4.1.pdf

[XMP] Adobe Systems Incorporated "Extensible Metadata Platform (XMP)" 
http://www.adobe.com/products/xmp/main.html 
Adobe's Extensible Metadata Platform (XMP) is a labeling technology that
allows you to embed data about a file, known as metadata, into the file
itself. With XMP, desktop applications and back-end publishing systems gain a
common method for capturing, sharing, and leveraging this valuable metadata -
opening the door for more efficient job processing, workflow automation, and
rights management, among many other possibilities. With XMP, Adobe has taken
the "heavy lifting" out of metadata integration, offering content creators an
easy way to embed meaningful information about their projects and providing
industry partners with standards-based building blocks to develop optimized
workflow solutions. 

[DCES]  "Dublin Core Metadata Element Set, Version 1.1: Reference Description". 
DCMI (Dublin Core Metadata Initiative)
http://dublincore.org/documents/dces/  
The Dublin Core metadata element set is a standard for cross-domain information 
resource description. Here an information resource is defined to be "anything 
that has identity". This is the definition used in Internet RFC 2396, 
"Uniform Resource Identifiers (URI): Generic Syntax", by Tim Berners-Lee et al. 
There are no fundamental restrictions to the types of resources to which Dublin 
Core metadata can be assigned. 

[DC-XML]  "Guidelines for implementing Dublin Core in XML". 
DCMI, Dublin Core Metadata Initiative, 2003-04-02. Powell, Andy; Johnston, Pete. 
http://dublincore.org/documents/dc-xml-guidelines/  
This document provides guidelines for people implementing Dublin Core metadata 
applications using XML. It considers both simple (unqualified) DC and qualified 
DC applications. In each case, the underlying metadata model is described 
(in a syntax neutral way), followed by some specific guidelines for XML implementations. 
Some guidance on the use of non-DC metadata within DC metadata applications is also provided.

[DCES-RDF]  "Expressing Simple Dublin Core in RDF/XML". 
Dublin Core Metadata Initiative, 2002-07-31. 
Beckett, Dave; Miller, Eric; Brickley, Dan. 
http://dublincore.org/documents/dcmes-xml/  
The Dublin Core Metadata Element Set V1.1 (DCMES) can be represented 
in many syntax formats. This document explains how to encode the DCMES 
in RDF/XML, provides a DTD to validate the documents and describes 
a method to link them from web pages. 

[DCQ-RDF]  "Expressing Qualified Dublin Core in RDF / XML". 
DCMI Dublin Core Metadata Initiative, 2002-05-15. 
Kokkelink, Stefan; Schwänzl, Roland. 
http://dublincore.org/documents/dcq-rdf-xml/  
This document describes how qualified Dublin Core metadata can be encoded 
in RDF / XML and gives practical examples. 

[AJLSM] Arvers, Jean-Luc; Sévigny, Martin 
"Solution pour le document numérique" <http://ajlsm.com>


-->
<xsl:transform version="1.0" xmlns:IIM="http://iptc.org/IIM/" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:photoshop="http://ns.adobe.com/photoshop/1.0/" xmlns:pdf="http://ns.adobe.com/pdf/1.3/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:x="adobe:ns:meta/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xap="http://ns.adobe.com/xap/1.0/" xmlns:xapMM="http://ns.adobe.com/xap/1.0/mm/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:xapRights="http://ns.adobe.com/xap/1.0/rights/" exclude-result-prefixes="photoshop pdf x xap xapMM xapRights">
  <!-- file naming utilities, especially for the "hasFormat" template -->
  <xsl:import href="naming.xsl"/>
  <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
  <!-- the path of the file as identifier  -->
  <xsl:param name="path"/>
  <!-- extensions from which an alternative format is waited -->
  <xsl:param name="formats"/>
  <!-- 
These variables are used to normalize names of languages
-->
  <xsl:variable name="majs" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZÀÁÂÃÄÅÆÈÉÊËÌÍÎÏÐÑÒÓÔÕÖÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõöùúûüýÿþ .()/\?'"/>
  <xsl:variable name="mins" select="'abcdefghijklmnopqrstuvwxyzaaaaaaaeeeeiiiidnooooouuuuybbaaaaaaaceeeeiiiionooooouuuuyyb------'"/>
  <xsl:variable name="CR" select="'&#xD;'"/>
  <xsl:variable name="LF" select="'&#10;'"/>
  <!-- root -->
  <xsl:template match="/">
    <rdf:RDF>
      <rdf:Description rdf:about="{$path}">
        <xsl:apply-templates/>
        <xsl:call-template name="hasFormat"/>
      </rdf:Description>
    </rdf:RDF>
  </xsl:template>
  <!--
Default handles
-->
  <xsl:template match="text()[normalize-space(.) ='']"/>
  <!-- should be unuseful but copy everything, in case of something missed -->
  <xsl:template match="*">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  <!-- order the record, output only dc:property 
1) the dc:properties
2) IIM elements mapped to dc
-->
  <xsl:template match="x:xmpmeta/rdf:RDF | x:xapmeta/rdf:RDF">
    <xsl:apply-templates select="rdf:Description[dc:*]"/>
    <xsl:apply-templates select="rdf:Description[not(dc:*)]"/>
  </xsl:template>
  <!-- default, pass it  -->
  <xsl:template match="rdf:Description | x:xmpmeta | x:xapmeta | rdf:RDF | /*">
    <xsl:apply-templates/>
  </xsl:template>
  <!-- no direct output for these elements -->
  <xsl:template match="photoshop:City|photoshop:Country|photoshop:State|photoshop:AuthorsPosition
  | rdf:Description[not(*)] | rdf:Description[xap:* | xapMM:*] | xapRights:*">
    <!--
TODO
    {{{
    <xapBJ:JobRef>
      <rdf:Bag>
        <rdf:li rdf:parseType="Resource">
          <stJob:name>Project Blue Square</stJob:name>
        </rdf:li>
      </rdf:Bag>
    </xapBJ:JobRef>
    }}}
    -->
  </xsl:template>
  <!-- 
2-115 Source :
  Not repeatable, maximum of 32 octets, consisting of graphic
  characters plus spaces.
  Identifies the original owner of the intellectual content of the
  objectdata. This could be an agency, a member of an agency or
  an individual.
-->
  <xsl:template match="photoshop:Source">
    <dc:source xsi:type="IIM:Source">
      <xsl:apply-templates/>
    </dc:source>
  </xsl:template>
  <!-- contributor -->
  <xsl:template match="photoshop:CaptionWriter">
    <dc:contributor xsi:type="IIM:CaptionWriter">
      <xsl:apply-templates/>
    </dc:contributor>
  </xsl:template>
  <!--
2-30 Release Date :
  Not repeatable, eight octets, consisting of numeric characters.
  Designates in the form CCYYMMDD the earliest date the
  provider intends the object to be used. Follows ISO 8601 standard.
Example:
  "19890317" indicates data for release on 17 March
  1989.
-->
  <xsl:template match="photoshop:DateCreated">
    <dc:date xsi:type="IIM:ReleaseDate">
      <xsl:apply-templates/>
    </dc:date>
  </xsl:template>
  <!--
2-15 Category :
  Not repeatable, maximum three octets, consisting of alphabetic
  characters.
  Identifies the subject of the objectdata in the opinion of the
  provider.
  A list of categories will be maintained by a regional registry,
  where available, otherwise by the provider.
Note: 
  Use of this DataSet is Deprecated. It is likely that this
  DataSet will not be included in further versions of the IIM.
-->
  <xsl:template match="photoshop:Category">
    <!--
    <dc:subject xsi:type="IIM:Category">
      <xsl:apply-templates/>
    </dc:subject>
-->
  </xsl:template>
  <!--
2-20 Supplemental Category :
  Repeatable, maximum 32 octets, consisting of graphic characters
  plus spaces.
  Supplemental categories further refine the subject of an
  objectdata. Only a single supplemental category may be
  contained in each DataSet. A supplemental category may include
  any of the recognised categories as used in 2-15. Otherwise,
  selection of supplemental categories are left to the
  provider.
Examples:
  "NHL" (National Hockey League)
  "Fußball"
Note: 
  Use of this DataSet is Deprecated. It is likely that this
  DataSet will not be included in further versions of the IIM.
-->
  <xsl:template match="photoshop:SupplementalCategories">
    <xsl:for-each select=".//rdf:li">
      <dc:subject xsi:type="IIM:SupplementalCategories">
        <xsl:apply-templates/>
      </dc:subject>
    </xsl:for-each>
  </xsl:template>
  <!-- 

2-100 Country/ Primary Location Code :
  Not repeatable, three octets consisting of alphabetic characters.
  Indicates the code of the country/primary location where the
  intellectual property of the objectdata was created, e.g. a photo
  was taken, an event occurred.
  Where ISO has established an appropriate country code under
  ISO 3166, that code will be used. When ISO3166 does not
  adequately provide for identification of a location or a new
  country, e.g. ships at sea, space, IPTC will assign an
  appropriate three-character code under the provisions of
  ISO3166 to avoid conflicts. (see Appendix D)
Examples:
  "USA" (United States)
  "FRA" (France)
  “XUN” (United Nations)

2-101 Country/Primary Location Name :
  Not repeatable, maximum 64 octets, consisting of graphic
  characters plus spaces.
  Provides full, publishable, name of the country/primary location
  where the intellectual property of the objectdata was created,
  according to guidelines of the provider.

  -->
  <xsl:template match="rdf:Description[photoshop:*]">
    <xsl:if test="photoshop:City|photoshop:State|photoshop:Country">
      <dc:coverage>
        <xsl:choose>
          <xsl:when test="photoshop:City">
            <xsl:apply-templates select="photoshop:City/node()"/>
            <!-- TODO : isolate country in an attribute ? Code ? -->
            <xsl:if test="photoshop:State|photoshop:Country">
              <xsl:text> (</xsl:text>
              <xsl:apply-templates select="photoshop:Country/node()"/>
              <xsl:if test="photoshop:State|photoshop:Country">, </xsl:if>
              <xsl:apply-templates select="photoshop:State/node()"/>
              <xsl:text>)</xsl:text>
            </xsl:if>
          </xsl:when>
          <xsl:when test="photoshop:State|photoshop:Country">
            <xsl:apply-templates select="photoshop:State/node()"/>
            <xsl:if test="photoshop:State|photoshop:Country">
              <xsl:text>, </xsl:text>
            </xsl:if>
            <xsl:apply-templates select="photoshop:Country/node()"/>
          </xsl:when>
        </xsl:choose>
      </dc:coverage>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:template>
  <!-- creator -->
  <xsl:template match="dc:creator[.//rdf:li]">
    <xsl:for-each select=".//rdf:li">
      <dc:creator xsi:type="IIM:Author">
        <xsl:apply-templates/>
        <xsl:if test="ancestor::rdf:RDF/rdf:Description/photoshop:AuthorsPosition and position()=1">
          <xsl:text> (</xsl:text>
          <xsl:value-of select="ancestor::rdf:RDF/rdf:Description/photoshop:AuthorsPosition"/>
          <xsl:text>)</xsl:text>
        </xsl:if>
      </dc:creator>
    </xsl:for-each>
  </xsl:template>
  <!-- title -->
  <xsl:template match="dc:title[.//rdf:li]">
    <xsl:for-each select=".//rdf:li">
      <dc:title xsi:type="IIM:Title">
        <!-- could be a good @xml:lang -->
        <xsl:copy-of select="@*[. != 'x-default']"/>
        <xsl:apply-templates/>
      </dc:title>
    </xsl:for-each>
  </xsl:template>
  <!--
2-40 Special Instructions
  Not repeatable, maximum 256 octets, consisting of graphic characters
  plus spaces.
  Other editorial instructions concerning the use of the objectdata,
  such as embargoes and warnings.
Examples:
  * "SECOND OF FOUR STORIES"
  * "3 Pictures follow"
  * "Argentina OUT"
-->
  <xsl:template match="photoshop:Instructions">
    <dc:description xsi:type="IIM:Instructions">
      <xsl:apply-templates/>
    </dc:description>
  </xsl:template>
  <!--
2-103 Original Transmission Reference
  Not repeatable. Maximum 32 octets, consisting of graphic characters
  plus spaces.
  A code representing the location of original transmission according
  to practices of the provider.
Examples:
  * BER-5
  * PAR-12-11-01
-->
  <xsl:template match="photoshop:TransmissionReference">
    <dc:identifier xsi:type="IIM:TransmissionReference">
      <xsl:apply-templates/>
    </dc:identifier>
  </xsl:template>
  <!--
2-105 Headline 
  Not repeatable, maximum of 256 octets, consisting of graphic
  characters plus spaces.
  A publishable entry providing a synopsis of the contents of the
  objectdata.
Example:
  "Lindbergh Lands In Paris"
-->
  <xsl:template match="photoshop:Headline">
    <dc:description xsi:type="IIM:Headline">
      <xsl:apply-templates/>
    </dc:description>
  </xsl:template>
  <!--
2-110 Credit :
  Not repeatable, maximum of 32 octets, consisting of graphic
  characters plus spaces.
  Identifies the provider of the objectdata, not necessarily the
  owner/creator.
-->
  <xsl:template match="photoshop:Credit">
    <dc:publisher xsi:type="IIM:Credit">
      <xsl:apply-templates/>
    </dc:publisher>
  </xsl:template>
  <!--
2-116 Copyright Notice :
  Not repeatable, maximum of 128 octets, consisting of graphic
  characters plus spaces.
  Contains any necessary copyright notice.
-->
  <xsl:template match="dc:rights">
    <xsl:for-each select=".//rdf:li">
      <dc:rights xsi:type="IIM:Copyright">
        <xsl:if test="ancestor::rdf:RDF//xapRights:WebStatement">
          <xsl:attribute name="rdf:resource">
            <xsl:apply-templates select="ancestor::rdf:RDF//xapRights:WebStatement/node()"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:apply-templates/>
      </dc:rights>
    </xsl:for-each>
  </xsl:template>
  <!--
2-25 Keywords : 
  Repeatable, maximum 64 octets, consisting of graphic characters
  plus spaces.
  Used to indicate specific information retrieval words.
  Each keyword uses a single Keywords DataSet. Multiple keywords
  use multiple Keywords DataSets.
  It is expected that a provider of various types of data that are related
  in subject matter uses the same keyword, enabling the receiving
  system or subsystems to search across all types of data
  for related material.
Examples: 
  "GRAND PRIX"
  "AUTO"
-->
  <xsl:template match="dc:subject">
    <xsl:for-each select=".//rdf:li">
      <dc:subject xsi:type="IIM:Keywords">
        <xsl:apply-templates/>
      </dc:subject>
    </xsl:for-each>
  </xsl:template>
  <!-- description -->
  <xsl:template match="dc:description[.//rdf:li]">
    <xsl:for-each select=".//rdf:li">
      <xsl:apply-templates/>
    </xsl:for-each>
  </xsl:template>
  <!-- 
This template parse a text in a description field in case of multilingual 
formating, like

{{{
default 
description

[lang] title
description
multiline

[other lang] title in another lang
description in this lang...
}}}

-->
  <xsl:template name="titledesc" match="dc:description//text()">
    <!-- normalize record, and add a LF at the end -->
    <xsl:param name="text" select="concat(translate(., $CR, $LF), $LF)"/>
    <xsl:choose>
      <xsl:when test="normalize-space($text)=''"/>
      <!-- start with a lang, but still another after, 
cut after next lang to have a mololang block, but keep '[' -->
      <xsl:when test="starts-with(normalize-space($text), '[')
        and contains(substring-after($text, '['), '[')
      ">
        <xsl:call-template name="titledesc">
          <xsl:with-param name="text" select="concat('[', substring-before(substring-after($text, '['), '['))"/>
        </xsl:call-template>
        <xsl:call-template name="titledesc">
          <xsl:with-param name="text">
            <xsl:value-of select="concat('[',substring-after(substring-after($text, '['), '['))"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <!-- here we should have only one lang -->
      <xsl:when test="starts-with(normalize-space($text), '[')">
        <xsl:variable name="lang" select="
translate(
  substring-before(substring-after($text, '['), ']')
  , $majs, $mins)
"/>
        <dc:title xsi:type="IIM:Title" xml:lang="{$lang}">
          <xsl:value-of select="substring-before(substring-after($text, ']'), $LF)"/>
        </dc:title>
        <xsl:if test="normalize-space(substring-after($text, $LF)) != ''">
          <dc:description xsi:type="IIM:Description" xml:lang="{$lang}">
            <xsl:value-of select="substring-after($text, $LF)"/>
          </dc:description>
        </xsl:if>
      </xsl:when>
      <!-- a lang somewhere, resend before and after, but keep '[' -->
      <xsl:when test="contains($text, '[')">
        <xsl:call-template name="titledesc">
          <xsl:with-param name="text" select="substring-before($text, '[')"/>
        </xsl:call-template>
        <xsl:call-template name="titledesc">
          <xsl:with-param name="text" select="concat('[', substring-after($text, '['))"/>
        </xsl:call-template>
      </xsl:when>
      <!-- no lang, a simple desc -->
      <xsl:otherwise>
        <dc:description xsi:type="IIM:Description">
          <xsl:value-of select="$text"/>
        </dc:description>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- sample of input -->
  <xsl:template name="xsl:input">
<?xpacket begin='' id='W5M0MpCehiHzreSzNTczkc9d'?>
<?adobe-xap-filters esc="CR"?>
<x:xmpmeta xmlns:x="adobe:ns:meta/" x:xmptk="XMP toolkit 2.9-9, framework 1.6">
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:iX="http://ns.adobe.com/iX/1.0/">

 <rdf:Description xmlns:pdf="http://ns.adobe.com/pdf/1.3/" 
   rdf:about="uuid:677e475e-f67e-11d8-b1aa-d5ccd9677e7a">

 </rdf:Description>

 <rdf:Description xmlns:photoshop="http://ns.adobe.com/photoshop/1.0/" 
   rdf:about="uuid:677e475e-f67e-11d8-b1aa-d5ccd9677e7a">
  <photoshop:AuthorsPosition>Ingénieur civil</photoshop:AuthorsPosition>

  <photoshop:City>FAQRA</photoshop:City>
  <photoshop:State>KESROUAN</photoshop:State>
  <photoshop:Country>LIBAN</photoshop:Country>
  <photoshop:DateCreated>2003-12-15</photoshop:DateCreated>
  <photoshop:CaptionWriter>S.D., H.K-J. Equipe Strabon</photoshop:CaptionWriter>
 </rdf:Description>

 <rdf:Description xmlns:xap="http://ns.adobe.com/xap/1.0/" 
  rdf:about="uuid:677e475e-f67e-11d8-b1aa-d5ccd9677e7a">

 </rdf:Description>

 <rdf:Description xmlns:xapMM="http://ns.adobe.com/xap/1.0/mm/" 
  rdf:about="uuid:677e475e-f67e-11d8-b1aa-d5ccd9677e7a">

  <xapMM:DocumentID>adobe:docid:photoshop:c2120245-f678-11d8-b1aa-d5ccd9677e7a</xapMM:DocumentID>
 </rdf:Description>

 <rdf:Description xmlns:xapRights="http://ns.adobe.com/xap/1.0/rights/" 
  rdf:about="uuid:677e475e-f67e-11d8-b1aa-d5ccd9677e7a">
  <xapRights:Marked>True</xapRights:Marked>

  <xapRights:WebStatement>http://creativecommons.org/licenses/by-nc-sa/2.0/</xapRights:WebStatement>
 </rdf:Description>

 <rdf:Description xmlns:dc="http://purl.org/dc/elements/1.1/" 
rdf:about="uuid:677e475e-f67e-11d8-b1aa-d5ccd9677e7a">
  <dc:creator>
   <rdf:Seq>
    <rdf:li>Kalayan, Haroutune</rdf:li>
   </rdf:Seq>
  </dc:creator>
  <dc:title>
   <rdf:Alt>

    <rdf:li xml:lang="x-default">FAQRA - Eglise d'époque byzantine</rdf:li>
   </rdf:Alt>
  </dc:title>
  <dc:description>
   <rdf:Alt>
    <rdf:li xml:lang="x-default">
[fr] Vue de la nef centrale de l'église bordée par ses deux rangées de colonnes.

[en]View of the chief nave of the church, bordered by its two rows of columns.
</rdf:li>
   </rdf:Alt>

  </dc:description>
  <dc:rights>
   <rdf:Alt>
    <rdf:li xml:lang="x-default">©1962. Direction Générale des Antiquités. Liban</rdf:li>
   </rdf:Alt>
  </dc:rights>
  <dc:subject>
   <rdf:Bag>

    <rdf:li>1962</rdf:li>
    <rdf:li>Archéologie</rdf:li>
    <rdf:li>Architecture</rdf:li>
    <rdf:li>Colonne</rdf:li>
    <rdf:li>Eglise</rdf:li>
    <rdf:li>Fakra</rdf:li>

    <rdf:li>Faqra</rdf:li>
    <rdf:li>Kalayan, Haroutune</rdf:li>
    <rdf:li>Nef</rdf:li>
    <rdf:li>Période byzantine</rdf:li>
    <rdf:li>Restauration</rdf:li>
   </rdf:Bag>

  </dc:subject>
 </rdf:Description>

</rdf:RDF>
</x:xmpmeta>
<?xpacket end='w'?>
  </xsl:template>
  
</xsl:transform>
