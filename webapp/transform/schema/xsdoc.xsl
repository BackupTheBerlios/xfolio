<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:transform [
	<!ENTITY sdapa-uri "http://www.culture.gouv.fr/ns/dapa/1.0">
	<!ENTITY xsdoc-uri "http://sdapa.org/xsdoc">
	<!ENTITY letters "abcdefghijklmnopqrstuvwxyzàáâãäåæçéèêëìíîïðñòóôõöùúûüýÀÁÂÃÄÅÆÇÉÈÊËÌÍÎÏÐÑÒÓÔÕÖÙÚÛÜÝ">
	<!ENTITY caps "ABCDEFGHIJKLMNOPQRSTUVWXYZAAAAAAACEEEEIIIIOOOOOOOUUUUYAAAAAAACEEEEIIIIDNOOOOOUUUUY">
	<!ENTITY letter1 "translate(substring(normalize-space(.), 1, 1), '&letters;', '&caps;')">
]><!--
  Cette transformation propose un format pour documenter un schéma W3C. 
  Cette présentation s'inspire largement de DTD Parse.
  Attention, il ne s'agit pas d'un outil parfaitement générique. Plusieurs aspects de la
  spécification ne sont pas pris en charge (imports, redéfinitions, éléments abstraits...). 
  De plus, l'outil prend une valeur documentaire
  lorsque que sont respectées certaines règles en écrivant le schéma
  Essentiellement, .


  Le processus normal de la transformation produit un <concept/> pour chaque 
  élément nommés.
  Il existe aussi un mode="xsdoc:markup" produisant des <markup/>
  
  MAYDO : un jeu de de balises taglib <xsdoc:*/> pour obtenir des blocs d'information
  sur un schéma dans un autre document.

 [TODO:URI] centraliser la résolution d'uri
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="&sdapa-uri;" xmlns:sdapa="&sdapa-uri;" xmlns:xsdoc="&xsdoc-uri;" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:gml="http://www.opengis.net/gml" exclude-result-prefixes="sdapa xsdoc xsi xs">
	<xsl:import href="sdapa2html.xsl"></xsl:import>
	<xsl:output method="xml" indent="no" encoding="UTF-8" omit-xml-declaration="no" cdata-section-elements="xml"></xsl:output>
	<xsl:output name="html" method="xml" indent="no" omit-xml-declaration="yes" encoding="ISO-8859-1"></xsl:output>
	<xsl:param name="lang" select="'fr'"></xsl:param>
	<xsl:param name="index-guidelines" select="''"></xsl:param>
	<xsl:param name="index-guidelines-mh" select="''"></xsl:param>
	<!-- l'engin xsl résoud les projections de documents relativement au répertoire
  où il est appelé. L'installation par défaut travaille juste au dessus de cette xsl.
  Les répertoires créés peuvent se faire relativement à ce point. -->
	<xsl:param name="site" select="''"></xsl:param>
	<!-- Le nom du fichier source pour le schéma -->
	<xsl:param name="schema-filename" select="''"/>
	<!-- constitution d'une variable globale avec le contenu du schéma,
  TODO: résoudre les include, import, et redéfinition -->
	<xsl:variable name="root" select="/"></xsl:variable>
	<xsl:variable name="schema" select="document('', $root)"></xsl:variable>
	<!-- documentation directe d'un schéma,
  fabrique un hypertexte avec une arborescence relative au schéma 
  avec version xml et html pour chaque item

  index.html .xml

  indexes/elements.html .xml
  elements/{name}.html .xml

  indexes/attributes.html .xml
  attributes/{name}.html .xml

  indexes/groups.html .xml
  groups/{name}.html .xml

  
  La projection de documents obéit à la syntaxe xslt2 (processeurs compatibles: saxon7)
-->
	<!-- surcharge de sdapa2sdapa.xsl (essentiellement pour les guidelines)
ajoute les méta-données communes -->
	<xsl:template match="/*/sdapa:info" mode="sdapa:copy">
		<info>
			<xsl:call-template name="xsdoc:dc"></xsl:call-template>
			<xsl:apply-templates mode="sdapa:copy"></xsl:apply-templates>
		</info>
	</xsl:template>
	<xsl:template match="/">
		<!--
  présentation générale
-->
		<xsl:variable name="info">
			<info>
				<info>
					<xsl:call-template name="xsdoc:dc">
						<xsl:with-param name="prefix"></xsl:with-param>
					</xsl:call-template>
				</info>
				<xsl:apply-templates select="$schema/xs:schema/xs:annotation/xs:documentation/node()" mode="sdapa:copy"></xsl:apply-templates>
			</info>
		</xsl:variable>
		<xsl:result-document href="{$site}index.xml">
			<xsl:copy-of select="$info"></xsl:copy-of>
		</xsl:result-document>
		<xsl:result-document format="html" href="{$site}index.html">
			<xsl:call-template name="sdapa:html">
				<xsl:with-param name="content" select="$info"></xsl:with-param>
				<xsl:with-param name="output-info" select="false()"/>
			</xsl:call-template>
		</xsl:result-document>
		<!-- documents thématiques -->
		<!-- l'index -->
<!-- 		<xsl:variable name="guidelines" select="document($index-guidelines)"></xsl:variable>
		<xsl:variable name="index">
			<xsl:apply-templates select="$guidelines" mode="sdapa:copy"></xsl:apply-templates>
		</xsl:variable>
		<xsl:result-document format="html" href="{$site}guidelines/index.html">
			<xsl:call-template name="sdapa:html">
				<xsl:with-param name="content" select="$index"></xsl:with-param>
			</xsl:call-template>
		</xsl:result-document>
 -->		<!-- TODO copier aussi la source des guidelines en XML -->
		<!-- chaque fichier pointé par la toc -->
