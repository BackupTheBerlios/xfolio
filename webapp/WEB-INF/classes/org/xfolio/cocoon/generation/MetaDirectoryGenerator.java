/*
 * Created on 5 mars 2004 (c) strabon.org GPL frederic.glorieux@ajlsm.com
 */
package org.xfolio.cocoon.generation;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.net.MalformedURLException;
import java.text.SimpleDateFormat;
import java.util.Comparator;
import java.util.Date;
import java.util.Map;
import java.util.Arrays;

import org.apache.avalon.framework.parameters.Parameters;
import org.apache.avalon.framework.service.ServiceException;
import org.apache.avalon.framework.service.ServiceManager;
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
import org.xml.sax.SAXException;
/**
 * <b> Extends DirectoryGenerator to replace default attributes and add nested elements </b> -
 * 
 * This generator accept the same parameters as the default DirectoryGenerator
 * (depth, includes, excludes...)
 * 
 * This generator assume that the files listed will be served by cocoon with the same hierarchy. 
 *  
 * <pre>
 * &lt;dir:file modified="2004-06-30H20:15:26" name="index_fr.sxw" radical="index" xml:lang="fr" extension="sxw" type="application/vnd.sun.xml.writer" href="tests/O1%20Section/index_fr" length="13236"&gt;
 * 	<!-- included XML metadata answering to URI cocoon:/tests/O1%20Section/index_fr.xfoliodir -->
 * &lt;/dir:file&gt;
 * </pre>
 * 
 * modified date is provide in XML format
 * name is detailed in radical, lang, extension according to XFolio naming convention
 * type/mime given by the web.xml of the servlet
 * href, a target relative to the generated directory (useful for a autotoc for example)
 * 
 * <p>
 *   <strong>caching</strong> -
 * 	 The cache key of this generator is made of all the listed files, even the one used
 * 	 to add info about a directory. So the XML is generated only if one file used changes.
 *   Good practice is of course to include also cacheable records.
 * 	 A detail, if you change a pipeline generating meta record, this global directory will
 *   not be informed till it is regenarated (for example after a touche of only one file in
 *   the scope). 
 * </p>
 * 
 * <p>
 *   <strong>caching</strong> -
 * </p>
 * 
 * @author <a href="mailto:frederic.glorieux@ajlsm.com">Glorieux, Frédéric </a>
 * @version CVS $Id: MetaDirectoryGenerator.java,v 1.1 2004/04/30 16:49:48
 *          frederic Exp $
 */
final public class MetaDirectoryGenerator extends DirectoryGenerator {
    /* from org.apache.cocoon.generation.ImageDirectoryGenerator */
    protected static String WIDTH = "width";
    protected static String HEIGHT = "height";
    protected static String COMMENT = "comment";
    protected static String TYPE = "type";
    /** A date formatter */
    protected SimpleDateFormat dateFormatter = new SimpleDateFormat(
            "yyyy-MM-dd'H'HH:mm:ss");
    /** the URI dir, relative to sitemap */
    protected String branch;
    /** the domain to build absolute URIs */
    protected String domain;
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
     * 	<li>this.branch = the SitemapURI parent when called</li>
     *  <li></li> 
     * </ul>
     *
     * @param resolver     the SourceResolver object
     * @param objectModel  a <code>Map</code> containing model object
     * @param src          the directory to be XMLized specified as src attribute on &lt;map:generate/>
     * @param par          configuration parameters
     */
    public void setup(SourceResolver resolver, Map objectModel, String src, Parameters par)
            throws ProcessingException, SAXException, IOException {
        super.setup(resolver, objectModel, src, par);
        // this.branch is used to resolve the cocoon:/ uri below
        this.branch = "/" + ObjectModelHelper.getRequest(objectModel).getSitemapURI();
        this.branch = this.branch.substring(0, this.branch.lastIndexOf("/"))+ "/";
        this.domain=(String)ObjectModelHelper.getContext(objectModel).getAttribute("xfolio.domain");
    }
    
