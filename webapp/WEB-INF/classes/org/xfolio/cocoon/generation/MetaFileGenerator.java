/*
 * Created on 5 mars 2004 (c) strabon.org GPL frederic.glorieux@ajlsm.com
 */
package org.xfolio.cocoon.generation;
import java.io.File;
import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.Arrays;
import java.util.Map;
import java.util.Stack;

import org.apache.avalon.framework.parameters.Parameters;
import org.apache.cocoon.ProcessingException;
import org.apache.cocoon.ResourceNotFoundException;
import org.apache.cocoon.environment.ObjectModelHelper;
import org.apache.cocoon.environment.SourceResolver;
import org.xfolio.file.FileComparator;
import org.xfolio.file.FileUtils;
import org.xml.sax.SAXException;
/**
 * <b> Extends MetaDirectoryGenerator to provide info for
 * a prev/up/next navigation of a file </b>
 * 
 * 
 * 
 * @author <a href="mailto:frederic.glorieux@ajlsm.com">Glorieux, Frédéric </a>
 */
public class MetaFileGenerator extends MetaDirectoryGenerator {
    /** root element */
    protected static String NAVIGATION = "navigation";
    /** prev */
    protected static String PREV = "prev";
    /** next */
    protected static String NEXT = "next";

    /** Constant for the file protocol. */
    static final String FILE = "file:";
    /** the directory from which generate a navigation */
    private File rootFile;
    
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
        // source is probably of pattern directory/identifier
        File base=new File(src);
        // in case of bad usage of the generator, protect against upper display
        // may bug if directories change
        if (base.isDirectory()) this.base=base.toURI().normalize().toString();
        else { 
            this.base=base.getParentFile().toURI().normalize().toString();
            // radical to find 
            this.radical=FileUtils.getRadical(new File(src));
        }
        // root is used to begin from root of efolder
        String root = par.getParameter("root", null);
        this.rootFile=(root==null)?
            new File((String)ObjectModelHelper.getContext(objectModel).getAttribute("xfolio.efolder"))
            :new File(root);
        // send an exception ?
        if (!this.rootFile.isDirectory()) {
            throw new ResourceNotFoundException(this.rootFile + " provide as root is not a directory.");
        }
    }

    /**
     * Generate XML data.
     * 
     * @throws SAXException  if an error occurs while outputting the document
     * @throws ProcessingException  if the requsted URI isn't a directory on the local filesystem
     */
    public void generate() throws SAXException, ProcessingException {
        File directory=null;
        try {
            directory=new File(new URI(this.base));
            if (!directory.isDirectory()) {
                throw new ResourceNotFoundException(directory + " is not a valid parent directory");
            }
            
            this.contentHandler.startDocument();
            this.contentHandler.startPrefixMapping(PREFIX, URI);
            
            attributes.clear();
            super.contentHandler.startElement(URI, NAVIGATION, PREFIX + ':' + NAVIGATION, attributes);
            // previous
            super.contentHandler.startElement(URI, PREV, PREFIX + ':' + PREV, attributes);
            if (this.radical != null) addPrev(directory, this.radical);
            super.contentHandler.endElement(URI, PREV, PREFIX + ':' + PREV);
            
            Stack ancestors = getAncestors(directory);
            addAncestorPath(directory, ancestors);
            // next
            attributes.clear();
            super.contentHandler.startElement(URI, NEXT, PREFIX + ':' + NEXT, attributes);
            if (this.radical != null) addNext(directory, this.radical);
            super.contentHandler.endElement(URI, NEXT, PREFIX + ':' + NEXT);
            
            super.contentHandler.endElement(URI, NAVIGATION, PREFIX + ':' + NAVIGATION);

            this.contentHandler.endPrefixMapping(PREFIX);
            this.contentHandler.endDocument();
        } catch (URISyntaxException e) {
            throw new ResourceNotFoundException(this.base + " is not a valid URI. Code problem.");
        }
        finally {
        }
    }
    
    /**
     * Adds recursively the path from the directory matched by the root pattern
     * down to the requested directory.
     * 
     * @param path       the requested directory.
     * @param ancestors  the stack of the ancestors.
     * @throws SAXException
     */
    public void addAncestorPath(File path, Stack ancestors) throws SAXException {
        if (ancestors.empty()) {
            /*
            // put the files of the right radical
            startNode(DIR_NODE_NAME, path);
            File contents[] = path.listFiles();
            Arrays.sort(contents, new FileComparator());
	        for (int index=0; index <contents.length; index++) {
	            if (FileUtils.getRadical(contents[index]).equals(this.radical)) addPath(contents[index], -1);
	        }
            endNode(DIR_NODE_NAME);
            */
            this.isRequestedDirectory = true;
            addPath(path, 1);
        } else {
            File dir=(File)ancestors.pop();
            startNode(DIR_NODE_NAME, dir);
            addWelcome(dir);
            addAncestorPath(path, ancestors);
            endNode(DIR_NODE_NAME);
        }
    }
    
    /**
     * From a directory, insert last file, with a go down directories
     */

    protected boolean addPrev(File directory, String radical) throws SAXException {
        if (!directory.isDirectory()) return false;
        boolean exit=false;
        File contents[] = directory.listFiles();
        Arrays.sort(contents, new FileComparator());
        int index=contents.length-1;
        // if a radical requested, set index from it, increment from 0
        if (radical != null && !"".equals(radical)) {
	        for (index=0; index <contents.length; index++) {
	            if (FileUtils.getRadical(contents[index]).equals(radical)) break;
	        }
            // radical not found, exit 
            if (index == contents.length) {
                return false;
            }
            // begin before
            else index--;
        }

        String searchRadical="";
        String currentRadical="";
        for (;index > -1;index--) {
            currentRadical = FileUtils.getRadical(contents[index]);
            // if searchRadical already found and current is an other, too far, stop.
            if (!"".equals(searchRadical) && !searchRadical.equals(currentRadical)) return true;
            if (isIncluded(contents[index]) && !isExcluded(contents[index])) {
                searchRadical=currentRadical;
                // what about directory with same radical as file ?
                if (contents[index].isDirectory()) {
                    // go down
                    if (addPrev(contents[index] , null)) return true;
                    // no file found in directory, continue
                    else searchRadical="";
                }
                else {
                    addPath(contents[index], -1);
                    // in case of only one file by directory
                    exit=true;
                }
            }
            
        }
        // stop when go down
        if (radical == null || "".equals(radical)) return exit;
        else if(directory.equals(this.rootFile)) return false;
        else return addPrev(directory.getParentFile() , FileUtils.getRadical(directory));
    }

    /**
     * From a directory and a radical, insert next file, with a go down or up directories
     */

    protected boolean addNext(File directory, String radical) throws SAXException {
        if (!directory.isDirectory()) return false;
        boolean exit=false;
        File contents[] = directory.listFiles();
        Arrays.sort(contents, new FileComparator());
        int index=0;
        // if a radical requested, set index from it, decrement from end
        if (radical != null && !"".equals(radical)) {
	        for (index=contents.length-1; index > -1; index--) {
	            if (FileUtils.getRadical(contents[index]).equals(radical)) break;
	        }
            // radical not found, exit 
            if (index == -1) {
                return false;
            }
            // begin after
            else index++;
        }

        String searchRadical="";
        String currentRadical="";
        // increment
        for (;index < contents.length ; index++) {
            currentRadical = FileUtils.getRadical(contents[index]);
            // if searchRadical already found and current is an other, too far, stop.
            if (!"".equals(searchRadical) && !searchRadical.equals(currentRadical)) return true;
            if (isIncluded(contents[index]) && !isExcluded(contents[index])) {
                searchRadical=currentRadical;
                // what about directory with same radical as file ?
                if (contents[index].isDirectory()) {
                    // go down
                    if (addNext(contents[index] , null)) return true;
                    // no file found in directory, continue
                    else searchRadical="";
                }
                else {
                    addPath(contents[index], -1);
                    // in case of only one file by directory
                    exit=true;
                }
            }
            
        }
        // stop when go down
        if (radical == null || "".equals(radical)) return exit;
        else if(directory.equals(this.rootFile)) return false;
        else return addNext(directory.getParentFile() , FileUtils.getRadical(directory));
    }

    
    /**
     * Creates a stack containing the ancestors of File up to specified directory.
     * 
     * @param path the File whose ancestors shall be retrieved
     * @return a Stack containing the ancestors.
     */
    protected Stack getAncestors(File path) {
        File parent = path;
        Stack ancestors = new Stack();

        while ((parent != null) && !this.rootFile.equals(parent)) {
            parent = parent.getParentFile();
            if (parent != null) {
                ancestors.push(parent);
            } else {
                // no ancestor matched the root pattern
                ancestors.clear();
            }
        }

        return ancestors;
    }

    
}