<!-- 		<xsl:for-each select="$guidelines//sdapa:contents[1]/sdapa:summary">
			<xsl:variable name="target">
				<xsl:apply-templates select="@uri"></xsl:apply-templates>
			</xsl:variable>
			<xsl:message>
				<xsl:value-of select="$target"></xsl:value-of>
			</xsl:message>
			<xsl:result-document format="html" href="{$site}guidelines/{$target}">
				<xsl:variable name="doc">
					<xsl:apply-templates select="document(@uri, .)" mode="sdapa:copy"></xsl:apply-templates>
				</xsl:variable>
				<xsl:call-template name="sdapa:html">
					<xsl:with-param name="content" select="$doc"></xsl:with-param>
				</xsl:call-template>
			</xsl:result-document>
		</xsl:for-each>
 -->
<!--  		<xsl:variable name="guidelines-mh" select="document($index-guidelines-mh)"></xsl:variable>
		<xsl:variable name="index-mh">
			<xsl:apply-templates select="$guidelines-mh" mode="sdapa:copy"></xsl:apply-templates>
		</xsl:variable>
		<xsl:result-document format="html" href="{$site}guidelines/exemples-mh/index.html">
			<xsl:call-template name="sdapa:html">
				<xsl:with-param name="content" select="$index-mh"></xsl:with-param>
			</xsl:call-template>
		</xsl:result-document>
 -->		<!-- TODO copier aussi la source des guidelines en XML -->
		<!-- chaque fichier pointé par la toc -->
