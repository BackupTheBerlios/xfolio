<?xml version="1.0" encoding="UTF-8"?>
<!--

(c) 2004 AJLSM <http://ajlsm.com>, xfolio.org. Licence ?


= WHAT =

Provide a flat Dublin Record from Adobe.XMP XML
Special handling of multilingual description

= WHO =

* [[FG]] Glorieux, Frédéric <frederic.glorieux@xfolio.org>
* [[PT]] Terray, Paul <terray@4dconcept.fr>

= HOW =
multilingual description are formatted as

default 
description

[lang] title on one line
description
multiline

[other lang] title in another lang
description in this lang...

= TODO =

<xapBJ:JobRef>
	<rdf:Bag>
    <rdf:li rdf:parseType="Resource">
      <stJob:name>Project Blue Square</stJob:name>
    </rdf:li>
  </rdf:Bag>
</xapBJ:JobRef>


= CHANGES =

* 2004-10-08:[FG] Licence URI (<xapRights:WebStatement/>)
* 2004-10-08:[FG] more precise "IIM:" namespace
* 2004-10-08:[FG] multilingual descriptions, bug corrected
* 2004-09   :[FG] creation


= REFERENCES =

* http://iptc.org/IIM/ (default URI for IIM namespace)
* http://www.iptc.org/download/download.php?fn=IIMV4.1.pdf


-->
<xsl:transform version="1.0" xmlns:IIM="http://iptc.org/IIM/" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:photoshop="http://ns.adobe.com/photoshop/1.0/" xmlns:pdf="http://ns.adobe.com/pdf/1.3/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:x="adobe:ns:meta/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xap="http://ns.adobe.com/xap/1.0/" xmlns:xapMM="http://ns.adobe.com/xap/1.0/mm/" xmlns:xapRights="http://ns.adobe.com/xap/1.0/rights/" exclude-result-prefixes="photoshop pdf x xap xapMM xapRights">
  <!-- bug possible from here (used to format description) -->
  <xsl:variable name="CR" select="'&#xD;'"/>
  <!-- root -->
  <xsl:template match="/x:xmpmeta | /x:xapmeta">
    <rdf:RDF>
      <rdf:Description>
        <xsl:apply-templates/>
      </rdf:Description>
    </rdf:RDF>
  </xsl:template>
  <!-- order the record, output only dc:property 
1) the dc:properties
2) iptc elements mapped to dc
-->
  <xsl:template match="x:xmpmeta/rdf:RDF | x:xapmeta">
    <xsl:apply-templates select="rdf:Description[dc:*]"/>
    <xsl:apply-templates select="rdf:Description[not(dc:*)]"/>
  </xsl:template>
  <!-- default, pass it -->
  <xsl:template match="rdf:Description | x:xmpmeta | x:xapmeta">
    <xsl:apply-templates/>
  </xsl:template>
  <!-- no direct output for these elements -->
  <xsl:template match="photoshop:City|photoshop:Country|photoshop:State|photoshop:AuthorsPosition
  | rdf:Description[not(*)] | rdf:Description[xap:* | xapMM:*] | xapRights:*"/>
  <!-- 
2:115 Source Not repeatable, maximum of 32 octets, consisting of graphic
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
2:30 Release
Date
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
2:15 Category Not repeatable, maximum three octets, consisting of alphabetic
characters.
Identifies the subject of the objectdata in the opinion of the
provider.
A list of categories will be maintained by a regional registry,
where available, otherwise by the provider.
Note: Use of this DataSet is Deprecated. It is likely that this
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
2:20 Supplemental
Category
Repeatable, maximum 32 octets, consisting of graphic characters
plus spaces.
Supplemental categories further refine the subject of an
objectdata. Only a single supplemental category may be
contained in each DataSet. A supplemental category may include
any of the recognised categories as used in 2:15. Otherwise,
selection of supplemental categories are left to the
provider.
Examples:
"NHL" (National Hockey League)
"Fußball"
Note: Use of this DataSet is Deprecated. It is likely that this
DataSet will not be included in further versions of the IIM.
-->
  <xsl:template match="photoshop:SupplementalCategories">
    <!--
    <xsl:for-each select=".//rdf:li">
      <dc:subject xsi:type="IIM:SupplementalCategories">
        <xsl:apply-templates/>
      </dc:subject>
    </xsl:for-each>
-->
  </xsl:template>
  <!-- 

2:100 Country/ Primary Location Code
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

