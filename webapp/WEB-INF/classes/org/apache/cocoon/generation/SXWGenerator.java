/*
 * Copyright 2004 xfolio.org
 * Licence : CeCILL
 *
 */
package org.apache.cocoon.generation;

import java.io.IOException;
import org.apache.cocoon.ProcessingException;
import org.apache.cocoon.caching.CacheableProcessingComponent;
import org.apache.cocoon.components.source.SourceUtil;
import org.apache.cocoon.xml.IncludeXMLConsumer;
import org.xml.sax.SAXException;
import org.xml.sax.helpers.AttributesImpl;
/**

 = WHAT =



 Open Office Writer generation, one more time.
 The issue is discussed in more than one place (sometimes by me)
 this is my last cocoon solution to have a flat oo xml file,
 with __caching__ !


 = WHO =

 *[[Anchor(FG)]] FredericGlorieux [[MailTo(frederic DOT glorieux AT xfolio DOT org)]]

 = STATUS =

 It works for me, in hope this helps others.
 For Cocoon 2.1.5
 After more tests, could be proposed as a java generator in default cocoon ?

 = CHANGES =

 * 2004-06-30:[#FG]  Creation

 = HOW =

 {{{
 <map:match pattern="**.oo">
 <map:generate type="xsp" src="actions/oo.xsp">
 <map:parameter name="sxw" value="{myfolder}{1}.sxw"/>
 </map:generate>
 <map:serialize type="xml"/>
 </map:match>
 }}}

 = WHY =

 I need an OpenOffice generator, not only to provide an HTML view or some other transformation,
 but also to extract metadata on vast amount of documents. So, performances is an issue. I read all I can about OpenOffice generation and search for the best solution which should be
 * easy
 * fast
 * cacheable
 This one is still implemented as an XSP, because it's easier for testing, and for people to integrate in their cocoon apps. But in fact, best could be a Cocoon generator.

 == Forget ==

 * default src="jar:myzip!myentry.xml" seems to load the file entry in memory, but never remember the changes (isnt'it the goal to load a class from a jar one type ?)

 == Forrest ==

 The best I found for now come from Forrest, using the new zip protocol from cocoon, able to resolve things like src="zip://content.xml@{folder}/test.sxw". This is a part of the trick. The problem of their solution is to use a cinclude transformer, which is not cacheable. I mean, you need to regenerate your aggregation each time it is requested. This is not a big problem in Forrest context (essentially generate a site), but on a real life server...

 Their solution looks like that

 {{{
 <map:generate src="transform/cocoon/dummy.xml"/>
 <map:transform src="transform/cocoon/sxw2oo.xsl">
 <map:parameter name="src" value="{context-attr:xfolio.efolder}{1}.sxw"/>
 </map:transform>
 <map:transform type="cinclude"/>
 <map:serialize type="xml"/>
 }}}

 The dummy.xml is only there because you need something to begin with pure cocoon.
 The job is done by the XSL, to write something like that.
 {{{
 <office:document xmlns:**>
 <c:include select="...">
 <xsl:attribute name="src">zip://meta.xml@<xsl:value-of select="$src"/></xsl:attribute>
 </c:include>
 <c:include select="...">
 <xsl:attribute name="src">zip://content.xml@<xsl:value-of select="$src"/></xsl:attribute>
 </c:include>
 </office:document>
 }}}

 Problems are
 * an Xpath include is expensive (all document need to be loaded as DOM)
 * Cinclude (like Xinclude) haven't seem to be cacheable for me

 You may say, try a {{{<map:agreggate/>}}}... I tried, and produce so much problems
 of validation that I stopped.

 == oo.xsp ==

 The attached xsp do quite the same job as the excellent Forrest solution,
 with these differences
 * the generator is controlled and know the files on which check changes : essentially the sxw file (and also the xsp, for debug)


 * performances
 * direct pipe cost ~10 ms
 * xinclude cost ~160ms
 * cinclude ~320ms
 * SXWGenerator cost ~200ms on first call, but is _cached_ (~40 ms on second call)




 = REFERENCES =

 * [http://svn.apache.org/viewcvs.cgi/forrest/trunk/src/core/context/forrest.xmap?root=Apache-SVN Forrest Open Office]
 * [http://wiki.apache.org/cocoon/XSPCachingWithCocoonHEAD XSPCaching]
 * [http://wiki.apache.org/cocoon/JarProtocolExample  JarProtocolExample]
 * [http://wiki.apache.org/cocoon/OpenOfficeGeneration OpenOfficeGeneration]



 */
public class SXWGenerator extends FileGenerator implements CacheableProcessingComponent {

    public void generate() throws IOException, SAXException, ProcessingException {
        try {
            if (getLogger().isDebugEnabled()) {
                getLogger().debug("Source " + super.source + " resolved to " + this.inputSource.getURI());
            }
            this.contentHandler.startDocument();
/* FIXME useful ?
            this.contentHandler.startPrefixMapping("office", "http://openoffice.org/2000/office");
*/          

            super.contentHandler.startElement("http://openoffice.org/2000/office", "document", "office" + ':' + "document", new AttributesImpl());

            //      from org.apache.cocoon.transformation.XIncludeTransformer
            SourceUtil.toSAX(super.resolver.resolveURI("zip://meta.xml@" + this.inputSource.getURI()),
                    new IncludeXMLConsumer(this.contentHandler));
            SourceUtil.toSAX(super.resolver.resolveURI("zip://content.xml@" + this.inputSource.getURI()),
                    new IncludeXMLConsumer(this.contentHandler));
            
            super.contentHandler.endElement("http://openoffice.org/2000/office", "document", "office" + ':' + "document");
            this.contentHandler.endDocument();
            
        } catch (SAXException e) {
            SourceUtil.handleSAXException(this.inputSource.getURI(), e);
        }
    }
}