<!-- 		<xsl:for-each select="$guidelines-mh//sdapa:contents[1]/sdapa:summary">
			<xsl:message>
				<xsl:value-of select="title"></xsl:value-of>
			</xsl:message>
			<xsl:variable name="target">
				<xsl:apply-templates select="@uri"></xsl:apply-templates>
			</xsl:variable>
			<xsl:if test="$target != ''">
				<xsl:message>
					<xsl:value-of select="$target"></xsl:value-of>
				</xsl:message>
				<xsl:result-document format="html" href="{$site}guidelines/exemples-mh/{$target}">
					<xsl:variable name="doc">
						<xsl:apply-templates select="document(@uri, .)" mode="sdapa:copy"></xsl:apply-templates>
					</xsl:variable>
					<xsl:call-template name="sdapa:html">
						<xsl:with-param name="content" select="$doc"></xsl:with-param>
					</xsl:call-template>
				</xsl:result-document>
			</xsl:if>
		</xsl:for-each>
 -->		<!-- index des groupes -->
		<xsl:variable name="groups">
			<index>
				<info>
					<xsl:call-template name="xsdoc:dc"></xsl:call-template>
				</info>
				<title>
					<xsl:value-of select="count($schema//xs:group[@name])"></xsl:value-of> 
          groupes
        </title>
				<xsl:apply-templates select="$schema//xs:group[@name]" mode="xsdoc:index">
					<xsl:sort select="@name"></xsl:sort>
				</xsl:apply-templates>
			</index>
		</xsl:variable>
		<xsl:result-document href="{$site}indexes/groups.xml">
			<xsl:copy-of select="$groups"></xsl:copy-of>
		</xsl:result-document>
		<xsl:result-document format="html" href="{$site}indexes/groups.html">
			<xsl:call-template name="sdapa:html">
				<xsl:with-param name="content" select="$groups"></xsl:with-param>
				<xsl:with-param name="in-schema-subdir" select="true()"/>
				<xsl:with-param name="output-info" select="false()"/>
			</xsl:call-template>
		</xsl:result-document>
		<xsl:message> -- groups</xsl:message>
		<!-- documenter les groupes -->
		<xsl:for-each select="$schema//xs:group[@name]">
			<xsl:variable name="content">
				<xsl:apply-templates select="."></xsl:apply-templates>
			</xsl:variable>
			<xsl:variable name="group" select="concat( $site, 'groups/', @name)"></xsl:variable>
			<xsl:result-document href="{$group}.xml">
				<xsl:copy-of select="$content"></xsl:copy-of>
			</xsl:result-document>
			<xsl:result-document format="html" href="{$group}.html">
				<xsl:call-template name="sdapa:html">
					<xsl:with-param name="content" select="$content"></xsl:with-param>
					<xsl:with-param name="in-schema-subdir" select="true()"/>
					<xsl:with-param name="output-info" select="false()"/>
				</xsl:call-template>
			</xsl:result-document>
			<xsl:message>
				<xsl:value-of select="$group"></xsl:value-of>
			</xsl:message>
		</xsl:for-each>
		<!-- index des éléments -->
		<xsl:variable name="elements">
			<index>
				<info>
					<xsl:call-template name="xsdoc:dc"></xsl:call-template>
				</info>
				<title>
					<!-- Pour le titre, on calcule les nombres d'éléments globaux et le nombre d'éléments locaux -->
					<xsl:value-of select="count($schema//xs:element[@name and not(ancestor::xs:element or ancestor::xs:complexType)])"></xsl:value-of>
					<xsl:text> éléments définis globalement et </xsl:text>
					<xsl:value-of select="count($schema//xs:element[@name and (ancestor::xs:element or ancestor::xs:complexType)])"></xsl:value-of>
					<xsl:text> éléments définis localement</xsl:text>
        </title>
				<xsl:apply-templates select="$schema//xs:element[@name]" mode="xsdoc:index">
					<xsl:sort select="@name"></xsl:sort>
				</xsl:apply-templates>
			</index>
		</xsl:variable>
		<xsl:result-document href="{$site}indexes/elements.xml">
			<xsl:copy-of select="$elements"></xsl:copy-of>
		</xsl:result-document>
		<xsl:result-document format="html" href="{$site}indexes/elements.html">
			<xsl:call-template name="sdapa:html">
				<xsl:with-param name="content" select="$elements"></xsl:with-param>
				<xsl:with-param name="in-schema-subdir" select="true()"/>
				<xsl:with-param name="output-info" select="false()"/>
			</xsl:call-template>
		</xsl:result-document>
		<xsl:message> -- elements</xsl:message>
		<!-- documenter les éléments -->
		<xsl:for-each select="$schema//xs:element[@name]">
			<xsl:sort select="@name"></xsl:sort>
			<xsl:variable name="content">
				<xsl:apply-templates select="."></xsl:apply-templates>
			</xsl:variable>
			<!-- url de projection du doc -->
			<xsl:variable name="url">
				<xsl:choose>
					<xsl:when test="ancestor::xs:complexType or ancestor::xs:element">
						<xsl:value-of select="@name"/><xsl:text>-</xsl:text><xsl:value-of select="ancestor::*[@name][1]/@name"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="@name"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="element" select="concat( $site, 'elements/', $url)"></xsl:variable>
			<xsl:result-document href="{$element}.xml">
				<xsl:copy-of select="$content"></xsl:copy-of>
			</xsl:result-document>
			<xsl:result-document format="html" href="{$element}.html">
				<xsl:call-template name="sdapa:html">
					<xsl:with-param name="content" select="$content"></xsl:with-param>
					<xsl:with-param name="in-schema-subdir" select="true()"/>
					<xsl:with-param name="output-info" select="false()"/>
				</xsl:call-template>
			</xsl:result-document>
			<xsl:message>
				<xsl:value-of select="$element"></xsl:value-of>
			</xsl:message>
		</xsl:for-each>
		<!-- index des attributs -->
		<xsl:variable name="attributes">
			<index>
				<info>
					<xsl:call-template name="xsdoc:dc"></xsl:call-template>
				</info>
				<sdapa:title>
					<xsl:value-of select="count($schema//xs:attribute[not(@name = preceding::xs:attribute/@name)])"></xsl:value-of> 
          attributs</sdapa:title>
				<xsl:apply-templates select="$schema//xs:attribute[not(@name = preceding::xs:attribute/@name)]" mode="xsdoc:index">
					<xsl:sort select="@name"></xsl:sort>
				</xsl:apply-templates>
			</index>
		</xsl:variable>
		<xsl:result-document href="{$site}indexes/attributes.xml">
			<xsl:copy-of select="$elements"></xsl:copy-of>
		</xsl:result-document>
		<xsl:result-document format="html" href="{$site}indexes/attributes.html">
			<xsl:call-template name="sdapa:html">
				<xsl:with-param name="content" select="$attributes"></xsl:with-param>
				<xsl:with-param name="in-schema-subdir" select="true()"/>
				<xsl:with-param name="output-info" select="false()"/>
			</xsl:call-template>
		</xsl:result-document>
		<xsl:message> -- attributes</xsl:message>
		<!-- documenter les attributs -->
		<xsl:for-each select="$schema//xs:attribute[not(@name = preceding::xs:attribute/@name)]">
			<xsl:variable name="content">
				<xsl:apply-templates select="."></xsl:apply-templates>
			</xsl:variable>
			<xsl:variable name="attribute" select="concat( $site, 'attributes/', @name)"></xsl:variable>
			<xsl:result-document href="{$attribute}.xml">
				<xsl:copy-of select="$content"></xsl:copy-of>
			</xsl:result-document>
			<xsl:result-document format="html" href="{$attribute}.html">
				<xsl:call-template name="sdapa:html">
					<xsl:with-param name="content" select="$content"></xsl:with-param>
					<xsl:with-param name="in-schema-subdir" select="true()"/>
					<xsl:with-param name="output-info" select="false()"/>
				</xsl:call-template>
			</xsl:result-document>
			<xsl:message>
				<xsl:value-of select="$attribute"></xsl:value-of>
			</xsl:message>
		</xsl:for-each>
	</xsl:template>
	<!-- [TODO:URI] -->
	<!--
  bloc de meta commun à peu près commun à tous les fichiers
  fournit un jeu de relations relatives à mettre en info de chaque page
  par défaut toutes les pages sont dans un répertoire (d'où le préfixe en ../)
  sauf la présentation générale du schéma
  
  
-->
	<xsl:template name="xsdoc:dc">
		<xsl:param name="prefix" select="'../'"></xsl:param>
		<relation role="home" uri="{$prefix}index.xml">Accueil</relation>
		<relation role="index" uri="{$prefix}indexes/elements.xml">Eléments</relation>
		<relation role="index" uri="{$prefix}indexes/groups.xml">Groupes</relation>
		<relation role="index" uri="{$prefix}indexes/attributes.xml">Attributs</relation>
		<relation role="contents" uri="{$prefix}guidelines/index.xml">Guides</relation>
		<!-- on recopie le titre du schéma -->
		<xsl:apply-templates select="$schema/xs:schema/xs:annotation/xs:documentation/sdapa:title" mode="xsdoc:copy"></xsl:apply-templates>
		<xsl:apply-templates select="$schema/xs:schema/xs:annotation/xs:documentation/sdapa:date" mode="xsdoc:copy"></xsl:apply-templates>
		<xsl:apply-templates select="xs:annotation/xs:documentation/sdapa:title" mode="xsdoc:copy"></xsl:apply-templates>
	</xsl:template>
	<!--
default mode

   sdapa:concept d'un xs:element, TODO lang, global/local 

document a schema.
process groups in hope that 
  all elements are in a group
  no elements in two groups
   -->
	<!-- défaut, on fait passer ? -->
	<xsl:template match="xs:element[@name] | xs:attribute[@name] | xs:group[@name]">
		<xsl:param name="current" select="."></xsl:param>
		<concept code="{@name}" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.culture.gouv.fr/ns/dapa/1.0 ../schema/sdapa.xsd">
			<info>
				<xsl:call-template name="xsdoc:dc"></xsl:call-template>
				<!-- la navigation générée dépend pour beaucoup de l'ordre rédactionnel du schéma,
    principe, attraper un voisin de même type (élément, attribut ...)
    TODO: effets de bord -->
				<!-- précédent -->
				<xsl:variable name="previous" select=" preceding-sibling::xs:*[local-name()=local-name($current)][@name][1]"></xsl:variable>
				<xsl:if test="$previous">
					<relation role="previous" uri="../{local-name($current)}s/{$previous/@name}.xml">
						<xsl:text>&lt; </xsl:text>
						<xsl:apply-templates select="$previous" mode="xsdoc:markup"></xsl:apply-templates>
					</relation>
				</xsl:if>
				<!-- suivant -->
				<xsl:variable name="next" select=" following-sibling::xs:*[local-name()=local-name($current)][@name][1]"></xsl:variable>
				<xsl:if test="$next">
					<relation role="next" uri="../{local-name($current)}s/{$next/@name}.xml">
						<xsl:apply-templates select="$next" mode="xsdoc:markup"></xsl:apply-templates>
						<xsl:text> &gt;</xsl:text>
					</relation>
				</xsl:if>
			</info>
			<term>
				<xsl:apply-templates select="$current" mode="xsdoc:markup">
					<xsl:with-param name="class" select="true()"></xsl:with-param>
				</xsl:apply-templates>
			</term>
			<xsl:apply-templates select="$current/xs:annotation/xs:documentation/node()" mode="xsdoc:copy"></xsl:apply-templates>
			<!-- case of elements, give type, and attributes -->
			<xsl:variable name="type" select=" .//xs:complexType | .//xs:simpleType | //xs:complexType[@name=$current/@type] | //xs:simpleType[@name=$current/@type] "></xsl:variable>
			<!--
      <format>
        <xsl:value-of select="$type/@name"/>
      </format>
      -->
			<description>
				<title>Parents</title>
				<xsl:call-template name="xsdoc:parents"></xsl:call-template>
			</description>
			<!-- frères -->
			<xsl:if test="local-name($current) != 'attribute'">
				<description>
					<title>Frères</title>
					<xsl:call-template name="xsdoc:brother"></xsl:call-template>
				</description>
			</xsl:if>
			<!-- enfants -->
			<xsl:if test="local-name($current) != 'attribute'">
				<description>
					<title>Enfants</title>
					<xsl:call-template name="xsdoc:child"></xsl:call-template>
				</description>
			</xsl:if>
			<!-- attributs -->
			<xsl:if test="local-name($current) = 'element'">
				<description>
					<title>Attributs</title>
					<xsl:apply-templates select="$type" mode="attribute"></xsl:apply-templates>
				</description>
			</xsl:if>
			<!-- source du schéma -->
			<description>
				<title>Source</title>
				<xml>
					<xsl:apply-templates select="$current" mode="xsdoc:copy"></xsl:apply-templates>
					<xsl:apply-templates select="$type" mode="xsdoc:copy"></xsl:apply-templates>
				</xml>
			</description>
		</concept>
	</xsl:template>
	<!--  ref elements. dont't process xs:group[@ref] -->
	<xsl:template match="xs:element[@ref] | xs:attribute[@ref]">
		<xsl:variable name="name" select="@ref"></xsl:variable>
		<xsl:choose>
			<!-- global first -->
			<xsl:when test="/xs:schema/xs:element[@name=$name]">
				<xsl:apply-templates select="/xs:schema/xs:element[@name=$name]"></xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="/xs:schema//xs:element[@name=$name][1]"></xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!--
  mode child

Get infos from xs:* to give infos on content of elements

-->
	<!-- child call usually from an element -->
	<xsl:template name="xsdoc:child">
		<xsl:param name="current" select="."></xsl:param>
		<xsl:variable name="type" select=" //xs:complexType[@name=$current/@type] | //xs:simpleType[@name=$current/@type] "></xsl:variable>
		<xsl:choose>
			<!-- group -->
			<xsl:when test="xs:sequence|xs:all|xs:choice|xs:attribute|xs:complexType[not(@name)]">
				<xsl:apply-templates mode="child"></xsl:apply-templates>
			</xsl:when>
			<xsl:when test="$type">
				<xsl:apply-templates select="$type" mode="child"></xsl:apply-templates>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<!-- child break default -->
	<xsl:template match="node()" mode="child"></xsl:template>
	<!-- child break element : cross ? -->
	<xsl:template match="xs:element" mode="child">
		<xsl:apply-templates select="." mode="xsdoc:markup"></xsl:apply-templates>
		<xsl:call-template name="xsdoc:quantifier"></xsl:call-template>
	</xsl:template>
	<!-- child cross group -->
	<xsl:template match="xs:group" mode="child">
		<xsl:choose>
			<xsl:when test="@name">
				<xsl:apply-templates select="." mode="xsdoc:markup"></xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates mode="child"></xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:call-template name="xsdoc:quantifier"></xsl:call-template>
	</xsl:template>
	<!-- child cross group reference -->
	<xsl:template match="xs:group[@ref]" mode="child">
		<xsl:variable name="name" select="@ref"></xsl:variable>
		<xsl:apply-templates select="//xs:group[@name=$name]" mode="child"></xsl:apply-templates>
		<xsl:call-template name="xsdoc:quantifier"></xsl:call-template>
	</xsl:template>
	<!-- child cross type, keep mixed content -->
	<xsl:template match="xs:complexType" mode="child">
		<xsl:if test="@mixed='true'">"text" </xsl:if>
		<xsl:apply-templates mode="child"></xsl:apply-templates>
	</xsl:template>
	<!-- child cross complex content -->
	<xsl:template match="xs:complexContent" mode="child">
		<xsl:apply-templates mode="child"></xsl:apply-templates>
	</xsl:template>
	<!-- child break at simple content, text, MAYDO: enumeration ? -->
	<xsl:template match="xs:simpleContent" mode="child">
		<xsl:text>"text"</xsl:text>
	</xsl:template>
	<!-- child cross sequence, choice, all -->
	<xsl:template match="xs:sequence|xs:choice|xs:all" mode="child">
		<xsl:variable name="ponct" select="boolean(xs:sequence[2] |xs:choice[2]|xs:all[2]|xs:group[2]|xs:element)"></xsl:variable>
		<xsl:if test="xs:sequence|xs:choice|xs:all|xs:group|xs:element">
			<xsl:variable name="sep">
				<xsl:choose>
					<xsl:when test="local-name()='sequence'">, </xsl:when>
					<xsl:when test="local-name()='choice'"> |&#160;</xsl:when>
					<xsl:when test="local-name()='all'"> -&#160;</xsl:when>
				</xsl:choose>
			</xsl:variable>
			<xsl:text> (</xsl:text>
			<xsl:for-each select="xs:sequence|xs:choice|xs:all|xs:group|xs:element">
				<xsl:apply-templates select="." mode="child"></xsl:apply-templates>
				<xsl:if test="not(position()=last())">
					<xsl:value-of select="$sep"></xsl:value-of>
				</xsl:if>
			</xsl:for-each>
			<xsl:text>)</xsl:text>
			<xsl:call-template name="xsdoc:quantifier"></xsl:call-template>
		</xsl:if>
	</xsl:template>
	<!-- child quantifier -->
	<xsl:template name="xsdoc:quantifier">
		<xsl:param name="current" select="."></xsl:param>
		<xsl:param name="min">
			<xsl:choose>
				<xsl:when test="not($current/@minOccurs)">1</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$current/@minOccurs"></xsl:value-of>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:param>
		<xsl:param name="max">
			<xsl:choose>
				<xsl:when test="not($current/@maxOccurs)">1</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$current/@maxOccurs"></xsl:value-of>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:param>
		<xsl:choose>
			<xsl:when test="$min=1 and $max=1"></xsl:when>
			<xsl:when test="$min=0 and $max='unbounded'">*</xsl:when>
			<xsl:when test="$min=1 and $max='unbounded'">+</xsl:when>
			<xsl:when test="$min=0 and $max=1">?</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$min"></xsl:value-of>
				<xsl:text>-</xsl:text>
				<xsl:value-of select="$max"></xsl:value-of>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- simple types -->
	<!-- attribute cross attribute group  -->
	<xsl:template match="xs:complexType" mode="attribute">
		<xsl:variable name="me" select="string(@name)"/>
		<xsl:apply-templates select=".//xs:attribute[not(ancestor::xs:element)] | .//xs:attributeGroup[not(ancestor::xs:element)]" mode="attribute"></xsl:apply-templates>
	</xsl:template>
	<xsl:template match="xs:attributeGroup[@ref]" mode="attribute">
		<xsl:param name="current" select="."></xsl:param>
		<xsl:apply-templates select="//xs:attributeGroup[@name=$current/@ref]" mode="attribute"></xsl:apply-templates>
	</xsl:template>
	<!-- maydo give some info on attribute groups ? -->
	<xsl:template match="xs:attributeGroup[@name]" mode="attribute">
		<!--
    <xsl:value-of select="local-name()"/>
    <xsl:text> </xsl:text>
    -->
		<xsl:apply-templates select=".//xs:attribute" mode="attribute"></xsl:apply-templates>
	</xsl:template>
	<xsl:template match="xs:attribute[@ref]" mode="attribute">
		<xsl:param name="current" select="."></xsl:param>
		<xsl:apply-templates select="//xs:attribute[@name=$current/@ref]" mode="attribute"></xsl:apply-templates>
	</xsl:template>
	<!-- value cross attribute -->
	<xsl:template match="xs:attribute[@name]" mode="attribute">
		<xsl:param name="current" select="."></xsl:param>
		<xsl:variable name="type" select=" $schema//xs:simpleType[@name=$current/@type] "></xsl:variable>
		<item>
			<xsl:apply-templates select="$current" mode="xsdoc:markup"></xsl:apply-templates>
			<xsl:text>="</xsl:text>
			<xsl:choose>
				<xsl:when test="$type">
					<xsl:apply-templates select="$type" mode="attribute"></xsl:apply-templates>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="@type"></xsl:value-of>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:text>" </xsl:text>
		</item>
	</xsl:template>
	<xsl:template match="xs:simpleType" mode="attribute">
		<span class="type">
			<xsl:if test="@name">
				<xsl:attribute name="value">
					<xsl:text>type:</xsl:text>
					<xsl:value-of select="@name"></xsl:value-of>
					<xsl:text> </xsl:text>
				</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates mode="attribute"></xsl:apply-templates>
			<xsl:if test="not(xs:union | xs:list)">&#160;; </xsl:if>
		</span>
	</xsl:template>
	<!-- value cross union|list keep an info ? -->
	<xsl:template match="xs:union | xs:list" mode="attribute">
		<xsl:call-template name="xsdoc:values">
			<xsl:with-param name="members" select="@memberTypes"></xsl:with-param>
		</xsl:call-template>
		<xsl:apply-templates mode="attribute"></xsl:apply-templates>
		<xsl:if test="local-name() = 'list' ">&#160;+</xsl:if>
	</xsl:template>
	<xsl:template match="xs:restriction" mode="attribute">
		<xsl:for-each select="xs:enumeration">
			<xsl:apply-templates select="." mode="attribute"></xsl:apply-templates>
			<xsl:if test="not(position()=last())">, </xsl:if>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="xs:enumeration" mode="attribute">
		<xsl:value-of select="@value"></xsl:value-of>
	</xsl:template>
	<!-- value call enumerate simple types from a space separated names -->
	<xsl:template name="xsdoc:values">
		<xsl:param name="members"></xsl:param>
		<xsl:choose>
			<xsl:when test="contains($members, ' ')">
				<xsl:call-template name="xsdoc:simpleType">
					<xsl:with-param name="name" select="substring-before($members, ' ')"></xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="xsdoc:values">
					<xsl:with-param name="members" select="substring-after($members, ' ')"></xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="xsdoc:simpleType">
					<xsl:with-param name="name" select="$members"></xsl:with-param>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- value call enumerate one type -->
	<xsl:template name="xsdoc:simpleType">
		<xsl:param name="name" select="''"></xsl:param>
		<xsl:choose>
			<xsl:when test="//xs:simpleType[@name=$name]">
				<xsl:apply-templates select="//xs:simpleType[@name=$name]" mode="attribute"></xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$name"></xsl:value-of>
				<xsl:text>&#160;; </xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- enumerate elements to markup -->
	<xsl:template name="xsdoc:markups">
		<xsl:param name="content" select="."></xsl:param>
		<xsl:param name="exclude"></xsl:param>
		<xsl:for-each select="$content/xs:group[not(@name = preceding-sibling::*/@name) and not(@name=$exclude)]">
			<xsl:sort select="@name"></xsl:sort>
			<xsl:apply-templates select="." mode="xsdoc:markup"></xsl:apply-templates>
			<xsl:choose>
				<xsl:when test="position()=last()">&#160;; </xsl:when>
				<xsl:otherwise>, </xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
		<xsl:for-each select="$content/xs:element[not(@name = preceding-sibling::*/@name) and not(@name=$exclude)]">
			<xsl:sort select="@name"></xsl:sort>
			<xsl:apply-templates select="." mode="xsdoc:markup"></xsl:apply-templates>
			<xsl:choose>
				<xsl:when test="position()=last()">&#160;; </xsl:when>
				<xsl:otherwise>, </xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>
	<!--
  mode parent

Get infos from xs:* to give infos on content of elements

TODO: what about elements declared in a type in an element ?

TODO: abstract elements
-->
	<!-- parent call from an element or a group - collect matching 
  buggy ? what about groups ?
  -->
	<xsl:template name="xsdoc:parents">
		<xsl:param name="current" select="."></xsl:param>
		<!-- Une variable pour déterminer s'il s'agit d'une définition locale -->
		<xsl:variable name="local">
			<xsl:choose>
				<xsl:when test="$current/ancestor::xs:element or $current/ancestor::xs:complexType">
					<xsl:value-of select="'yes'"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="'no'"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="parents">
			<xsl:choose>
				<xsl:when test="$local = 'yes'">
					<xsl:apply-templates select="ancestor::*[@name][1]" mode="xsdoc:parent"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="//xs:*[local-name()=local-name($current)] [@ref=$current/@name or @name=$current/@name]" mode="xsdoc:parent"></xsl:apply-templates>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:call-template name="xsdoc:markups">
			<xsl:with-param name="content" select="$parents"></xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	<!-- parent break default -->
	<xsl:template match="node()" mode="xsdoc:parent"></xsl:template>
	<!-- mode="xsdoc:parent" pass to parent -->
	<xsl:template match="xs:extension | xs:complexContent | xs:attribute | xs:attributeGroup[@ref]" mode="xsdoc:parent">
		<xsl:apply-templates select=".." mode="xsdoc:parent"></xsl:apply-templates>
	</xsl:template>
	<xsl:template match="xs:attributeGroup[@name]" mode="xsdoc:parent">
		<xsl:param name="current" select="."></xsl:param>
		<xsl:apply-templates select="//xs:*[local-name()=local-name($current)] [@ref=$current/@name]" mode="xsdoc:parent"></xsl:apply-templates>
	</xsl:template>
	<!-- parent cross element -->
	<xsl:template match="xs:element" mode="xsdoc:parent">
		<xsl:apply-templates select="ancestor::xs:*[local-name()='group' or local-name()='complexType'][1]" mode="xsdoc:parent"></xsl:apply-templates>
	</xsl:template>
	<!-- parent break complexType - copy releving elements -->
	<xsl:template match="xs:complexType" mode="xsdoc:parent">
		<xsl:param name="current" select="."></xsl:param>
		<xsl:copy-of select="ancestor::xs:element[1] | //xs:element[@name and @type=$current/@name]"></xsl:copy-of>
	</xsl:template>
	<!-- parent cross group@name -->
	<xsl:template match="xs:group[@name]" mode="xsdoc:parent">
		<xsl:param name="current" select="."></xsl:param>
		<xsl:apply-templates select="//xs:group[@ref=$current/@name]" mode="xsdoc:parent"></xsl:apply-templates>
	</xsl:template>
	<!-- parent cross group@ref -->
	<xsl:template match="xs:group[@ref]" mode="xsdoc:parent">
		<xsl:param name="current" select="."></xsl:param>
		<xsl:apply-templates select="ancestor::xs:*[local-name()='group' or local-name()='complexType'][1]" mode="xsdoc:parent"></xsl:apply-templates>
	</xsl:template>
	<!--

  mode brother

enumerate elements or groups, which could appears at same level of a given one
logic :
1) get all complexType where element[@ref] or container group is refered
2) get elements or groups, children of theese types

