/*
 * Copyright 2004 xfolio.org
 * Licence : CeCILL
 *
 */
package org.apache.cocoon.generation;

import org.apache.avalon.framework.activity.Initializable;
import org.apache.avalon.framework.activity.Disposable;
import org.apache.avalon.framework.context.Context;
import org.apache.avalon.framework.context.ContextException;
import org.apache.avalon.framework.context.Contextualizable;
import org.apache.avalon.framework.parameters.ParameterException;
import org.apache.avalon.framework.parameters.Parameters;
import org.apache.cocoon.ProcessingException;
import org.apache.cocoon.environment.ObjectModelHelper;
import org.apache.cocoon.environment.Request;
import org.apache.cocoon.environment.SourceResolver;
import org.apache.lucene.analysis.Analyzer;
import org.apache.lucene.analysis.standard.StandardAnalyzer;
import org.apache.lucene.document.Document;
import org.apache.lucene.document.Field;
import org.apache.lucene.index.IndexReader;
import org.apache.lucene.queryParser.ParseException;
import org.apache.lucene.queryParser.QueryParser;
import org.apache.lucene.search.Hits;
import org.apache.lucene.search.IndexSearcher;
import org.apache.lucene.search.Query;
import org.apache.lucene.search.Searcher;
import org.apache.lucene.store.Directory;
import org.apache.lucene.store.FSDirectory;
import org.xml.sax.SAXException;
import org.xml.sax.helpers.AttributesImpl;
import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Collection;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Enumeration;
/**
 @author frederic.glorieux@xfolio.org

 = WHAT =

 = CHANGES =

 = HOW =

 = WHY =

 = REFERENCES =

 [SearchGenerator]  

 */
