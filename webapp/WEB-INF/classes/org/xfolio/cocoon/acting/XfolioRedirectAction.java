package org.xfolio.cocoon.acting;

import java.io.File;
import java.util.HashMap;
import java.util.Map;
import org.apache.avalon.framework.parameters.Parameters;
import org.apache.avalon.framework.thread.ThreadSafe;
import org.apache.cocoon.ProcessingException;
import org.apache.cocoon.acting.ServiceableAction;
import org.apache.cocoon.environment.Redirector;
import org.apache.cocoon.environment.SourceResolver;
import org.xfolio.file.FileUtils;
/**
 @author frederic.glorieux@xfolio.org

 (c) 2003, 2004 xfolio.org, ajlsm.com, strabon.org.
 Licence [http://www.gnu.org/copyleft/gpl.html GPL]


 = WHAT =

 Cocoon app design, probably because of the samples,
 usually control what is served (I want a CSS ? 
 declare it in the sitemap).
 If Cocoon is used as a more free way server, 
 (ex: an httpd.apache pointing on a folder)
 lots of nice things could be done (transform !). 
 But if you open this door, it's not always HTML,
 you may have strange surprises of what users can produce.

 For example, which welcome page to choose when there's no equivalent
 of an index.html ? Redirection accross all a sitemap logic could
 be expensive and dangerous (infinite loops ! Real life experience). 
 If nothing answer at the end of a sitemap, 
 it could be nice to have something which say, for what is requested,
 I've nothing exact but this is a not too bad answer.

 = WHO =

 [FG] FredericGlorieux AJLSM <http://ajlsm.com> for Strabon <http://strabon.org>

 = Why =

 From Cocoon samples, you have usually things like that
 {{{
 <map:match pattern="">
 <map:generate src="welcome.xml"/>
 <map:transform src="welcome.xslt"/>
 <map:serialize type="xhtml"/>
 </map:match>
 }}}
 Perfect. You know what you have, it's an XML you are waiting for, you know how to transform it.

 Imagine now you have authors who are not developpers but real world writers,
 you can obtain a source folder like this
 efolder
 * 01 first page.xml
 * default.xml
 * welcome.xml

 You can try a Sitemap logic like that
 {{{
 <map:match pattern="">
 <map:redirect-to uri="index.html"/>
 </map:match>
 <map:match pattern="**index.html">
 <map:generate src="{efolder}{1}index.xml"/>
 ...
 </map:match>
 }}}

 And you will have a "Resource Not Found" error, because 
 your authors haven't yet understood that the default page of a folder should be an "index.xml". 
 A work around could be

 {{{
 <map:match pattern="**index.html">
 <map:act type="exists" src="{efolder}{1}index.xml">
 ...
 </map:act>
 <map:redirect-to uri="default.html"/>
 </map:match>
 <map:match pattern="**default.html">
 <map:act type="exists" src="{efolder}{1}default.xml">
 ...
 </map:act>
 </map:match>
 }}}

 No Cocoon Exception, but if there no default.xml, still 404.

 So this action implement something like that

 {{{
 <map:sitemap xmlns:map="http://apache.org/cocoon/sitemap/1.0">
 <map:components>
 <map:actions>
 <map:action name="xfolioRedirect" 
 src="org.xfolio.cocoon.acting.XfolioRedirectAction" 
 logger="sitemap.xfolio.redirect"/>
 </map:actions>
 </map:components>
 <!-- all your pipeline logic -->
 <map:match pattern="**">
 <map:act type="xfolioRedirect">
 <map:parameter name="file" value="{context-attr:xfolio.efolder}{1}"/>
 <map:read src="cocoon:/{path}.html"/>
 </map:act>
 </map:match>
 </map:sitemap>
 }}}

 xfolioRedirect is an action, you pass it parameters, it answer parameters, 
 and also, success or failed. From the match, we can guess the folder requested. 
 A piece of code is then able to find in a folder if there is "index.xml", 
 or "default.xml", or if nothing of that, giving the first valid xml file 
 (or whatever navigation logic you have). This for succes, and fail could be, 
 this directory doesn't exist, let sitemap handle 404. The output is a "radical", 
 a not yet precise spec but a filename without extension, probably more convenient 
 to build an URI for your sitemap.


 = References =

 * [http://cocoon.apache.org/2.1/userdocs/actions/actions.html Actions]
 * [http://cocoon.apache.org/2.1/userdocs/xsp/index.html  XSP]
 * [http://wiki.apache.org/cocoon/XSPAction  XSP Actions]
 * [http://cocoon.apache.org/2.1/userdocs/concepts/redirection.html redirections]


 */