Test if interesting info provided
-->
	<!-- brother call, from element@name ? -->
	<xsl:template name="xsdoc:brother">
		<xsl:param name="current" select="."></xsl:param>
		<xsl:variable name="content">
			<xsl:apply-templates select="." mode="_brother"></xsl:apply-templates>
		</xsl:variable>
		<!-- wash from same element ? -->
		<xsl:call-template name="xsdoc:markups">
			<xsl:with-param name="content" select="$content"></xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	<!-- parse the types -->
	<xsl:template match="xs:element | xs:group" mode="_brother">
		<xsl:variable name="current" select="."></xsl:variable>
		<!-- always, if current is in a type, parse the type -->
		<xsl:apply-templates select="ancestor::xs:complexType[1] | ancestor::xs:element[1]" mode="brother"></xsl:apply-templates>
		<xsl:choose>
			<!-- if current is in a group, find types where the group is in -->
			<xsl:when test="ancestor::xs:group[@name][1]">
				<xsl:apply-templates select="ancestor::xs:group[@name][1]" mode="_brother"></xsl:apply-templates>
			</xsl:when>
			<!-- current have a name, try the ref -->
			<xsl:when test="@name and not(ancestor::xs:complexType or ancestor::xs:element)">
				<xsl:apply-templates select="//xs:*[local-name()=local-name($current) and @ref=$current/@name]" mode="_brother"></xsl:apply-templates>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<!-- brother cross complexType - copy of children, but not descendant -->
	<xsl:template match="xs:complexType | xs:choice | xs:all | xs:sequence" mode="brother">
		<!-- maybe buggy if complexType embed elements in local type of element -->
		<xsl:apply-templates mode="brother"></xsl:apply-templates>
	</xsl:template>
	<!-- brother break group - give group reference is enough -->
	<xsl:template match="xs:group[@name] | xs:element[@name]" mode="brother">
		<xsl:copy-of select="."></xsl:copy-of>
	</xsl:template>
	<xsl:template match="xs:group[@ref] | xs:element[@ref]" mode="brother">
		<xsl:param name="current" select="."></xsl:param>
		<xsl:copy-of select="//xs:*[local-name()=local-name($current) and @name=$current/@ref]"></xsl:copy-of>
	</xsl:template>
	<!--
