/*
 * Created on 5 mars 2004 (c) strabon.org GPL frederic.glorieux@ajlsm.com
 */
package org.xfolio.file;
import java.io.File;
import java.text.SimpleDateFormat;
/**
 * Some methods specific to XFolio directory organisation
 */
public class FileUtils  {
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

    public static String getRadical(File file) {
        String radical=file.getName();
        if (radical.startsWith(".") || radical.startsWith("_")) return "";
        if (radical.lastIndexOf('.') > 0) radical=radical.substring(0, radical.lastIndexOf('.'));
        if (radical.lastIndexOf('_') >0 && radical.lastIndexOf('_') == radical.length() -3) radical=radical.substring(0, radical.lastIndexOf('_'));
        return radical;
    }

    /**
     * Give extension of a file.
     */
    public static String getExtension(File file) {
        String name=file.getName();
        if (name.lastIndexOf('.') < 1) return "";
        return name.substring(name.lastIndexOf('.')+1);
    }

    /**
     * <b>Give lang of a file according to XFolio practices </b> -
     * .*_(??)\.extension, where (??) is an iso language code on 2 chars
     * extend to other locale ?
     */
    public static String getLang(File file) {
        String name=file.getName();
        if (name.lastIndexOf('.') > 0) name=name.substring(0, name.lastIndexOf('.'));
        if (name.lastIndexOf('_') < 1 || name.lastIndexOf('_') != name.length() -3) return "";
        return name.substring(name.lastIndexOf('_')+1);
    }

}