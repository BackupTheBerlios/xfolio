/*
 * Created on 10 juil. 2004
 */
package org.xfolio.cocoon.components.pipeline.impl;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.io.Serializable;
import java.net.SocketException;

import org.apache.cocoon.ConnectionResetException;
import org.apache.cocoon.ProcessingException;
import org.apache.cocoon.caching.CacheValidity;
import org.apache.cocoon.caching.CacheValidityToSourceValidity;
import org.apache.cocoon.caching.Cacheable;
import org.apache.cocoon.caching.CacheableProcessingComponent;
import org.apache.cocoon.caching.CachedResponse;
import org.apache.cocoon.caching.CachingOutputStream;
import org.apache.cocoon.caching.ComponentCacheKey;
import org.apache.cocoon.caching.PipelineCacheKey;
import org.apache.cocoon.components.pipeline.impl.CachingProcessingPipeline;
import org.apache.cocoon.environment.Context;
import org.apache.cocoon.environment.Environment;
import org.apache.cocoon.environment.ObjectModelHelper;
import org.apache.excalibur.source.SourceValidity;

/**
 * <h4>A light try to implement a filewriter on caching events</h4>
 * 
 * <p>
 * Every cacheable response should update a filesystem copy of a browsable site.
 * Do the less as possible here, cocoon API is not yet stable on this topic. 
 * </p>
 * 
 * <p> <b>issues</b> -
 * Old files are not deleted, but should be out of navigation.
 * How cache can know that a key is deleted ?
 * Careful, a user may insert XFolio files among other things.
 * Better for now is to let user to manage his files, 
 * and delete what he doen't like. 
 * </p>
 * 
 * TODO: the same for reader
 *
 * @author <a href="mailto:frederic.glorieux@xfolio.org">Frédéric Glorieux</a>
 */
public class WriteFileCachingProcessingPipeline extends CachingProcessingPipeline {

    
    /**
     * <dt>Cache longest cacheable key</dt>
     * copy from 
     * <code>org.apache.cocoon.components.pipeline.impl.CachingProcessingPipeline</code>
     */

    protected void cacheResults(Environment environment, OutputStream os)  throws Exception {
        if (this.toCacheKey != null) {
            // See if there is an expires object for this resource.                
            Long expiresObj = (Long) environment.getObjectModel().get(ObjectModelHelper.EXPIRES_OBJECT);
            if ( this.cacheCompleteResponse ) {
                CachedResponse response = new CachedResponse(this.toCacheSourceValidities,
                                          ((CachingOutputStream)os).getContent(),
                                          expiresObj);
                this.cache.store(this.toCacheKey,
                                 response);
                // here is the moment where a file is written
                writeToFile(environment, os);

            
            } else {
                CachedResponse response = new CachedResponse(this.toCacheSourceValidities,
                                          (byte[])this.xmlSerializer.getSAXFragment(),
                                          expiresObj);
                this.cache.store(this.toCacheKey,
                                 response);
                // here could be a moment but Cocoon don't give the complete response
                // Perhaps it's a good practice to not write 

            }
        }
    }
    
