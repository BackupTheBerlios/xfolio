package org.xfolio.cocoon.acting;

import java.io.File;
import java.util.Map;
import org.apache.avalon.framework.context.ContextException;
import org.apache.avalon.framework.parameters.ParameterException;
import org.apache.avalon.framework.parameters.Parameterizable;
import org.apache.avalon.framework.parameters.Parameters;
import org.apache.avalon.framework.thread.ThreadSafe;
import org.apache.cocoon.Constants;
import org.apache.cocoon.acting.ServiceableAction;
import org.apache.cocoon.environment.ObjectModelHelper;
import org.apache.cocoon.environment.Redirector;
import org.apache.cocoon.environment.Request;
import org.apache.cocoon.environment.Session;
import org.apache.cocoon.environment.SourceResolver;
import org.apache.cocoon.environment.Context;


public class XfolioStartParamsAction extends ServiceableAction
        implements
            ThreadSafe,
            Parameterizable {

	/** Contextualize this class */
    protected File workDir;
    protected File cacheDir;
    protected Context context;
    protected Request request;
    

    public void contextualize(final Context context)
    throws ContextException {
        this.workDir = (File)context.getAttribute(Constants.CONTEXT_WORK_DIR);
    }
	
	public void parameterize(Parameters parameters) throws ParameterException {
        // super.parameterize(parameters);
    }

    public Map act (Redirector redirector, SourceResolver resolver, Map objectModel, String src, Parameters par) throws Exception {
//      strange logic but efficient in sitemap logic
//      this action fails if everything is OK to continue sitemap process

       boolean stop=false;
       this.context=ObjectModelHelper.getContext(objectModel);
       this.request = ObjectModelHelper.getRequest(objectModel);

     /*
     see
     http://java.sun.com/j2se/1.4.2/docs/api/java/net/URLConnection.html#getFileNameMap()
     */
     /*
           new URI(
             super.resolver.resolveURI("WEB-INF/classes/content-types.properties").getURI() 
           ).normalize().toURL().getFile()
     */


      
     /*
       get Parameters to start the server
         xfolio.efolder = the documents folder to serve
         xfolio.skin = the default skin folder
         xfolio.lang = the default lang
         xfolio.domain = the internet domain for which this pages are generated
         xfolio.site = a directory where to write the generated files

     */


     /* 
       to continue as fast as possible, 
       verify if efolder path is set on context
       if not, set it and take other params
     */

       String efolder=String.valueOf(context.getAttribute("xfolio.efolder"));
       if (!(efolder == null  || "null".equals(efolder) || "".equals(efolder)) ) {
       }
       else {
         efolder=context.getInitParameter("xfolio.efolder");
         if (path2dir(efolder)==null) efolder=System.getProperty("xfolio.efolder");
         if (path2dir(efolder)==null) efolder=String.valueOf(request.getParameter("efolder"));

         // impossible to get a value, set nothing, stop 
         if ( path2dir(efolder)==null ) stop=true;
         // a value is provide, test it
     		else {
           String dir=path2dir(efolder);
           System.out.println("param requested : " + efolder);
           System.out.println("efolder served : " + dir);
           context.setAttribute("xfolio.efolder", dir + File.separator );
           // delete workdir here, if efolder changes, problems may happen
           System.out.println("Deleting Work dir : '" + workDir +"'.");
           delDir(workDir);


           // set skin for this context
           
           String skin=searchValue("skin");
           // no test of availability of skin for now. Who should test if it exists ?
           if (check(skin)) context.setAttribute("xfolio.skin", skin );

           // set domain (documentation variable)

           String domain=searchValue("domain");
           if (check(domain)) context.setAttribute("xfolio.domain", domain);

           // set site (a destination folder)

           String site=searchValue("site");
           if (check(site)) {
             File siteDir=new File(site);
             if (!siteDir.isAbsolute()) siteDir=new File(context.getRealPath("/"), site);
             if (!siteDir.isDirectory() && siteDir.isFile()) siteDir=siteDir.getParentFile();
             context.setAttribute("xfolio.site", siteDir.getCanonicalPath());
           }

         }
       }      


       
     /*
       dynamic skin

       if a user ask for a skin by a param
       dynamic skin for each user oblige to have session
       the session value is setted on the request param skin
       skin is a folder name xfolio/skins/{skin}
     */

     	// a skin param requested
     	String skin=request.getParameter("skin");
       Session session=null;
     	if (skin ==null) { } 
     	else if ("".equals(skin)) {
     		// delete session ?
     	}
     	else {
     		session=request.getSession(true);
     		session.setAttribute("skin", skin);
     	}
        // action fail if parameters are setted to give hand to sitemap
		if (stop) return EMPTY_MAP ;
		else return null;

    }

    
    /*
    Properties are used as context variable
    if not set, a value is search as
       a context initParameter
       a system property
       a request parameter (server on start)
   */

       public String searchValue(String name) {
         String value=(String)context.getAttribute("xfolio."+name);
         if (!check(value)) value = context.getInitParameter("xfolio."+name);
         if (!check(value)) value=System.getProperty("xfolio."+name);
         if (!check(value)) value=(String)request.getParameter(name);
         return value;
       }

    
    public boolean check (String s) {
        return !(s == null || "null".equals(s) || "".equals(s));
     }

    public String path2dir(String path) {
        if (path==null || "null".equals(path) || "".equals(path)) return null;
        try {
          
          File dir=new File(path);
          if (!dir.isAbsolute()) dir=new File(context.getRealPath("/"), path);
          // maybe a file from a directory, take the parent
          if (!dir.isDirectory() && dir.isFile()) dir=dir.getParentFile();
          // not a dir, return nothing
          if (!dir.isDirectory()) return null;
          return dir.getCanonicalPath();
  			}
  			catch (Exception e) {return null;}
      }

    
    public void delDir(File dir)
    {
        if (dir==null) return;
        if (dir.isFile()) dir.delete();
        if (dir.isDirectory())
        {
            File[] files=dir.listFiles();
            for (int i=0; i < files.length; i++) {delDir(files[i]);}
            dir.delete();
        }
    }

}