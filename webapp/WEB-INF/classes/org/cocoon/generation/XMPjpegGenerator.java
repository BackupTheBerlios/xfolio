package org.apache.cocoon.generation;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.StringReader;
import java.util.Iterator;
import java.util.Map;
import java.util.Vector;
import org.apache.avalon.framework.parameters.Parameters;
import org.apache.avalon.framework.service.ServiceException;
import org.apache.cocoon.ProcessingException;
import org.apache.cocoon.caching.CacheableProcessingComponent;
import org.apache.cocoon.components.source.SourceUtil;
import org.apache.cocoon.environment.SourceResolver;
import org.apache.excalibur.source.Source;
import org.apache.excalibur.source.SourceException;
import org.apache.excalibur.source.SourceValidity;
import org.apache.excalibur.xml.sax.SAXParser;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;
import org.xml.sax.helpers.AttributesImpl;
/**
[[TableOfContents([3])]]


Copyright (C) xfolio.org 

= WHAT =

The XMPjpegGenerator extracts [XMP] from a jpeg file. This AdobeTM XML can
encode metadatas like title, author, description... This schema implements an
open standard knowed as [IPTC/IMM]. For your photos, try for example an app
like [pixVue], it allows you to add different infos, encoded in jpeg headers,
with also an XML/XMP embed. 

= HOW =

Find and compile XMPjpegGenerator.java
<http://cvs.berlios.de/cgi-bin/viewcvs.cgi/xfolio/webapp/WEB-INF/classes/org/cocoon/generation/ >
or put the binary classes in the same way in your cocoon webapp 
{cocoon}/WEB-INF/org/apache/cocoon/generation/( XMPjpegGenerator.class | XMPjpegGenerator$JpegException.class | XMPjpegGenerator$MarkerVector.class)

In your sitemap, declare and use the component

{{{
  <map:components>
    <map:generators default="file">
      <map:generator name="xmp" src="org.apache.cocoon.generation.XMPjpegGenerator"/> 
    </map:generators>
  </map:components>

  <map:match pattern="gallery/**.xmp">
    <map:generate type="xmp" src="gallery/{1}.jpg"/>
    <map:serialize type="xml"/>
  </map:match>
}}}

= WHO =

Persons in historic order, but not of importance

[FG] Glorieux, Frédéric [AJLSM] Integration of W3C classes as a cocoon generator 

[PD] Dittgen, Pierre [PassTech] Refactoring W3C classes 

[nwalsh] Walsh, Norman Seems the most active maintener of jpeg metadata classes in his [jpegrdf] project 

[PF] Fumagalli, Pierpaolo (Apache Software Foundation) 

[CZ] Ziegeler, Carsten. Original authors of [fileGenerator]

= REFERENCES =

[xmpJpegGenerator] http://cvs.berlios.de/cgi-bin/viewcvs.cgi/xfolio/webapp/WEB-INF/classes/org/cocoon/generation/ 

[fileGenerator] http://cocoon.apache.org/2.1/apidocs/org/apache/cocoon/generation/FileGenerator.html

[sourceUtil] http://cocoon.apache.org/2.1/apidocs/org/apache/cocoon/components/source/SourceUtil.html

[jpegHeaders] http://dev.w3.org/cvsweb/~checkout~/java/classes/org/w3c/tools/jpeg/JpegHeaders.java http://cvs.sourceforge.net/viewcvs.py/jpegrdf/jpegrdf/src/org/w3c/tools/jpeg/JpegHeaders.java >

[jpegrdf] Walsh, Norman "JpegRDF" reads and manipulates RDF metadata stored in JPEG images http://sourceforge.net/projects/jpegrdf

[pixvue] Colemenan, Eamon. An MS.Windows Image Organizer, XMP compatible http://pixvue.com/ 

[IPTC/IMM] "IPTC - NAA INFORMATION INTERCHANGE MODEL" http://www.iptc.org/IIM/

[XMP] Adobe Systems Incorporated "Extensible Metadata Platform (XMP)" http://www.adobe.com/products/xmp/main.html 
Adobe's Extensible Metadata Platform (XMP) is a labeling technology that
allows you to embed data about a file, known as metadata, into the file
itself. With XMP, desktop applications and back-end publishing systems gain a
common method for capturing, sharing, and leveraging this valuable metadata -
opening the door for more efficient job processing, workflow automation, and
rights management, among many other possibilities. With XMP, Adobe has taken
the "heavy lifting" out of metadata integration, offering content creators an
easy way to embed meaningful information about their projects and providing
industry partners with standards-based building blocks to develop optimized
workflow solutions. 

[passTech] Boutros, Nader ; Dittgen, Pierre. http://pass-tech.fr/

[AJLSM] Arvers, Jean-Luc; Sévigny, Martin "Solution pour le document numérique" http://ajlsm.com

= SEE ALSO =

Generated links

|| '''cited by'''   || '''about XMP'''         || '''about generator''' ||
|| [[FullSearch()]] || [[PageList(xmp)]] || [[PageList(generator)]] ||

 
 */