    /**
     * Serviceable
     * 
     * @param manager
     *            the ComponentManager
     * 
     * @throws ServiceException
     *             in case a component could not be found
     */
    public void service(ServiceManager manager) throws ServiceException {
        super.service(manager);
    }
    /**
     * Recycle resources
     */
    public void recycle() {
        super.recycle();
    }
    /**
     * Extends the <code>setNodeAttributes</code> method from the
     * <code>DirectoryGenerator</code> by adding width, height and comment
     * attributes if the path is a GIF or a JPEG file.
     * 
     * And some more useful Xfolio information ("lang", "radical", "branch" ...).
     * 
     * TODO: previous / next
     * 
     */
    protected void setNodeAttributes(File path) throws SAXException {
        // unplug for better values
        // super.setNodeAttributes(path);
        attributes.clear();



        // write attributes
        if (path.equals(new File(this.source))) {
            if (check(this.branch)) attributes.addAttribute("", "branch", "branch", "CDATA", this.branch);
            attributes.addAttribute("", "generated", "generated", "CDATA", dateFormatter.format(new Date()));
            if (check(this.domain)) attributes.addAttribute("", "domain", "domain", "CDATA", this.domain);
        }
        attributes.addAttribute("", "name", "name", "CDATA", path.getName());
        String value;
        value=getRadical(path);
        if (check(value)) attributes.addAttribute("", "radical", "radical", "CDATA", value);
        value=getLang(path);
        if (check(value)) attributes.addAttribute("http://www.w3.org/XML/1998/namespace", "lang", "xml:lang", "CDATA", value);
        value=getExtension(path);
        if (check(value)) attributes.addAttribute("", "extension", "extension", "CDATA", value);
        // prefer servlet level to resolve
        // String type = MIMEUtils.getMIMEType(extension);
        value=ObjectModelHelper.getContext(objectModel).getMimeType(path.getName());
        if (check(value)) attributes.addAttribute("", TYPE, TYPE, "CDATA", value);
        value = new File(super.source).toURI().relativize(path.toURI()).toString();
        // take base
        value=(value.lastIndexOf("/") == -1)?"":value.substring(0, value.lastIndexOf("/")+1);
        attributes.addAttribute("", "base", "base", "CDATA", value);
        
        attributes.addAttribute("", "modified", "modified", "CDATA",
                dateFormatter.format(new Date(path.lastModified())));
        attributes.addAttribute("", "length", "length", "CDATA", ""+ path.length());

        if (path.isDirectory()) {
            return;
        }
        String extension=getExtension(path);
        if ("jpg".equals(extension) || "png".equals(extension)) try {
            ImageProperties p = ImageUtils.getImageProperties(path);
            if (p != null) {
                if (getLogger().isDebugEnabled()) {
                    getLogger().debug(
                            String.valueOf(path) + " = " + String.valueOf(p));
                }
                attributes.addAttribute("", WIDTH, WIDTH, "CDATA", String
                        .valueOf(p.width));
                attributes.addAttribute("", HEIGHT, HEIGHT, "CDATA", String
                        .valueOf(p.height));
                // bug on some chars in jpeg comments
                /*
                if (p.comment != null)
                    attributes.addAttribute("", COMMENT, COMMENT, "CDATA",
                            String.valueOf(p.comment));
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
     * <b>Extends the startNode() method of the DirectoryGenerator. </b> -
     *
     * Idea is to include a generated file from sitemap
     * with an URI like
     * cocoon:/{branch}{fileRadical}.xfoliodir
     * App developper could then provide the nicest records he can from
     * source and XSL
     * 
     * In case of directory, the best source files to inform it will be searched
     * 1) index files (what ever the format or the lang extension)
     * 2) the first files with the same radical
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
        if (path.isDirectory()) {
            // get here records about the directory from the nested files 
            File[] children=path.listFiles();
            return;
        } else {
            includeMeta(path);
        }
    }
    
    /**
     * <p>
     * Adds a single node to the generated document. If the path is a
     * directory, and depth is greater than zero, then recursive calls
     * are made to add nodes for the directory's children.
     * </p>
     * 
     * <p>
     * Even if depth is zero, directory will nest i18n "welcome" paths 
     * to get minimum meta on it.
     * The recursive call will put all "index" file in the beginning as
     * meta of a directory.
     * </p>
     * 
     * @param path   the file/directory to process
     * @param depth  how deep to scan the directory
     * @throws SAXException  if an error occurs while constructing nodes
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
            // TODO extract this class from here
            Arrays.sort (contents, new FileComparator());
            if (depth < 1) {
                // insert the welcome files
                // may have strange effects in case of nested empty directories ?
                String welcome=null;
                String radical="";
                for (int i = 0; i < contents.length; i++) {
                    if (isIncluded(contents[i]) && !isExcluded(contents[i])) {
                        radical=getRadical(contents[i]);
                        // should be another radical here
                        if (welcome != null && !welcome.equals(radical)) break;
                        if (welcome == null) welcome=radical;
                        // addPath(contents[i], depth - 1);
                    }
                }
            }
            if (depth > 0) {
                for (int i = 0; i < contents.length; i++) {
                    if (isIncluded(contents[i]) && !isExcluded(contents[i])) {
                        addPath(contents[i], depth - 1);
                    }
                }
            }
            endNode(DIR_NODE_NAME);
        }
        else {
            // what else ?
        }
    }

    
    
    /**
     * Give radical of a file, on the form
     * radical(_en)?(\.ext)?
     * according on the rules that
     * <ul> 
     *   <li>file beginning by '.' or '_' (.*, _*) are considered invisible, so radical=""</li>
     *   <li>after last '.' it's extension : "ext"</li>
     *   <li>after last'_' before extension it's a lang "en"</li>
     * </ul>
     * 
     * So radical is what is left, "radical."
     */

    public String getRadical(File file) {
        String radical=file.getName();
        if (radical.startsWith(".") || radical.startsWith("_")) return "";
        if (radical.lastIndexOf('.') > 0) radical=radical.substring(0, radical.lastIndexOf('.'));
        if (radical.lastIndexOf('_') >0 && radical.lastIndexOf('_') == radical.length() -3) radical=radical.substring(0, radical.lastIndexOf('_'));
        return radical;
    }

    /**
     * Give extension of a file.
     */
    public String getExtension(File file) {
        String name=file.getName();
        if (name.lastIndexOf('.') < 1) return "";
        return name.substring(name.lastIndexOf('.')+1);
    }

    /**
     * <b>Give lang of a file according to XFolio practices </b> -
     * .*_(??)\.extension, where (??) is an iso language code on 2 chars
     * extend to other locale ?
     */
    public String getLang(File file) {
        String name=file.getName();
        if (name.lastIndexOf('.') > 0) name=name.substring(0, name.lastIndexOf('.'));
        if (name.lastIndexOf('_') < 1 || name.lastIndexOf('_') != name.length() -3) return "";
        return name.substring(name.lastIndexOf('_')+1);
    }
    
    
    /**
     * <b>Include a meta XML file given by sitemap </b> -
     *
     * This generator suppose that all files 
     */
    public void includeMeta(File path) throws SAXException {
        String radical=getRadical(path);
        // careful here, break if there's forbidden name which are
        // toc, dir or you will have infinite loop
        if ("dir".equals(radical) || "toc".equals(radical)) return;
        // get relative 
        String uri = new File(this.source).toURI()
                .relativize(path.toURI()).toString();
        
        int dot = uri.lastIndexOf(".");
        if (dot > -1 && dot > uri.lastIndexOf("/")) {
            uri = uri.substring(0, dot) + ".meta";
            Source rdf = null;
            try {
                // FIXME, are there's a strange loop in some cases ? example cocoon://
                // absolute cocoon link
                uri="cocoon:/" + this.branch + uri;
                rdf = super.resolver.resolveURI(uri);
                
                SourceUtil.toSAX(rdf, new IncludeXMLConsumer(this.contentHandler));
            } catch (MalformedURLException e) {
                getLogger().debug(
                        "xfolioDirectoryGenerator "
                                + e.getLocalizedMessage()
                                + " file:"
                                + path
                                + " uri:"
                                + ObjectModelHelper.getRequest(objectModel)
                                        .getSitemapURI());
            } catch (IOException e) {
                getLogger().debug(
                        "xfolioDirectoryGenerator "
                                + e.getLocalizedMessage()
                                + " file:"
                                + path
                                + " uri:"
                                + ObjectModelHelper.getRequest(objectModel)
                                        .getSitemapURI());
            } catch (ProcessingException e) {
                getLogger().debug(
                        "xfolioDirectoryGenerator "
                                + e.getLocalizedMessage()
                                + " file:"
                                + path
                                + " uri:"
                                + ObjectModelHelper.getRequest(objectModel)
                                        .getSitemapURI());
            } finally {
                if (rdf != null) this.resolver.release(rdf);
            }

    }
    }
    
    private boolean check(String s) {
        return (s != null && !"".equals(s));
    }
    
    class FileComparator implements Comparator {
        public int compare(Object o1, Object o2) {
            // TODO, be more efficient here
            // String lang=(String)ObjectModelHelper.getContext(objectModel).getAttribute("xfolio.lang");
            // some hard coded nationalism
            String lang="fr";
            // default, equal
            int compare=0;
            String radical1=getRadical((File)o1);
            String radical2=getRadical((File)o2);
            String lang1=getLang((File)o1);
            String lang2=getLang((File)o2);
            String extension1=getExtension((File)o1);
            String extension2=getExtension((File)o2);
            // separe on radical
            if (radical1.equals("index") && !radical2.equals("index")) compare=-1;
            else if (!radical1.equals("index") && radical2.equals("index")) compare=1;
            else if (radical1.equals("index") && radical2.equals("index")) compare=0;
            else compare=radical1.compareTo(radical2); 
            // if not enough, separe on lang
            if (compare==0) {
                if (lang1.equals(lang) && !lang2.equals(lang)) compare=-1;
                else if (!lang1.equals(lang) && lang2.equals(lang)) compare=1;
                else if (lang1.equals(lang) && lang2.equals(lang)) compare=0;
                // TODO an ordering table of language should be prefered
                else compare=lang1.compareTo(lang2);
            }
            // if not enough, compare on extension
            if (compare==0) {
                // TODO an ordering table of formats may be prefered ?
                if (extension1.equals("sxw")) compare=-1;
                else if (extension2.equals("sxw")) compare=1;
                else if (extension1.equals("dbx")) compare=-1;
                else if (extension2.equals("dbx")) compare=1;
                else if (extension1.equals("txt")) compare=-1;
                else if (extension2.equals("txt")) compare=1;
            }
            return compare;
        }
    }

}