public class LuceneGenerator extends ServiceableGenerator
        implements
            Contextualizable,
            Initializable,
            Disposable {

    /**
     * Vocabulary
     */
    protected final static String NAMESPACE      = "http://jakarta.apache.org/lucene/ns";
    protected final static String PREFIX         = "luc";
    /** hits */
    protected final static String HITS           = "hits";
    /** directory, the index folder as a source, perhaps not a good idea to expose */
    protected final static String DIRECTORY      = "directory";
    /** version, last modification of the index */
    protected final static String VERSION        = "version";
    /** date, date of the query */
    protected final static String DATE           = "date";
    /** query, the query string, attribute of root */
    protected final static String QUERY          = "query";
    /** analyser, class of the analyser used to parse the query string, 
     * attribute of root for a query, may be for each multilingual field */
    protected final static String ANALYSER       = "analyser";
    /** fields, the field names of an index, attribute of root */
    protected final static String FIELDS          = "fields";
    /** length, number of hits, attribute of root */
    protected final static String LENGTH         = "length";
    /** page, page number according to paging and start, attribute of root */
    protected final static String START          = "start";
    /** paging, hits per page, attribute of root */
    protected final static String PAGING         = "paging";
    /** page, page number according to paging and start, attribute of root */
    protected final static String PAGE           = "page";
    /** end, end index in hits, attribute of root */
    protected final static String END            = "end";
    /** sort, field on which hits are sorted, attribute of root */
    protected final static String SORT           = "sort";
    /** text, field on which searching by default, attribute of root */
    protected final static String TEXT           = "text";
    /** document, the hit element, children of root */
    protected final static String DOCUMENT       = "document";
    /** count, attribute of document  */
    protected final static String COUNT          = "count";
    /** id, attribute of document */
    protected final static String ID             = "id";
    /** score, attribute of document */
    protected final static String SCORE          = "score";
    /** rank, attribute of document */
    protected final static String RANK           = "rank";
    /** boost, attribute of document or field */
    protected final static String BOOST          = "boost";
    /** field, children of document */
    protected final static String FIELD          = "field";
    /** name, name of field, field attribute */
    protected final static String NAME           = "name";
    /** index, is indexed, property of a field, true/false */
    protected final static String INDEX          = "index";
    /** token, is tokenised (analysed), property of a field, true/false */
    protected final static String TOKEN          = "token";
    /** store, is stored, property of a field, true/false */
    protected final static String STORE          = "store";
    protected final static String NEXT           = "next";
    protected final static String PREV           = "prev";
    /** A date formatter */
    protected SimpleDateFormat dateFormat = new SimpleDateFormat(
            "yyyy-MM-dd' 'HH:mm:ss");
    /** Attributes, SAX commodity */
    private final AttributesImpl  atts           = new AttributesImpl();
    /** CDATA, SAX commodity */
    private final String          CDATA          = "CDATA";
    /** start, index from which to start */
    private int                   start          = -1;
    /** paging default */
    private final static int      START_DEFAULT  = 0;
    /** paging, hits per page */
    private int                   paging         = 20;
    /** paging default */
    private final static int      PAGING_DEFAULT = 20;
    /** paging max */
    private final static int      PAGING_MAX     = 100;
    /** page, page number */
    private int                   page           = 0;
    /** directory, filepath of a directory to search */
    private File                  directory;
    /** query, the query string */
    private String                query;
    /** default, the default field where to search */
    private String                text           = "text";
    /** class analyser */
    private String                analyser       = "org.apache.lucene.analysis.standard.StandardAnalyzer";
    /**
     * Contextualize this class.
     */
    public void contextualize(Context context) throws ContextException {
        // nothing for now
    }
    /**
     * Initialize this class.
     */
    public void initialize() throws IOException {
        // nothing for now
    }
    /**
     * setup all members of this generator.
     *
     * @since
     */
    public void setup(SourceResolver resolver, Map objectModel, String src,
            Parameters par) throws ProcessingException, SAXException,
            IOException {
        super.setup(resolver, objectModel, src, par);
        try {
            // get directory from sitemap, default value in work ?
            this.directory = new File(par.getParameter(DIRECTORY));
            // TODO more tests here
        } catch (ParameterException e) {
            throw new ProcessingException(
                    "sitemap parameter needed for a valid lucene directory");
        }
        //  get analyser from sitemap
        this.analyser = par.getParameter(ANALYSER, this.analyser);
        Request request = ObjectModelHelper.getRequest(objectModel);
        // start
        this.start = integer(request.getParameter(START), -1);
        // get query from request
        // TODO merge query with something provide from sitemap
        this.query = request.getParameter(QUERY);
        // if a query, then start should begin at 0
        if (this.query != null && this.start == -1) this.start = 0;
        // get paging
        this.paging = integer(String.valueOf(par.getParameter(PAGING, String
                .valueOf(PAGING_DEFAULT))), PAGING_DEFAULT);
        this.paging = integer(request.getParameter(PAGING), PAGING_DEFAULT);
        if (this.paging > PAGING_MAX) this.paging = PAGING_MAX;
    }
    /**
     * start document.
     *
     * @exception  IOException       when there is a problem reading the from file system.
     * @since
     * @throws  SAXException         when there is a problem creating the output SAX events.
     * @throws  ProcessingException  when there is a problem obtaining the hits
     */
    public void generate() throws IOException, SAXException,
            ProcessingException {
        // Start the document and set the namespace.
        this.contentHandler.startDocument();
        this.contentHandler.startPrefixMapping(PREFIX, NAMESPACE);
        // this.contentHandler.startPrefixMapping("xlink", XLINK_NAMESPACE); ?
        // TODO, list of terms
        try {
            root();
        } catch (ParseException e) {
            // if imparsable query
            // should do something there with a friendly localised message ?
        }
        // End the document.
        // this.contentHandler.endPrefixMapping("xlink"); ?
        this.contentHandler.endPrefixMapping(PREFIX);
        this.contentHandler.endDocument();
    }
    /**
     * Root element
     *
     *
     * @exception  IOException       when there is a problem reading the from file system.
     * @since
     * @throws  SAXException         when there is a problem creating the output SAX events.
     * @throws  ProcessingException  when there is a problem obtaining the hits
     */
    public void root() throws IOException, SAXException, ParseException,
            ProcessingException {
        Directory fsDir = FSDirectory.getDirectory(directory, false);
        // TODO optimize indexReader ? 
        IndexReader ir = IndexReader.open(fsDir);
        // ? System.out.println(IndexReader.isLocked(fsDir));
        String fields=" ";
        Collection fn = ir.getFieldNames();
        Iterator it = fn.iterator();
        while (it.hasNext()) {
            fields+=(String)it.next()+" ";
        }

        atts.clear();
        atts.addAttribute("", DATE, DATE, CDATA, dateFormat.format(new Date()));
        atts.addAttribute("", VERSION, VERSION, CDATA, String
                .valueOf(IndexReader.getCurrentVersion(fsDir)));
        atts.addAttribute("", START, START, CDATA, String.valueOf(start));
        atts.addAttribute("", PAGING, PAGING, CDATA, String.valueOf(paging));
        atts.addAttribute("", LENGTH, LENGTH, CDATA, String.valueOf(ir.maxDoc()));
        atts.addAttribute("", DIRECTORY, DIRECTORY, CDATA, directory
                .getCanonicalPath());
        atts.addAttribute("", FIELDS, FIELDS, CDATA, fields);
        if (query != null) {

            Analyzer analyser = null;
            try {
                analyser = (Analyzer) Class.forName(this.analyser).newInstance();
            } catch (InstantiationException e) {
                throw new ParseException(e.getLocalizedMessage());
            } catch (IllegalAccessException e) {
                throw new ParseException(e.getLocalizedMessage());
            } catch (ClassNotFoundException e) {
                throw new ParseException(e.getLocalizedMessage());
            }
            // atts.addAttribute("", ANALYSER, ANALYSER, CDATA, tokenizer.getClass().getName());
            Searcher searcher = new IndexSearcher(fsDir);
            // should find better logic on field names (first indexed, unstore field)
            Query q = QueryParser.parse(query, text, analyser);
            System.out.println(q);
            Hits hits = searcher.search(q);
            atts.addAttribute("", QUERY, QUERY, CDATA, String
                    .valueOf(query));
            atts.addAttribute("", HITS, HITS, CDATA, String.valueOf(hits.length()));
        }
        contentHandler.startElement(NAMESPACE, INDEX, PREFIX + ":" + INDEX,
                atts);
        /*
         // loop on hits from start to end
         int end = (start + paging < hits.length()) ? start + paging : hits
         .length() - 1;
         for (int i = start; i < end; i++) {
         Document doc = hits.doc(i);
         // pass some atts to doc
         atts.clear();
         atts.addAttribute("", COUNT, COUNT, CDATA, String.valueOf(i));
         atts.addAttribute("", SCORE, SCORE, CDATA, String.valueOf(hits
         .score(i)));
         atts.addAttribute("", ID, ID, CDATA, String.valueOf(hits.id(i)));
         document(doc);
         }
         */
        // close the root
        if (false) {
        }
        // careful public start begins at 1
        else if (this.start > 0 && this.start <= ir.maxDoc()) {
            int end = (start + paging <= ir.maxDoc()) ? start + paging - 1 : ir
                    .maxDoc();
            for (int i = start -1 ; i < end; i++) {
                Document doc = ir.document(i);
                // clear atts here, before passing some atts to doc
                atts.clear();
                atts.addAttribute("", COUNT, COUNT, CDATA, String.valueOf(i + 1));
                document(doc);
            }
        }
        ir.close();
        contentHandler.endElement(NAMESPACE, INDEX, PREFIX + ":" + INDEX);
    }
    /**
     * Generate the xml content of a document
     *
     * @param  doucument             a Lucene document
     * @since
     * @throws  SAXException         when there is a problem creating the output SAX events.
     */
    private void document(Document doc) throws SAXException {
        atts.addAttribute("", BOOST, BOOST, CDATA, String.valueOf(doc
                .getBoost()));
        contentHandler.startElement(NAMESPACE, DOCUMENT, PREFIX + ":"
                + DOCUMENT, atts);
        // for debug only
        // contentHandler.characters(doc.toString().toCharArray(), 0, doc.toString().length());
        int i = 0;
        for (Enumeration e = doc.fields(); e.hasMoreElements();) {
            Field field = (Field) e.nextElement();
            if (field.isStored()) {
                // pass some atts to field
                atts.clear();
                i++;
                atts.addAttribute("", COUNT, COUNT, CDATA, String.valueOf(i));
                field(field);
            }
        }
        contentHandler.endElement(NAMESPACE, DOCUMENT, PREFIX + ":" + DOCUMENT);
    }
    /**
     * Generate xml for a field
     *
     * @param  field             a Lucene field
     * @since
     * @throws  SAXException         when there is a problem creating the output SAX events.
     */
    private void field(Field field) throws SAXException {
        atts.addAttribute("", BOOST, BOOST, CDATA, String.valueOf(field
                .getBoost()));
        atts.addAttribute("", INDEX, INDEX, CDATA, String.valueOf(field
                .isIndexed()));
        atts.addAttribute("", STORE, STORE, CDATA, String.valueOf(field
                .isStored()));
        atts.addAttribute("", TOKEN, TOKEN, CDATA, String.valueOf(field
                .isTokenized()));
        contentHandler.startElement(NAMESPACE, FIELD, PREFIX + ":" + FIELD,
                atts);
        String value = field.stringValue();
        contentHandler.characters(value.toCharArray(), 0, value.length());
        contentHandler.endElement(NAMESPACE, FIELD, PREFIX + ":" + FIELD);
    }
    /**
     *   Create an Integer from String s, if conversion fails return default value.
     *
     * @param  s  Converting s to an Integer
     * @return    Integer converted value originating from s, or default value
     * @since
     */
    private int integer(String s, int i) {
        try {
            return new Integer(s).intValue();
        } catch (NumberFormatException nfe) {
            // useful ? ignore it, write only warning
            getLogger().debug("Cannot convert " + s + " to Integer");
            return i;
        }
    }
    /**
     * Recycle the generator
     */
    public void recycle() {
        super.recycle();
        this.query = null;
        this.start = 0;
        this.paging = 20;
    }
    public void dispose() {
        super.dispose();
    }
}