Pour un concept allégé en index
-->
	<xsl:template match="*" mode="xsdoc:index"></xsl:template>
	<xsl:template match="xs:*[@name]" mode="xsdoc:index">
		<xsl:param name="current" select="."></xsl:param>
		<!-- Le nom de code dépend du fait qu'on soit un élément local ou global -->
		<xsl:variable name="code">
			<xsl:choose>
				<xsl:when test="self::xs:element and (ancestor::complexType or ancestor::element)">
					<xsl:value-of select="@name"/><xsl:text>-</xsl:text><xsl:value-of select="ancestor::*[@name][1]/@name"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="@name"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<concept code="{$code}">
			<xsl:for-each select="@name">
				<xsl:attribute name="class">
					<xsl:value-of select="&letter1;"></xsl:value-of>
				</xsl:attribute>
			</xsl:for-each>
			<term>
				<xsl:apply-templates select="$current" mode="xsdoc:markup">
					<xsl:with-param name="class" select="true()"></xsl:with-param>
				</xsl:apply-templates>
			</term>
			<type>
				<xsl:value-of select="local-name($current)"></xsl:value-of>
			</type>
			<xsl:apply-templates select="$current/xs:annotation/xs:documentation/sdapa:title" mode="xsdoc:copy"></xsl:apply-templates>
		</concept>
	</xsl:template>
	<!-- mode docstrip - copie des noeuds du schéma, sans documentation, sans commentaires (?) -->
	<!-- xscopy cross -->
	<xsl:template match="node()|@*" mode="xsdoc:copy">
		<xsl:copy>
			<xsl:apply-templates mode="xsdoc:copy"></xsl:apply-templates>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="xs:*" mode="xsdoc:copy">
		<xsl:copy>
			<xsl:apply-templates select="node()|@*" mode="xsdoc:copy"></xsl:apply-templates>
		</xsl:copy>
	</xsl:template>
	<!-- xscopy break - noeuds externes et doc -->
	<xsl:template match="*" mode="xsdoc:copy"></xsl:template>
	<xsl:template match="xs:annotation | xs:documentation | xs:appinfo" mode="xsdoc:copy"></xsl:template>
	<!-- copy sdapa:* - reduce @xmlns:* -->
	<xsl:template match="sdapa:*" mode="xsdoc:copy">
		<xsl:element name="{local-name()}" namespace="{namespace-uri()}">
			<xsl:apply-templates select="node() | @*" mode="xsdoc:copy"></xsl:apply-templates>
		</xsl:element>
	</xsl:template>
	<xsl:template match="gml:*" mode="xsdoc:copy">
		<xsl:element name="{local-name()}" namespace="{namespace-uri()}">
			<xsl:apply-templates select="node() | @*" mode="xsdoc:copy"></xsl:apply-templates>
		</xsl:element>
	</xsl:template>
	<!-- mode="xsdoc:copy" que faire des termes supplémentaires dans une définition ? -->
	<xsl:template match="sdapa:term[ancestor::code]" mode="xsdoc:copy"></xsl:template>
	<!-- 