2:101 Country/Primary Location Name
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
2:40 Special
Instructions
Not repeatable, maximum 256 octets, consisting of graphic characters
plus spaces.
Other editorial instructions concerning the use of the objectdata,
such as embargoes and warnings.
Examples:
"SECOND OF FOUR STORIES"
"3 Pictures follow"
"Argentina OUT"
-->
  <xsl:template match="photoshop:Instructions">
    <dc:description xsi:type="IIM:Instructions">
      <xsl:apply-templates/>
    </dc:description>
  </xsl:template>
  <!--
2:103 Original
Transmission
Reference
Not repeatable. Maximum 32 octets, consisting of graphic characters
plus spaces.
A code representing the location of original transmission according
to practices of the provider.
Examples:
BER-5
PAR-12-11-01
-->
  <xsl:template match="photoshop:TransmissionReference">
    <dc:identifier xsi:type="IIM:TransmissionReference">
      <xsl:apply-templates/>
    </dc:identifier>
  </xsl:template>
  <!--
2:105 Headline Not repeatable, maximum of 256 octets, consisting of graphic
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
2:110 Credit Not repeatable, maximum of 32 octets, consisting of graphic
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
2:116 Copyright
Notice
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
2:25 Keywords Repeatable, maximum 64 octets, consisting of graphic characters
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
- -
default 
description

[lang] title
description
multiline

[other lang] title in another lang
description in this lang...
- -

parsing description text in case of multilingual description 

* 2004-10-08 [FG] debugging on real life records

-->
  <xsl:template name="text" match="dc:description//text()">
    <xsl:param name="text" select="."/>
    <xsl:param name="max" select="5"/>
    <xsl:choose>
      <!-- don't forget to finish ! -->
      <xsl:when test="$max = 0"/>
      <xsl:when test="normalize-space($text)=''"/>
      <!-- wash spaces before a language declaration -->
      <xsl:when test="substring-before($text, '[') != '' and normalize-space(substring-before($text, '[')) = ''">
        <xsl:call-template name="text">
          <xsl:with-param name="text" select="substring-after($text, substring-before($text, '['))"/>
          <xsl:with-param name="max" select="$max - 1"/>
        </xsl:call-template>
      </xsl:when>
      <!-- here is formatting -->
      <xsl:when test="starts-with($text, '[') and contains($text, ']')">
        <xsl:variable name="lang" select="substring-after(substring-before($text, ']'), '[')"/>
        <dc:title xsi:type="IIM:Description" xml:lang="{$lang}">
          <xsl:choose>
            <xsl:when test="contains(substring-after($text, ']'), $CR)">
              <xsl:value-of select="normalize-space(substring-before(substring-after($text, ']'), $CR))"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="normalize-space(substring-after($text, ']'))"/>
            </xsl:otherwise>
          </xsl:choose>
        </dc:title>
        <xsl:variable name="after" select="substring-after(substring-after($text, ']'), $CR)"/>
        <xsl:choose>
          <!-- other language -->
          <xsl:when test="contains($after, '[') or true()">
            <xsl:call-template name="text">
              <xsl:with-param name="text" select="concat('[', substring-after($after, '['))"/>
              <xsl:with-param name="max" select="$max - 1"/>
            </xsl:call-template>
          </xsl:when>
          <!-- a description after a title -->
          <xsl:when test="contains($after, concat($CR, '['))">
            <dc:description xsi:type="IIM:Description" xml:lang="{$lang}">
              <xsl:value-of select="substring-before($after, concat($CR, '['))"/>
            </dc:description>
            <xsl:call-template name="text">
              <xsl:with-param name="text" select="concat('[', substring-after($after, '['))"/>
              <xsl:with-param name="max" select="$max - 1"/>
            </xsl:call-template>
          </xsl:when>
          <!-- end of field -->
          <xsl:otherwise>
            <dc:description xsi:type="IIM:Description" xml:lang="{$lang}">
              <xsl:value-of select="$after"/>
            </dc:description>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <!-- text before a language declaration is a description in default language -->
      <xsl:when test="contains($text, '[')">
        <xsl:if test="normalize-space(substring-before($text, '['))!=''">
          <dc:description xsi:type="IIM:Description">
            <xsl:value-of select="substring-before($text, '[')"/>
          </dc:description>
        </xsl:if>
        <xsl:call-template name="text">
          <xsl:with-param name="text" select="concat('[', substring-after($text, '['))"/>
          <xsl:with-param name="max" select="$max - 1"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <dc:description xsi:type="IIM:Description">
          <xsl:value-of select="."/>
        </dc:description>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- should be unuseful but copy everything, in case of something missed -->
  <xsl:template match="*">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
</xsl:transform>