public class XMPjpegGenerator extends ServiceableGenerator
        implements
            CacheableProcessingComponent {

    /** The input source */
    protected Source         inputSource;
    protected InputStream    in;
    /**
     * @version $Revision: 1.3 $
     * @author Benoît Mahé (bmahe@w3.org)
     */
    /* Start Of Frame N. */
    static final int         M_SOF0           = 0xC0;
    /* N indicates which compression process. */
    static final int         M_SOF1           = 0xC1;
    /* Only SOF0-SOF2 are now in common use */
    static final int         M_SOF2           = 0xC2;
    static final int         M_SOF3           = 0xC3;
    /* NB: codes C4 and CC are NOT SOF markers */
    static final int         M_SOF5           = 0xC5;
    static final int         M_SOF6           = 0xC6;
    static final int         M_SOF7           = 0xC7;
    static final int         M_SOF9           = 0xC9;
    static final int         M_SOF10          = 0xCA;
    static final int         M_SOF11          = 0xCB;
    static final int         M_SOF13          = 0xCD;
    static final int         M_SOF14          = 0xCE;
    static final int         M_SOF15          = 0xCF;
    /* Start Of Image (beginning of datastream) */
    static final int         M_SOI            = 0xD8;
    /* End Of Image (end of datastream) */
    static final int         M_EOI            = 0xD9;
    /* Start Of Scan (begins compressed data) */
    static final int         M_SOS            = 0xDA;
    /* Application-specific marker, type N */
    static final int         M_APP0           = 0xE0;
    static final int         M_APP1           = 0xE1;
    static final int         M_APP2           = 0xE2;
    static final int         M_APP3           = 0xE3;
    static final int         M_APP4           = 0xE4;
    static final int         M_APP5           = 0xE5;
    static final int         M_APP6           = 0xE6;
    static final int         M_APP7           = 0xE7;
    static final int         M_APP8           = 0xE8;
    static final int         M_APP9           = 0xE9;
    static final int         M_APP10          = 0xEA;
    static final int         M_APP11          = 0xEB;
    static final int         M_APP12          = 0xEC;
    static final int         M_APP13          = 0xED;
    static final int         M_APP14          = 0xEE;
    static final int         M_APP15          = 0xEF;
    static final int         M_COM            = 0xFE;
    /** The maximal comment length */
    static final int         M_MAX_COM_LENGTH = 65500;
    /** Marker character. */
    private static final int MARKER_CHAR      = 0xFF;
    /** Nb of application markers. */
    private static final int NB_APP_MARKERS   = 16;
    /** Buffer size (used in getXMP() method). */
    private static final int BUFF_SIZE        = 256;
    protected int            compression      = -1;
    protected int            bitsPerPixel     = -1;
    protected int            height           = -1;
    protected int            width            = -1;
    protected int            numComponents    = -1;
    /** Vector of Com markers. */
    protected MarkerVector   vcom             = null;
    /** Vector of Application markers. */
    protected MarkerVector[] vacom            = null;
    /**
     * Convenience object, so we don't need to create an AttributesImpl for
     * every element.
     */
    protected AttributesImpl attributes       = new AttributesImpl();
    /**
     * Recycle this component. All instance variables are set to
     * <code>null</code>.
     */
    public void recycle() {
        if (null != this.inputSource) {
            super.resolver.release(this.inputSource);
            this.inputSource = null;
        }
        super.recycle();
    }
    /**
     * Setup the file generator. Try to get the last modification date of the
     * source for caching.
     */
    public void setup(SourceResolver resolver, Map objectModel, String src,
            Parameters par) throws ProcessingException, SAXException,
            IOException {
        super.setup(resolver, objectModel, src, par);
        try {
            this.inputSource = super.resolver.resolveURI(src);
        } catch (SourceException se) {
            throw SourceUtil.handle("Error during resolving of '" + src + "'.",
                    se);
        }
    }
    /**
     * Generate the unique key. This key must be unique inside the space of this
     * component.
     * 
     * @return The generated key hashes the src
     */
    public java.io.Serializable getKey() {
        return this.inputSource.getURI();
    }
    /**
     * Generate the validity object.
     * 
     * @return The generated validity object or <code>null</code> if the
     *         component is currently not cacheable.
     */
    public SourceValidity getValidity() {
        return this.inputSource.getValidity();
    }
    /**
     * Generate XML data.
     */
    public void generate() throws IOException, SAXException,
            ProcessingException {
        try {
            if (getLogger().isDebugEnabled()) {
                getLogger().debug(
                        "Source " + super.source + " resolved to "
                                + this.inputSource.getURI());
            }
            String xmp;
            in = null;
            in = inputSource.getInputStream();
            try {
                scanHeaders();
                xmp = this.getXMP();
            }
            // FG 2004-10-09
            // TODO, better Exception handling in case of guilty image
            catch (JpegException e) {
                getLogger().error("XMP Generator " + this.inputSource.getURI(),
                        e);
                xmp = "<test/>";
            }
            /*
             * from default file generator SourceUtil.parse(this.manager,
             * this.inputSource, super.xmlConsumer);
             */
            //SourceUtil.parse(this.manager, this.inputSource,
            // super.xmlConsumer);
            // from org.apache.cocoon.components.source.SourceUtil;
            SAXParser parser = null;
            parser = (SAXParser) manager.lookup(SAXParser.ROLE);
            parser.parse(new InputSource(new StringReader(xmp)),
                    this.contentHandler);
        } catch (ServiceException e) {
            throw new ProcessingException(e);
        } catch (SAXException e) {
            final Exception cause = e.getException();
            if (cause != null) {
                if (cause instanceof ProcessingException) { throw (ProcessingException) cause; }
                if (cause instanceof IOException) { throw (IOException) cause; }
                if (cause instanceof SAXException) { throw (SAXException) cause; }
                throw new ProcessingException("Could not read resource "
                        + this.inputSource.getURI(), cause);
            }
            throw e;
        } finally {
            if (in != null) in.close();
            in = null;
        }
    }
    /**
     * Gets XMP in APP1.
     * 
     * from
     * http://cvs.sourceforge.net/viewcvs.py/jpegrdf/jpegrdf/src/org/w3c/tools/jpeg/JpegHeaders.java
     * 
     * @return XMP info as a unicode string
     * @throws IOException
     *             If a I/O read error occurred
     * @throws JpegException
     *             For all other reasons
     */
    public String getXMP() throws IOException, JpegException {
        // Pattern to search at the really beginning of XMP.
        byte[] xmpStart = "<?xp".getBytes();
        // Pattern to search at the beginning of XMP.
        byte[] xmpStamp = "W5M0MpCehiHzreSzNTczkc9d".getBytes();
        // Pattern indicating end of XMP.
        byte[] xmpEnd = "<?xpacket".getBytes();
        // Closing pattern
        byte[] xmpClose = ">".getBytes();
        // Gets XMPApp1Marker
        byte[] input = vacom[M_APP1 - M_APP0].getBytes();
        // Look for magic number
        int pos = find(input, 2, xmpStamp);
        if (pos == -1)
                throw new JpegException("XMP stamp not found : " + xmpStamp);
        // Search <?xp before magic number
        int beginIndex = find(input, pos, xmpStart, false);
        if (beginIndex == -1)
                throw new JpegException("XMP start not found " + xmpStart);
        // Then search magic end
        int endIndex = find(input, pos, xmpEnd);
        if (endIndex == -1)
                throw new JpegException("XMP end not found " + xmpEnd);
        // Then closing '>'
        endIndex = find(input, endIndex, xmpClose) + 1;
        if (endIndex == 0) throw new JpegException("XMP not valid XML");
        // Extract significant bytes
        byte[] result = new byte[endIndex - beginIndex];
        System.arraycopy(input, beginIndex, result, 0, result.length);
        return new String(result, "UTF-8");
    }
    /**
     * Finds a pattern in a buffer from an offset forward. This is a shortcut
     * for the other find() method.
     * 
     * @param haystack
     *            The buffer to search in.
     * @param offset
     *            The offset to search from.
     * @param needle
     *            The pattern to search
     * @return First position where the pattern is found, else -1
     */
    private int find(byte[] haystack, int offset, byte[] needle) {
        return find(haystack, offset, needle, true);
    }
    /**
     * Finds a pattern in a buffer from an offset forward or backward.
     * 
     * @param haystack
     *            The buffer to search in.
     * @param offset
     *            The offset to search from.
     * @param needle
     *            The pattern to search
     * @param forward
     *            The direction, true to search forward
     * @return First position where the pattern is found, else -1
     */
    private int find(byte[] haystack, int offset, byte[] needle, boolean forward) {
        if (needle.length == 0) return -1;
        int maxpos = haystack.length - needle.length;
        int step = (forward) ? 1 : -1;
        for (int pos = offset; pos >= 0 && pos <= maxpos; pos += step) {
            if (isAtPos(haystack, pos, needle)) { return pos; }
        }
        return -1;
    }
    /**
     * Tests if a pattern (contained in a byte array) is present at a position
     * of another byte array.
     * 
     * @param buffer
     *            The buffer to search in
     * @param offset
     *            The offset to search at
     * @param pattern
     *            The pattern to search
     * @return True if the pattern is found, else false
     */
    private boolean isAtPos(byte[] buffer, int offset, byte[] pattern) {
        int totallen = buffer.length;
        for (int i = 0; i < pattern.length; i++) {
            if (i + offset >= totallen) return false;
            if (buffer[i + offset] != pattern[i]) return false;
        }
        return true;
    }
    /**
     * Main method. Scan headers and prepare information for following work.
     * 
     * @return Last seen marker?
     * @throws IOException
     *             If I/O error occurs
     * @throws JpegException
     *             If Jpeg header is broken
     */
    protected int scanHeaders() throws IOException, JpegException {
        // Init members
        vcom = new MarkerVector();
        vacom = new MarkerVector[NB_APP_MARKERS];
        for (int i = 0; i < NB_APP_MARKERS; i++) {
            vacom[i] = new MarkerVector();
        }
        readFirstMarker();
        // Scan each found marker
        while (true) {
            int marker = nextMarker();
            switch (marker) {
                case M_SOF0 : /* Baseline */
                case M_SOF1 : /* Extended sequential, Huffman */
                case M_SOF2 : /* Progressive, Huffman */
                case M_SOF3 : /* Lossless, Huffman */
                case M_SOF5 : /* Differential sequential, Huffman */
                case M_SOF6 : /* Differential progressive, Huffman */
                case M_SOF7 : /* Differential lossless, Huffman */
                case M_SOF9 : /* Extended sequential, arithmetic */
                case M_SOF10 : /* Progressive, arithmetic */
                case M_SOF11 : /* Lossless, arithmetic */
                case M_SOF13 : /* Differential sequential, arithmetic */
                case M_SOF14 : /* Differential progressive, arithmetic */
                case M_SOF15 : /* Differential lossless, arithmetic */
                    // Remember the kind of compression we saw
                    compression = marker;
                    // Get the intrinsic properties fo the image
                    readImageInfo();
                    break;
                case M_SOS : /* stop before hitting compressed data */
                    skipVariable();
                    // Updates the Exif
                    // [FG] 2004-10-10 Not yet implemented
                    // updateExif();
                    return marker;
                case M_EOI : /* in case it's a tables-only JPEG stream */
                    // Updates the Exif
                    // [FG] 2004-10-10 Not yet implemented
                    // updateExif();
                    return marker;
                case M_COM :
                    vcom.addMarker(processComment());
                    break;
                case M_APP0 :
                case M_APP1 :
                case M_APP2 :
                case M_APP3 :
                case M_APP4 :
                case M_APP5 :
                case M_APP6 :
                case M_APP7 :
                case M_APP8 :
                case M_APP9 :
                case M_APP10 :
                case M_APP11 :
                case M_APP12 :
                case M_APP13 :
                case M_APP14 :
                case M_APP15 :
                    // Some digital camera makers put useful textual
                    // information into APP1 andAPP12 markers, so we print
                    // those out too when in -verbose mode.
                    byte[] data = processComment();
                    vacom[marker - M_APP0].addMarker(data);
                    // This is where the EXIF data is stored, grab it and parse it!
                    if (marker == M_APP1) { // APP1 == EXIF
                        /* [FG] 2004-10-10 not implemented 
                         if (exif != null) {
                         exif.parseExif(data);
                         }
                         */
                    }
                    break;
                default : // Anything else just gets skipped
                    skipVariable(); // we assume it has a parameter count...
                    break;
            }
        }
    }
    /**
     * skip the body after a marker.
     *
     * @throws IOException If a I/O read error occurred
     * @throws JpegException If something weird occurs
     */
    protected void skipVariable() throws IOException, JpegException {
        processComment();
    }
    /**
     * Process JPEG comment: reads a whole comment and returns it.
     *
     * @return Read comment
     * @throws IOException If a I/O read error occurs
     * @throws JpegException If the comment is broken
     */
    protected byte[] processComment() throws IOException, JpegException {
        // Get the marker parameter length count
        int length = readLength(in);
        // Copy comment into a byte array
        byte[] comment = new byte[length];
        int pos = 0;
        while (length > 0) {
            int got = in.read(comment, pos, length);
            if (got < 0)
                    throw new JpegException("EOF while reading jpeg comment");
            pos += got;
            length -= got;
        }
        return comment;
    }
    /**
     * Reads length of a marker from the given input stream.
     *
     * @param is Input stream to read from
     * @return Read length - 2
     * @throws IOException If the two bytes needed to compute length can't be
     * read
     * @throws JpegException If the length is less than 2
     */
    private int readLength(InputStream is) throws IOException, JpegException {
        int c1 = read(is);
        int c2 = read(is);
        int length = (c1 << 8) + c2;
        // Length includes itself, so must be at least 2
        if (length < 2)
                throw new JpegException("Erroneous JPEG marker length");
        return length - 2;
    }
    /**
     * Reads first marker and checks its validity.
     * 
     * @throws IOException
     *             If a I/O read error occurred
     * @throws JpegException
     *             If the marker is invalid
     */
    protected void readFirstMarker() throws IOException, JpegException {
        int c1 = read(in);
        int c2 = read(in);
        if (c1 != MARKER_CHAR || c2 != M_SOI)
                throw new JpegException("Not a JPEG file");
    }
    /**
     * Seeks next marker.
     * 
     * @return First character read after first marker
     * @throws IOException
     *             If a I/O read error occurred
     * @throws JpegException
     *             If something weird occurs
     */
    protected int nextMarker() throws IOException, JpegException {
        /* Find 0xFF byte; count and skip any non-FFs. */
        int c = read(in);
        while (c != MARKER_CHAR) {
            c = read(in);
        }
        /*
         * Get marker code byte, swallowing any duplicate FF bytes. Extra FFs
         * are legal as pad bytes, so don't count them in discarded_bytes.
         */
        do {
            c = read(in);
        } while (c == MARKER_CHAR);
        return c;
    }
    /**
     * Reads a char from the given input stream.
     * 
     * @param anInputStream
     *            The input stream to read from
     * @return Character read
     * @throws IOException
     *             If the character can't be read
     * @throws JpegException
     *             If we reach the end of file
     */
    private int read(final InputStream anInputStream) throws IOException,
            JpegException {
        int cc = anInputStream.read();
        if (cc == -1) throw new JpegException("Premature EOF in Jpeg file");
        return cc;
    }
    /**
     * read the image info then the section
     */
    protected void readImageInfo() throws IOException, JpegException {
        long len = (long) readLength(in);
        bitsPerPixel = read(in);
        len--;
        height = readLength(in) + 2;
        len -= 2;
        width = readLength(in) + 2;
        len -= 2;
        numComponents = read(in);
        len--;
        while (len > 0) {
            long saved = in.skip(len);
            if (saved < 0)
                    throw new IOException("Error while reading jpeg stream");
            len -= saved;
        }
    }
    /**
     * Handy class that handles a list of marker byte arrays.
     */
    private static class MarkerVector {

        /** Byte array list. */
        private Vector buffers = new Vector();
        /**
         * Adds a marker byte array to the list.
         * 
         * @param aBuff
         *            Marker content
         */
        public void addMarker(final byte[] aBuff) {
            buffers.add(aBuff);
        }
        /**
         * Builds an array of unicode strings from the marker list.
         * 
         * @return Array of unicode strings.
         * @throws IOException
         *             If an encoding error occurred.
         */
        public String[] getStringArray() throws IOException {
            String[] toReturn = new String[buffers.size()];
            for (int i = 0; i < toReturn.length; i++) {
                toReturn[i] = new String((byte[]) buffers.elementAt(i), "UTF-8");
            }
            return toReturn;
        }
        /**
         * Concatenates all markers of the list to produce a big byte array.
         * 
         * @return byte array containing all the markers
         * @throws IOException
         *             Never happened
         */
        public byte[] getBytes() throws IOException {
            ByteArrayOutputStream mybaos = new ByteArrayOutputStream();
            for (Iterator it = buffers.iterator(); it.hasNext();) {
                byte[] buff = (byte[]) it.next();
                mybaos.write(buff);
            }
            mybaos.close();
            return mybaos.toByteArray();
        }
    }
    public class JpegException extends Exception {

        public JpegException(String msg) {
            super(msg);
        }
    }
}