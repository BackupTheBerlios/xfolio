

import javax.xml.transform.TransformerFactory;
import org.xml.sax.Attributes;
import org.xml.sax.ContentHandler;
import org.xml.sax.Locator;
import org.xml.sax.SAXException;
import org.xml.sax.ext.LexicalHandler;

/**
 * A special purpose <code>XMLConsumer</code> which can:
 * <ul>
 * <li>Trim empty characters if
 *     {@link #setIgnoreEmptyCharacters(boolean) ignoreEmptyCharacters} is set.
 * <li>Ignore root element if
 *     {@link #setIgnoreRootElement(boolean) ignoreRootElement} is set.
 * <li>Ignore startDocument, endDocument events.
 * <li>Ignore startDTD, endDTD, and all comments within DTD.
 * </ul>
 *
 * <p>It is more complicated version of {@link EmbeddedXMLPipe} which, except
 * being used to include other files into the SAX events stream, can perform
 * optional operations described above.</p>
 *
 * @see EmbeddedXMLPipe
 * @author <a href="mailto:bloritsch@apache.org">Berin Loritsch</a>
 * @author <a href="mailto:cziegeler@apache.org">Carsten Ziegeler</a>
 * @version CVS $Id: IncludeXMLConsumer.java,v 1.1 2004/11/04 21:29:10 glorieux Exp $
 */
public class IncludeXMLConsumer implements ContentHandler, LexicalHandler {

    /** The TrAX factory for serializing xml */
    private static final TransformerFactory FACTORY = TransformerFactory.newInstance();

    private final ContentHandler contentHandler;
    private final LexicalHandler lexicalHandler;

    private boolean ignoreEmptyCharacters;
    private boolean ignoreRootElement;
    private int     ignoreRootElementCount;
    private boolean inDTD;


    /**
     * Constructor
     */
    public IncludeXMLConsumer (ContentHandler contentHandler, LexicalHandler lexicalHandler) {
        this.contentHandler = contentHandler;
        this.lexicalHandler = lexicalHandler;
    }

    /**
     * Constructor
     */
    public IncludeXMLConsumer (ContentHandler contentHandler) {
        this.contentHandler = contentHandler;
        this.lexicalHandler = contentHandler instanceof LexicalHandler ? (LexicalHandler)contentHandler : null;
    }


    /**
     * Control SAX event handling.
     * If set to <code>true</code> all empty characters events are ignored.
     * The default is <code>false</code>.
     */
    public void setIgnoreEmptyCharacters(boolean value) {
        this.ignoreEmptyCharacters = value;
    }

    /**
     * Control SAX event handling.
     * If set to <code>true</code> the root element is ignored.
     * The default is <code>false</code>.
     */
    public void setIgnoreRootElement(boolean value) {
        this.ignoreRootElement = value;
        this.ignoreRootElementCount = 0;
    }

    //
    // ContentHandler interface
    //

    public void setDocumentLocator(Locator loc) {
        this.contentHandler.setDocumentLocator(loc);
    }

    public void startDocument() throws SAXException {
        // Ignored
    }

    public void endDocument() throws SAXException {
        // Ignored
    }

    public void startPrefixMapping(String prefix, String uri) throws SAXException {
        this.contentHandler.startPrefixMapping(prefix, uri);
    }

    public void endPrefixMapping(String prefix) throws SAXException {
        this.contentHandler.endPrefixMapping(prefix);
    }

    public void startElement(String uri, String local, String qName, Attributes attr) throws SAXException {
        if (this.ignoreRootElement == false ||
            this.ignoreRootElementCount > 0) {
            this.contentHandler.startElement(uri,local,qName,attr);
        }
        this.ignoreRootElementCount++;
    }

    public void endElement(String uri, String local, String qName) throws SAXException {
        this.ignoreRootElementCount--;
        if (!this.ignoreRootElement  || this.ignoreRootElementCount > 0) {
            this.contentHandler.endElement(uri, local, qName);
        }
    }

    public void characters(char[] ch, int start, int end) throws SAXException {
        if (this.ignoreEmptyCharacters) {
            String text = new String(ch, start, end).trim();
            if (text.length() > 0) {
                this.contentHandler.characters(text.toCharArray(), 0, text.length());
            }
        } else {
            this.contentHandler.characters(ch, start, end);
        }
    }

    public void ignorableWhitespace(char[] ch, int start, int end) throws SAXException {
        if (!this.ignoreEmptyCharacters) {
            this.contentHandler.ignorableWhitespace(ch, start, end);
        }
    }

    public void processingInstruction(String name, String value) throws SAXException {
        this.contentHandler.processingInstruction(name, value);
    }

    public void skippedEntity(String ent) throws SAXException {
        this.contentHandler.skippedEntity(ent);
    }

    //
    // LexicalHandler interface
    //

    public void startDTD(String name, String public_id, String system_id)
    throws SAXException {
        // Ignored
        this.inDTD = true;
    }

    public void endDTD() throws SAXException {
        // Ignored
        this.inDTD = false;
    }

    public void startEntity(String name) throws SAXException {
        if (lexicalHandler != null) {
            lexicalHandler.startEntity(name);
        }
    }

    public void endEntity(String name) throws SAXException {
        if (lexicalHandler != null) {
            lexicalHandler.endEntity(name);
        }
    }

    public void startCDATA() throws SAXException {
        if (lexicalHandler != null) {
            lexicalHandler.startCDATA();
        }
    }

    public void endCDATA() throws SAXException {
        if (lexicalHandler != null) {
            lexicalHandler.endCDATA();
        }
    }

    public void comment(char ary[], int start, int length) throws SAXException {
        if (!inDTD && lexicalHandler != null) {
            lexicalHandler.comment(ary,start,length);
        }
    }
}
