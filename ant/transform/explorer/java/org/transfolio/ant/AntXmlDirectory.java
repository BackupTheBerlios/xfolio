package org.transfolio.ant;


import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Comparator;
import java.util.Date;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Result;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.sax.SAXTransformerFactory;
import javax.xml.transform.sax.TransformerHandler;
import javax.xml.transform.stream.StreamResult;


import org.xml.sax.ContentHandler;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;
import org.xml.sax.XMLReader;
import org.xml.sax.helpers.AttributesImpl;

import org.apache.tools.ant.Project;
import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;
import org.apache.tools.ant.taskdefs.MatchingTask;



/**
 @author frederic.glorieux@xfolio.org
 @version CVS $Id: AntXmlDirectory.java,v 1.2 2004/11/23 02:57:09 glorieux Exp $

 = What =

An ant task to generate an XML directory.

 */
public class AntXmlDirectory extends Task {

    /* commodity for SAX generation */
    private char[] c;
    private AttributesImpl atts;
    /* xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" */
    private static String RDF="rdf";
    private static String RDF_URI="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
    private static String ABOUT="about";
    private static String RDF_ABOUT=RDF+":"+ABOUT;
    private static String RESOURCE="resource";
    private static String COLLECTION="collection";
    private static String CDATA="CDATA";
    private static String XML="xml";
    private static String XML_URI="http://www.w3.org/XML/1998/namespace";
    private static String LANG="lang";
    private static String XML_LANG=XML+":"+LANG;
    

    /** the directory to document */
    public File srcDir;
    public void setSrcDir (File srcDir) {
        this.srcDir = srcDir;
    }
    /** the file where to write XML */
    public File destFile;
    public void setDestFile (File destFile) {
        this.destFile = destFile;
    }
    /** for an xsl declaration */
    public String xsl;
    public void setXsl (String xsl) {
        this.xsl = xsl;
    }
    /** a path to find a theme directory for generated html from this xml  */
    public String theme;
    public void setTheme (String theme) {
        this.theme = theme;
    }
    /** where to find a relevant css for generated html from this xml  */
    public String css;
    public void setCss (String css) {
        this.css = css;
    }
    /** same logic as css for javascript */
    public String js;
    public void setJs (String js) {
        this.js = js;
    }

    /** TODO ? an exclude pattern */
    public String excludes;
    /** TODO ? an include pattern  */
    public String includes;
    /** A priority lang order */
    public String languages="fr en ar";
    public void setlanguages (String languages) {
        this.languages = languages;
    }
    /** A priority format order */
    public String formats="sxw dbx html";
    public void setFormats (String formats) {
        this.formats = formats;
    }
    /** a pattern for dates */
    public String dateFormat="yyyy-MM-dd'T'HH:mm:ss";
    public void setdateFormat (String dateFormat) {
        this.dateFormat = dateFormat;
    }
    /** A date formatter */
    protected SimpleDateFormat dateFormatter = new SimpleDateFormat(dateFormat);
    /** A depth limit, and also a counter to know when it's root */
    public int depth=10;
    public void setDepth (int depth) {
        this.depth = depth;
    }

    public void execute() throws BuildException {
        // log("AntXMPjpeg");
		try {
			if (srcDir == null) throw new BuildException ("\n[" + this.getTaskName() + "] provide a directory to parse as @srcDir.");
			if (destFile == null) throw new BuildException ("\n[" + this.getTaskName() + "] provide a file path as @fileDest, where to write your XML directory.");
			// delete it without prompt ?
			if (destFile.exists()) {
			    destFile.delete();
			    log(destFile+" overwritten");
			}
			saxDoc(destFile);
		}
		catch (TransformerConfigurationException e) {
			throw new BuildException("TransformerConfigurationException:" +e);
		}
		catch (FileNotFoundException e) {
			throw new BuildException("FileNotFoundException:" +e);
		}
		catch (IOException e) {
			throw new BuildException("IOException:" +e);
		}
		catch (SAXException e) {
			throw new BuildException("SAXException:" +e);
		}
		catch (ParserConfigurationException e) {
			throw new BuildException("ParserConfigurationException:" +e);
		}
    }

    /** begins the process, create an info.xml with the file given 
     * @throws TransformerConfigurationException*/
    public void saxDoc(File destination) throws SAXException, IOException, 
    TransformerConfigurationException, ParserConfigurationException {
        // create transformers
        SAXTransformerFactory transformer = null;
        if (transformer == null) transformer = (SAXTransformerFactory) SAXTransformerFactory.newInstance();
        if (destination == null) throw new BuildException("No file provide for SAXdoc");

        TransformerHandler handler = transformer.newTransformerHandler();
        handler.getTransformer().setOutputProperty(OutputKeys.ENCODING, "UTF-8");
        handler.getTransformer().setOutputProperty(OutputKeys.INDENT, "yes");
        handler.getTransformer().setOutputProperty(OutputKeys.METHOD, "xml");
        Result result = new StreamResult();
        // write result in a file
        // do it like that to avoid some escaping characters from I don't know where
        result.setSystemId(destination.getCanonicalPath());
        handler.setResult(result);


        // Open document
        handler.startDocument();
        if (check(xsl)) 
            handler.processingInstruction("xml-stylesheet", " type=\"text/xsl\" href=\"" + xsl + "\"");
        if (check(theme)) 
            handler.processingInstruction("theme", theme);
        if (check(js)) 
            handler.processingInstruction("js", js);
        if (check(css)) 
            handler.processingInstruction("css", css);
        
        fileToSax(srcDir, handler, this.depth);
        
        handler.endDocument();
    }

