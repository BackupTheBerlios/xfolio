/*
 * Created on 5 mars 2004 (c) strabon.org GPL frederic.glorieux@ajlsm.com
 */
package org.xfolio.cocoon.generation;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.net.MalformedURLException;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Date;
import java.util.Map;
import org.apache.avalon.framework.parameters.Parameters;
import org.apache.cocoon.ProcessingException;
import org.apache.cocoon.components.source.SourceUtil;
import org.apache.cocoon.environment.ObjectModelHelper;
import org.apache.cocoon.environment.SourceResolver;
import org.apache.cocoon.generation.DirectoryGenerator;
import org.apache.cocoon.util.FileFormatException;
import org.apache.cocoon.util.ImageProperties;
import org.apache.cocoon.util.ImageUtils;
import org.apache.cocoon.xml.IncludeXMLConsumer;
import org.apache.excalibur.source.Source;
import org.xfolio.file.FileComparator;
import org.xfolio.file.FileUtils;
import org.xml.sax.SAXException;
import org.apache.cocoon.util.NetUtils;
/**
 * <b>Extends DirectoryGenerator to replace default attributes and add nested
 * elements </b>-
 * 
 * This generator accept the same parameters as the default DirectoryGenerator
 * (depth, includes, excludes...)
 * 
 * This generator assume that the files listed will be served by cocoon with the
 * same hierarchy.
 * 
 * <pre>
 * 
 *  
 *   
 *    
 *     
 *      
 *       
 *        
 *         &lt;dir:file modified=&quot;2004-06-30H20:15:26&quot; name=&quot;index_fr.sxw&quot; radical=&quot;index&quot; xml:lang=&quot;fr&quot; extension=&quot;sxw&quot; type=&quot;application/vnd.sun.xml.writer&quot; href=&quot;tests/O1%20Section/index_fr&quot; length=&quot;13236&quot;&gt;
 *         	&lt;!-- included XML metadata answering to URI cocoon:/tests/O1%20Section/index_fr.xfoliodir --&gt;
 *         &lt;/dir:file&gt;
 *         
 *        
 *       
 *      
 *     
 *    
 *   
 *  
 * </pre>
 * 
 * modified date is provide in XML format name is detailed in radical, lang,
 * extension according to XFolio naming convention type/mime given by the
 * web.xml of the servlet href, a target relative to the generated directory
 * (useful for a autotoc for example)
 * 
 * <p>
 * <strong>caching </strong>- The cache key of this generator is made of all the
 * listed files, even the one used to add info about a directory. So the XML is
 * generated only if one file used changes. Good practice is of course to
 * include also cacheable records. A detail, if you change a pipeline generating
 * meta record, this global directory will not be informed till it is
 * regenarated (for example after a touche of only one file in the scope).
 * </p>
 * 
 * <p>
 * <strong>caching </strong>-
 * </p>
 * 
 * @author <a href="mailto:frederic.glorieux@ajlsm.com">Glorieux, Frédéric </a>
 * @version CVS $Id: MetaDirectoryGenerator.java,v 1.2 2004/08/23 22:43:19
 *          glorieux Exp $
 */
public class MetaDirectoryGenerator extends DirectoryGenerator {

    /* from org.apache.cocoon.generation.ImageDirectoryGenerator */
    protected static String    WIDTH         = "width";
    protected static String    HEIGHT        = "height";
    protected static String    COMMENT       = "comment";
    protected static String    TYPE          = "type";
    /** A date formatter */
    protected SimpleDateFormat dateFormatter = new SimpleDateFormat("yyyy-MM-dd' 'HH:mm:ss");
    /** the base directory from which to work and resolve */
    protected String           base;
    /** the URI dir, relative to sitemap */
    protected String           branch;
    /** the domain to build absolute URIs */
    protected String           domain;
    /** the requested radical */
    protected String           radical;

    /**
     * Disposable
     */
    public void dispose() {
        if (this.manager != null) {
        }
        super.dispose();
    }

    /**
     * Set the request parameters. Must be called before the generate method.
     * Extends DirectoryGenerator to set some specific properties
     * <ul>
     * <li>this.branch = the SitemapURI parent when called</li>
     * <li></li>
     * </ul>
     * 
     * @param resolver
     *            the SourceResolver object
     * @param objectModel
     *            a <code>Map</code> containing model object
     * @param src
     *            the directory to be XMLized specified as src attribute on
     *            &lt;map:generate/>
     * @param par
     *            configuration parameters
     */
    public void setup(SourceResolver resolver, Map objectModel, String src, Parameters par) throws ProcessingException,
            SAXException, IOException {
        super.setup(resolver, objectModel, src, par);
        // base should be a directory from here
        this.base = new File(src).toURI().normalize().toString();
        // this.branch is used to resolve the cocoon:/ uri below
        this.branch = "/" + ObjectModelHelper.getRequest(objectModel).getSitemapURI();
        this.branch = this.branch.substring(0, this.branch.lastIndexOf("/")) + "/";
        this.domain = (String) ObjectModelHelper.getContext(objectModel).getAttribute("xfolio.domain");
    }