public class XfolioRedirectAction extends ServiceableAction implements ThreadSafe {

    public Map act(Redirector redirector, SourceResolver resolver, Map objectModel, String src, Parameters parameters)
            throws Exception {
        // output of the action. If it stay like that, action failed
        HashMap map;
        String file = parameters.getParameter("file", null);
        // For sitemap authors
        if (file == null) throw new ProcessingException("XfolioRedirectAction, path parameter is empty");
        File best=search(new File(file));
        if (best == null) return null;
        map= new HashMap();
        map.put("file", best.getCanonicalPath());
        map.put("name", best.getName());
        map.put("radical", FileUtils.getRadical(best));
        // not the best name, may change
        map.put("identifier", FileUtils.getIndentifier(best));
        return map;
    }

    /*
     * This method try to be intelligent and find the best file 
     * from a path requested. 
     */
    public File search(File file) {
        if (file.isFile()) return file;
        String radical = FileUtils.getRadical(file);
        if (!file.isDirectory()) file = file.getParentFile();
        // don't search more than one step up
        if (!file.isDirectory()) return null;
        File[] folder;
        folder = file.listFiles();
        if (folder.length == 0) return null;
        File first=null;
        File index=null;
        File best=null;
        File directory=null;
        // TODO pass as parameters
        // these strings are ordered as last prefered
        String langs = " en fr ";
        String htmlisable = " jpg html dbx sxw ";
        for (int i = 0; i < folder.length; i++) {
            if (folder[i].isDirectory()) ;
            else if (first == null) {
                first = folder[i];
            }
            // file with same radical as first, is it better ?
            else if (first != null && FileUtils.getRadical(first).equals(FileUtils.getRadical(folder[i]))) {
                // TODO test this logic
                if (langs.indexOf(" "+FileUtils.getLang(folder[i])+" ") 
                 >= langs.indexOf(" "+FileUtils.getLang(first    )+" "))
                        first = folder[i];
                if (htmlisable.indexOf(" "+FileUtils.getLang(folder[i])+" ") 
                 >= htmlisable.indexOf(" "+FileUtils.getLang(first    )+" "))
                    	first = folder[i];
            } else if ("index".equals(FileUtils.getRadical(folder[i]))) {
                index = folder[i];
            }
            else if (index != null && FileUtils.getRadical(index).equals(FileUtils.getRadical(folder[i]))) {
                // TODO test this logic
                if (langs.indexOf(" "+FileUtils.getLang(folder[i])+" ") 
                 >= langs.indexOf(" "+FileUtils.getLang(index    )+" "))
                        index = folder[i];
                if (htmlisable.indexOf(" "+FileUtils.getLang(folder[i])+" ") 
                 >= htmlisable.indexOf(" "+FileUtils.getLang(first    )+" "))
                    	first = folder[i];
            }
            else if (radical.equals(FileUtils.getRadical(folder[i]))) {
                best = folder[i];
            }
            else if (best !=null && FileUtils.getRadical(best).equals(FileUtils.getRadical(folder[i]))) {
                // TODO test this logic
                if (langs.indexOf(" "+FileUtils.getLang(folder[i])+" ") 
                 >= langs.indexOf(" "+FileUtils.getLang(best    )+" "))
                        best = folder[i];
                if (htmlisable.indexOf(" "+FileUtils.getLang(folder[i])+" ") 
                 >= htmlisable.indexOf(" "+FileUtils.getLang(best    )+" "))
                    	best = folder[i];
            }
        }
        if (best != null) return best;
        else if (index != null) return index;
        else if (first != null) return first;
        // maybe dangerous
        // else if (folder[1].isDirectory()) return search(folder[1]);
        else return null;
    }
}