    public void fileToSax(File file, ContentHandler handler, int depth) throws SAXException, IOException {
        atts= new AttributesImpl();
        String value;
        // root collection
        if (depth == this.depth) {
            atts.addAttribute("", "generated", "generated", CDATA, dateFormatter.format(new Date()));
            atts.addAttribute("", "directory", "directory", CDATA, srcDir.getCanonicalPath() );
        }
        atts.addAttribute("", "name", "name", "CDATA", file.getName());
        // value = NetUtils.relativize(this.srcDir, file.toURI().normalize().toString());
        value=""+this.srcDir.toURI().relativize(file.toURI()).normalize().getPath();
        atts.addAttribute("", "href","href", "CDATA", value);
        atts.addAttribute("", "modified", "modified", "CDATA", dateFormatter
                .format(new Date(file.lastModified())));

        // atts.addAttribute("", "file", "file", "CDATA", "" + file);

        
        if (file.isDirectory()) {
            handler.startElement("", COLLECTION, COLLECTION, atts);

            File collection[] = file.listFiles(new FileFilterWebfolder());
            Arrays.sort(collection, new ComparatorWebfolder());

            for (int i = 0; i < collection.length; i++) {
                fileToSax(collection[i], handler, depth - 1);
            }
            
            handler.endElement("", COLLECTION, COLLECTION);
            
        }
        else {
            value = getRadical(file);
            if (check(value)) atts.addAttribute("", "radical", "radical", CDATA, value);
            value = getLang(file);
            if (check(value)) atts.addAttribute(XML_URI, LANG, XML_LANG, CDATA, value);
            value = getExtension(file);
            if (check(value)) atts.addAttribute("", "extension", "extension", CDATA, value);
            value = getBasename(file);
            if (check(value)) atts.addAttribute("", "basename", "basename", CDATA, value);
            handler.startElement("", RESOURCE, RESOURCE, atts);
            
            handler.endElement("", RESOURCE, RESOURCE);
        }
    }
    
    public boolean check(String s) {
        return (s != null && !"".equals(s));
    }

    /**
    Give basename of a file (without extension)
    */
	 public static String getBasename(File file) {
	     String name=file.getName();
	     if (name.lastIndexOf('.') < 1) return name;
	     return name.substring(0, name.lastIndexOf('.'));
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
     * clean a prefix ?
     */

    public static String getRadical(File file) {
        String radical=file.getName();
        if (radical.startsWith(".") || radical.startsWith("_")) return "";
        if (radical.lastIndexOf('.') > 0) radical=radical.substring(0, radical.lastIndexOf('.'));
        if (radical.lastIndexOf('_') >0 && radical.lastIndexOf('_') == radical.length() -3) radical=radical.substring(0, radical.lastIndexOf('_'));
        return radical;
    }

    /**
     * <b>Give lang of a file according to TransFolio practices </b> -
     * .*_(??)\.extension, where (??) is an iso language code on 2 chars
     * extend to other locale ?
     */
    public static String getLang(File file) {
        String name=file.getName();
        if (name.lastIndexOf('.') > 0) name=name.substring(0, name.lastIndexOf('.'));
        if (name.lastIndexOf('_') < 1 || name.lastIndexOf('_') != name.length() -3) return "";
        return name.substring(name.lastIndexOf('_')+1);
    }

    /**
     * Give extension of a file.
     */
    public static String getExtension(File file) {
        String name=file.getName();
        if (name.lastIndexOf('.') < 1) return "";
        return name.substring(name.lastIndexOf('.')+1);
    }


    public class ComparatorWebfolder implements Comparator {
        public int compare(Object o1, Object o2) {
            // default, equal
            int compare=0;
            String radical1=getRadical((File)o1);
            String radical2=getRadical((File)o2);
            // separe on radical
            if (radical1.equals("index") && !radical2.equals("index")) compare=-1;
            else if (!radical1.equals("index") && radical2.equals("index")) compare=1;
            else if (radical1.equals("index") && radical2.equals("index")) compare=0;
            else compare=radical1.compareToIgnoreCase(radical2);
            if (compare != 0) return compare;
            // if not enough, separe on lang
            // logic is, find lang in an ordered string of languages (lang codes space separated)
            // languages.indexOf("fr") == 0, means better than -1 or 7

            String lang1=getLang((File)o1);
            int lang1Index=languages.indexOf(lang1);
            if (lang1Index==-1) lang1Index=languages.length();
            if ("".equals(lang1)) lang1Index=-1;

            String lang2=getLang((File)o2);
            int lang2Index=languages.indexOf(lang2);
            if (lang2Index==-1) lang2Index=languages.length();
            if ("".equals(lang2)) lang2Index=-1;

            compare=lang1Index-lang2Index;

            if (compare != 0) return compare;

            // for extensions, same kind of logic as langs 

            String extension1=getExtension((File)o1);
            int extension1Index=formats.indexOf(extension1);
            if (extension1Index == -1) extension1Index=formats.length();
            
            String extension2=getExtension((File)o2);
            int extension2Index=formats.indexOf(extension2);
            if (extension2Index == -1) extension2Index=formats.length();

            compare=extension1Index - extension2Index;
            
            return compare;
        }
    }

    /**

This filter should implement include and exclude for 
listFiles in a directory
For now it will be a bit hardcoded, to avoid CVS or .svn directories
     */
    public class FileFilterWebfolder implements java.io.FileFilter {
		public boolean accept(File file) {
			// readable ?
			if (!file.canRead()) return false;
			String name=file.getName();
			if (name.startsWith(".") 
			 || name.startsWith("CVS") 
			 || name.startsWith("_")
			 || name.startsWith("Thumbs.db")) return false;
			return true;
		}
	}

    
    
}