    /**
     * Extends the <code>setNodeAttributes</code> method from the
     * <code>DirectoryGenerator</code> by adding width, height and comment
     * attributes if the path is a GIF or a JPEG file.
     * 
     * And some more useful Xfolio information ("lang", "radical", "branch"
     * ...).
     * 
     * TODO: previous / next
     *  
     */
    protected void setNodeAttributes(File path) throws SAXException {
        // unplug for better values
        // super.setNodeAttributes(path);
        attributes.clear();
        // write attributes
        if (path.equals(new File(this.base))) {
            if (check(this.branch)) attributes.addAttribute("", "branch", "branch", "CDATA", this.branch);
            attributes.addAttribute("", "generated", "generated", "CDATA", dateFormatter.format(new Date()));
            if (check(this.domain)) attributes.addAttribute("", "domain", "domain", "CDATA", this.domain);
        }
        if (this.isRequestedDirectory) {
            attributes.addAttribute("", "requested", "requested", "CDATA", "true");
            this.isRequestedDirectory = false;
        }
        attributes.addAttribute("", "name", "name", "CDATA", path.getName());
        String value;
        value = FileUtils.getRadical(path);
        if (check(value)) {
            attributes.addAttribute("", "radical", "radical", "CDATA", value);
            if (value.equals(this.radical)) attributes.addAttribute("", "selected", "selected", "CDATA", "selected");
        }
        value = FileUtils.getLang(path);
        if (check(value))
                attributes.addAttribute("http://www.w3.org/XML/1998/namespace", "lang", "xml:lang", "CDATA", value);
        value = FileUtils.getExtension(path);
        if (check(value)) attributes.addAttribute("", "extension", "extension", "CDATA", value);
        // prefer servlet level to resolve
        // String type = MIMEUtils.getMIMEType(extension);
        value = ObjectModelHelper.getContext(objectModel).getMimeType(path.getName());
        if (check(value)) attributes.addAttribute("", TYPE, TYPE, "CDATA", value);
        value = NetUtils.relativize(this.base, path.toURI().normalize().toString());
        attributes.addAttribute("", "href", "href", "CDATA", value);
        attributes.addAttribute("", "modified", "modified", "CDATA", dateFormatter
                .format(new Date(path.lastModified())));
        attributes.addAttribute("", "length", "length", "CDATA", "" + path.length());
        if (path.isDirectory()) { return; }
        String extension = FileUtils.getExtension(path);
        if ("jpg".equals(extension) || "png".equals(extension)) try {
            ImageProperties p = ImageUtils.getImageProperties(path);
            if (p != null) {
                if (getLogger().isDebugEnabled()) {
                    getLogger().debug(String.valueOf(path) + " = " + String.valueOf(p));
                }
                attributes.addAttribute("", WIDTH, WIDTH, "CDATA", String.valueOf(p.width));
                attributes.addAttribute("", HEIGHT, HEIGHT, "CDATA", String.valueOf(p.height));
                // bug on some chars in jpeg comments
                /*
                 * if (p.comment != null) attributes.addAttribute("",
                 * COMMENT, COMMENT, "CDATA",
                 * String.valueOf(p.comment));
                 */
            }
        } catch (FileFormatException e) {
            throw new SAXException(e);
        } catch (FileNotFoundException e) {
            throw new SAXException(e);
        } catch (IOException e) {
            throw new SAXException(e);
        }
    }

    /**
     * <b>Extends the startNode() method of the DirectoryGenerator. </b>-
     * 
     * Idea is to include a generated file from sitemap with an URI like
     * cocoon:/{branch}{fileRadical}.xfoliodir App developper could then provide
     * the nicest records he can from source and XSL
     * 
     * In case of directory, the best source files to inform it will be searched
     * 1) index files (what ever the format or the lang extension) 2) the first
     * files with the same radical
     * 
     * @param nodeName
     *            the node currently processing
     * @param path
     *            the file path
     * 
     * @throws SAXException
     *             in case of errors
     */
    protected void startNode(String nodeName, File path) throws SAXException {
        // open a <dir:file> or a <dir:directory>
        if (this.validity != null) {
            this.validity.addFile(path);
        }
        setNodeAttributes(path);
        super.contentHandler.startElement(URI, nodeName, PREFIX + ':' + nodeName, attributes);
        try {
            if (path.isFile()) includeMeta(path);
        } catch (IOException e) {
            // do something ?
        }
    }