mode markup
   -->
	<xsl:template match="node()" mode="xsdoc:markup">
		<xsl:apply-templates mode="xsdoc:markup"></xsl:apply-templates>
	</xsl:template>
	<!-- cross ref to name -->
	<xsl:template match="xs:element[@ref] | xs:attribute[@ref] | xs:attributeGroup[@ref] | xs:group[@ref]" mode="xsdoc:markup">
		<xsl:param name="type" select="local-name()"></xsl:param>
		<xsl:variable name="current" select="."></xsl:variable>
		<xsl:apply-templates select="/*/xs:*[local-name()=local-name($current)][@name=$current/@ref][1]" mode="xsdoc:markup">
			<xsl:with-param name="type" select="$type"></xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>
	<xsl:template match="xs:element[@name] | xs:attributeGroup[@name] | xs:attribute[@name] | xs:group[@name]" mode="xsdoc:markup">
		<xsl:param name="class"></xsl:param>
		<xsl:param name="index"></xsl:param>
		<!-- title could be localize name="{@name}" -->
		<markup value="{local-name()} {@name} - {xs:annotation/xs:documentation/sdapa:title}">
			<!-- généralement, ne pas classer en cas d'élément, sinon illisible -->
			<xsl:choose>
				<xsl:when test="$class">
					<xsl:attribute name="class">
						<xsl:value-of select="local-name()"></xsl:value-of>
					</xsl:attribute>
				</xsl:when>
				<xsl:when test="local-name()='element'"></xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="class">
						<xsl:value-of select="local-name()"></xsl:value-of>
					</xsl:attribute>
				</xsl:otherwise>
			</xsl:choose>
			<!-- [TODO:URI] donner une uri calculée ici -->
			<xsl:attribute name="uri">
				<xsl:if test="not($index)">../</xsl:if>
				<!-- On ajoute le nom d'un parent lorsque c'est une définition locale -->
				<xsl:variable name="local">
					<xsl:if test="self::xs:element and (ancestor::xs:complexType or ancestor::xs:element)">
						<xsl:text>-</xsl:text>
						<xsl:value-of select="ancestor::*[@name][1]/@name"/>
					</xsl:if>
				</xsl:variable>
				<xsl:value-of select="concat(local-name(), 's/', @name, $local, '.xml')"></xsl:value-of>
			</xsl:attribute>
			<xsl:value-of select="@name"></xsl:value-of>
		</markup>
		<!-- On ajoute une partie locale si nécessaire -->
		<xsl:if test="ancestor::xs:complexType or ancestor::xs:element">
			<xsl:text>-</xsl:text>
			<xsl:value-of select="ancestor::*[@name][1]/@name"/>
			<xsl:text></xsl:text>
		</xsl:if>
	</xsl:template>
	<!-- [TODO:URI] -->
	<!-- surcharges de la présentation de source html, pour y apporter des liens clicables
  avec des urls connues seulement depuis ici -->
	<xsl:template match=" xs:element/@ref | xs:element/@name | xs:attribute/@name | xs:attribute/@ref | xs:group/@name | xs:group/@ref " mode="xml:html">
		<xsl:call-template name="xml:html-att">
			<xsl:with-param name="attvalue-href" select="concat('../', local-name(..), 's/', ., '.html')"></xsl:with-param>
			<xsl:with-param name="attvalue-title"></xsl:with-param>
			<xsl:with-param name="attname-href"></xsl:with-param>
			<xsl:with-param name="attname-title"></xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="sdapa:*" mode="xml:html">
		<xsl:call-template name="xml:html-el">
			<xsl:with-param name="elname-href" select="concat('../elements/', local-name(.), '.html')"></xsl:with-param>
			<xsl:with-param name="elname-title"></xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="sdapa:*/@*" mode="xml:html">
		<xsl:call-template name="xml:html-att">
			<xsl:with-param name="attname-href" select="concat('../attributes/', local-name(.), '.html')"></xsl:with-param>
			<xsl:with-param name="attname-title"></xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	<!--
  overrides of sdapa.xsl
  -->
	<!--
  <xsl:template match="sdapa:markup">
    <a href="#{.}">
      <code>
        <xsl:call-template name="atts"/>
        <xsl:apply-templates/>
      </code>
    </a>
  </xsl:template>
  -->
	<!-- TODO: reconstituer un schéma plat, avec inclusions, redéfinitions... -->
	<xsl:template match="xsdoc:*/@schema" name="xsdoc:schema">
		<xsl:copy-of select="document(., $root)"></xsl:copy-of>
	</xsl:template>
</xsl:stylesheet>