    /** Process the pipeline using a reader.
     * @throws ProcessingException if an error occurs
     */
    protected boolean processReader(Environment  environment)
    throws ProcessingException {
        try {
            boolean usedCache = false;
            OutputStream outputStream = null;
            SourceValidity readerValidity = null;
            PipelineCacheKey pcKey = null;

            // test if reader is cacheable
            Serializable readerKey = null;
            boolean isCacheableProcessingComponent = false;
            if (super.reader instanceof CacheableProcessingComponent) {
                readerKey = ((CacheableProcessingComponent)super.reader).getKey();
                isCacheableProcessingComponent = true;
            } else if (super.reader instanceof Cacheable) {
                readerKey = new Long(((Cacheable)super.reader).generateKey());
            }

            if ( readerKey != null) {
                // response is cacheable, build the key
                pcKey = new PipelineCacheKey();
                pcKey.addKey(new ComponentCacheKey(ComponentCacheKey.ComponentType_Reader,
                                                   this.readerRole,
                                                   readerKey)
                            );

                // now we have the key to get the cached object
                CachedResponse cachedObject = this.cache.get( pcKey );

                if (cachedObject != null) {
                    if (this.getLogger().isDebugEnabled()) {
                        this.getLogger().debug(
                            "Found cached response for '" +
                            environment.getURI() + "' using key: " + pcKey);
                    }
                    SourceValidity[] validities = cachedObject.getValidityObjects();
                    if (validities == null || validities.length != 1) {
                        // to avoid getting here again and again, we delete it
                        this.cache.remove( pcKey );
                        if (this.getLogger().isDebugEnabled()) {
                            this.getLogger().debug(
                                "Cached response for '" +
                                environment.getURI() + "' using key: " +
                                pcKey + " is invalid.");
                        }
                        cachedResponse = null;
                    } else {
                        SourceValidity cachedValidity = validities[0];
                        int result = cachedValidity.isValid();
                        boolean valid = false;
                        if ( result == 0 ) {
                            // get reader validity and compare
                            if (isCacheableProcessingComponent) {
                                readerValidity = ((CacheableProcessingComponent)super.reader).getValidity();
                            } else {
                                CacheValidity cv = ((Cacheable)super.reader).generateValidity();
                                if ( cv != null ) {
                                    readerValidity = CacheValidityToSourceValidity.createValidity( cv );
                                }
                            }
                            if (readerValidity != null) {
                                result = cachedValidity.isValid(readerValidity);
                                if ( result == 0 ) {
                                    readerValidity = null;
                                } else {
                                    valid = (result == 1);
                                }
                            }
                        } else {
                            valid = (result > 0);
                        }

                        if (valid) {
                            if (this.getLogger().isDebugEnabled()) {
                                this.getLogger().debug("processReader: using valid cached content for '" + environment.getURI() + "'.");
                            }
                            byte[] response = cachedObject.getResponse();
                            if (response.length > 0) {
                                usedCache = true;
                                outputStream = environment.getOutputStream(0);
                                environment.setContentLength(response.length);
                                outputStream.write(response);
                            }
                        } else {
                            if (this.getLogger().isDebugEnabled()) {
                                this.getLogger().debug("processReader: cached content is invalid for '" + environment.getURI() + "'.");
                            }
                            // remove invalid cached object
                            this.cache.remove(pcKey);
                        }
                    }
                }
            }

            if (!usedCache) {

                if ( pcKey != null ) {
                    if (this.getLogger().isDebugEnabled()) {
                        this.getLogger().debug("processReader: caching content for further requests of '" + environment.getURI() + "'.");
                    }
                    if (readerValidity == null) {
                        if (isCacheableProcessingComponent) {
                            readerValidity = ((CacheableProcessingComponent)super.reader).getValidity();
                        } else {
                            CacheValidity cv = ((Cacheable)super.reader).generateValidity();
                            if ( cv != null ) {
                                readerValidity = CacheValidityToSourceValidity.createValidity( cv );
                            }
                        }
                    }
                    if (readerValidity != null) {
                        outputStream = environment.getOutputStream(this.outputBufferSize);
                        outputStream = new CachingOutputStream(outputStream);
                    } else {
                        pcKey = null;
                    }
                    
                }


                if (this.reader.shouldSetContentLength()) {
                    ByteArrayOutputStream os = new ByteArrayOutputStream();
                    this.reader.setOutputStream(os);
                    this.reader.generate();
                    environment.setContentLength(os.size());
                    if (outputStream == null) {
                        outputStream = environment.getOutputStream(0);
                    }
                    os.writeTo(environment.getOutputStream(0));
                } else {
                    if (outputStream == null) {
                        outputStream = environment.getOutputStream(this.outputBufferSize);
                    }
                    this.reader.setOutputStream(outputStream);
                    this.reader.generate();
                }

                // store the response
                if (pcKey != null) {
                    this.cache.store(
                        pcKey,
                        new CachedResponse( new SourceValidity[] {readerValidity},
                                            ((CachingOutputStream)outputStream).getContent())
                    );
                    // this work, but probably not optimize for long reader generation
	                FileOutputStream fileOS = getFileOS(environment);
                    this.reader.setOutputStream(fileOS);
                    this.reader.generate();
                    fileOS.close();
                }
            }
        } catch ( SocketException se ) {
            if (se.getMessage().indexOf("reset") > 0
                    || se.getMessage().indexOf("aborted") > 0
                    || se.getMessage().indexOf("connection abort") > 0) {
                throw new ConnectionResetException("Connection reset by peer", se);
            } else {
                throw new ProcessingException("Failed to execute pipeline.", se);
            }
        } catch ( ProcessingException e ) {
            throw e;
        } catch ( Exception e ) {
            throw new ProcessingException("Failed to execute pipeline.", e);
        }

        
        return true;
    }

    
    /**
     * Here is the method to write something somewhere.
     * The root folder is provide like other xfolio parameters
     * as a context parameter.
     * 
     * It's not provide when the component is parametrize, 
     * because it allows dynamic modification, and 
     * same sitemap could be executed by different servlet context.
     *
     */

    protected void writeToFile(Environment environment, OutputStream os) throws IOException {
        FileOutputStream fileOS = getFileOS(environment);
        if (fileOS != null) {
	        fileOS.write(((CachingOutputStream)os).getContent());
	        fileOS.close();
        }
    }
    
    protected FileOutputStream getFileOS(Environment environment) throws IOException {
        FileOutputStream fileOS=null;
		Context ctx = ObjectModelHelper.getContext(environment.getObjectModel());
		// get the root path of where to generate site
		String site=null;
		if (ctx != null) site=(String)ctx.getAttribute("xfolio.site");
		if (site != null && !"".equals(site)) {
		    // FIXME path may be unwaited in case of context call
		    String uri=environment.getURI();
		    // MAYDO better could be done on localisation ?
 		    if (uri==null || "".equals(uri) || uri.lastIndexOf('/')==uri.length()-1) uri += "index.html";
	        File file=new File(new File(site), uri);
	        if (!file.exists()) {
	            file.getParentFile().mkdirs();
	            file.createNewFile();
	        }
	        fileOS = new FileOutputStream(file);
		}
        return fileOS;
    }
    

}