    /**

     Adds a single node to the generated document. If the path is a directory,
     and depth is greater than zero, then recursive calls are made to add
     nodes for the directory's children.

     Even if depth is zero, directory will nest i18n "welcome" paths to get
     minimum meta on it. The recursive call will put all "index" file in the
     beginning as meta of a directory.

     * @param path
     *            the file/directory to process
     * @param depth
     *            how deep to scan the directory
     * @throws SAXException
     *             if an error occurs while constructing nodes
     */
protected void addPath(File path, int depth) throws SAXException {
        if (!isIncluded(path) || isExcluded(path)) {
            // stop here
        }
        if (path.isFile()) {
            startNode(FILE_NODE_NAME, path);
            endNode(FILE_NODE_NAME);
        } 
        else if (path.isDirectory()) {
            startNode(DIR_NODE_NAME, path);
            // order the files
            File contents[] = path.listFiles();
            Arrays.sort(contents, new FileComparator());
            // if last leave of a tree or root directory, insert welcome files
            if (depth < 1) addWelcome(path);
            if (depth > 0) {
                for (int i = 0; i < contents.length; i++) {
                    if (false) ;
                    else if (!isIncluded(contents[i]) || isExcluded(contents[i]));
                    /*
                    // here recursive insert of toc from this generator
                    // let's bet this pipe is accessible from 
                    // don't forget to add children to the cache key
                    // problem will be, no stop down
                    else if (contents[i].isDirectory()) {
                        String file = contents[i].toURI().normalize().toString();
                        String uri = NetUtils.relativize(this.base, file) + "toc.meta";
                        uri = "cocoon:/" + this.branch + uri;
                        Source rdf = null;
                        // FIXME will I have some problems of refreshing ?
                        recursiveAddKey(path, depth);
                        // System.out.println(this.source + " " + uri);
                        try {
            	            rdf = super.resolver.resolveURI(uri);
                            SourceUtil.toSAX(rdf, new IncludeXMLConsumer(this.contentHandler));
                        } catch (Exception e) {
                        // should sent an exception if source not found
                            throw new SAXException(e);
                        }
                    }
                    */ 
                    else {
                        addPath(contents[i], depth - 1);
                    }
                }
            }
            endNode(DIR_NODE_NAME);
        } else {
            // what else ?
        }
    }

/**

Adds a file/directory path to cache key.


@param path the file/directory to process
@param depth  how deep to scan the directory

*/
	public void recursiveAddKey(File path, int depth) {
	    if (false);
	    else if (depth < 1);
        else if (!isIncluded(path) || isExcluded(path));
        else if (path.isDirectory()) {
            if (this.validity != null) this.validity.addFile(path);
            File contents[] = path.listFiles();
            for (int i = 0; i < contents.length; i++) {
                if (isIncluded(contents[i]) && !isExcluded(contents[i])) {
                    recursiveAddKey(contents[i], depth - 1);
                }
            }
        }
        else {
            if (this.validity != null) this.validity.addFile(path);
        }
	}

    public void addWelcome(File path) throws SAXException {
        if (!path.isDirectory()) return;
        File contents[] = path.listFiles();
        Arrays.sort(contents, new FileComparator());
        // insert the welcome files
        // may have strange effects in case of nested empty directories ?
        String welcome = null;
        String radical = "";
        for (int i = 0; i < contents.length; i++) {
            if (isIncluded(contents[i]) && !isExcluded(contents[i])) {
                radical = FileUtils.getRadical(contents[i]);
                // should be another radical here
                if (welcome != null && !welcome.equals(radical)) break;
                if (welcome == null) welcome = radical;
                addPath(contents[i], depth - 1);
            }
        }
    }

    /**
     * <b>Include a meta XML file given by sitemap </b>-
     * 
     * This generator suppose that all files
     */
    public void includeMeta(File path) throws SAXException, IOException {
        String radical = FileUtils.getRadical(path);
        // careful here, break if there's forbidden name which are
        // toc, dir or you will have infinite loop
        if ("dir".equals(radical) || "toc".equals(radical)) return;
        // get relative
        String file = path.toURI().normalize().toString();
        String uri = NetUtils.relativize(this.base, file);
        // may break in cas of name without extensions ?
        int dot = uri.lastIndexOf(".");
        if (dot > -1 && dot > uri.lastIndexOf("/")) {
            uri = uri.substring(0, dot) + ".meta";
            Source rdf = null;
            try {
                // FIXME, are there's a strange loop in some cases ? example
                // cocoon://
                // absolute cocoon link
                uri = "cocoon:/" + this.branch + uri;
                rdf = super.resolver.resolveURI(uri);
                SourceUtil.toSAX(rdf, new IncludeXMLConsumer(this.contentHandler));
            } catch (MalformedURLException e) {
                getLogger().debug(
                        "xfolioDirectoryGenerator " + e.getLocalizedMessage() + " file:" + path + " uri:"
                            + ObjectModelHelper.getRequest(objectModel).getSitemapURI());
            } catch (IOException e) {
                getLogger().debug(
                        "xfolioDirectoryGenerator " + e.getLocalizedMessage() + " file:" + path + " uri:"
                            + ObjectModelHelper.getRequest(objectModel).getSitemapURI());
            } catch (ProcessingException e) {
                getLogger().debug(
                        "xfolioDirectoryGenerator " + e.getLocalizedMessage() + " file:" + path + " uri:"
                            + ObjectModelHelper.getRequest(objectModel).getSitemapURI());
            } catch (Exception e) {
                getLogger().debug(
                        "xfolioDirectoryGenerator " + e.getLocalizedMessage() + " file:" + path + " uri:"
                            + ObjectModelHelper.getRequest(objectModel).getSitemapURI());
            } finally {
                if (rdf != null) this.resolver.release(rdf);
            }
        }
    }

    private boolean check(String s) {
        return (s != null && !"".equals(s));
    }
}