import java.lang.Math;

import java.io.File;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.FileOutputStream;
import java.io.FileInputStream;
import java.io.InputStream;
import java.io.StringReader;

import java.io.FileNotFoundException;
import java.io.IOException;

import java.util.Iterator;
import java.util.Map;
import java.util.Vector;
import java.util.Arrays;


import org.apache.tools.ant.Project;
import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.taskdefs.MatchingTask;




/**
Very simple task to extract XMP from a jpeg file


Do a fileset ?

 */
public class AntJpegInfo extends MatchingTask {

	/*
	Ant specific
	*/
    private File srcFile;
    public void setSrcFile (File srcFile) {
        this.srcFile = srcFile;
    }

    private File destFile;
    public void setDestFile (File destFile) {
        this.destFile = destFile;
    }

    private long granularity = 1000;

    /**
     * Overwrite any existing destination file(s).
     * @param overwrite if true force overwriting of destination file(s)
     *                  even if the destination file(s) are younger than
     *                  the corresponding source file. Default is false.
     */
    protected boolean forceOverwrite = false;
    public void setOverwrite(boolean overwrite) {
        this.forceOverwrite = overwrite;
    }


    public void execute() throws BuildException {
        // log("AntXMPjpeg");
		String xmp;
		try {
			if (srcFile == null) throw new BuildException ("\n[" + this.getTaskName() + "] no @srcFile in task to extract xmp from.");
			in = new FileInputStream(srcFile);
			// if no destFile provided, create a brother
			if (destFile == null) destFile=new File (srcFile.getParent(), getBasename(srcFile) + ".xjpeg");
			if ( !forceOverwrite && destFile.exists()
	             && (srcFile.lastModified() - granularity < destFile.lastModified())) {
				log(srcFile + " omitted as " + destFile + " is up to date.", Project.MSG_VERBOSE);
               	return;
            }

			// it works but badly, should be SAX
			xmp="<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
			xmp+="<jpeginfo ";
			xmp+= "\n    file=\"" + srcFile +"\" ";
			/* works but not relevant
			File file;
			file=getPrevImage(srcFile);
			if (file != null) xmp+= "\n    prev=\"" + file +"\" ";
			file=getNextImage(srcFile);
			if (file != null) xmp+= "\n    next=\"" + file +"\" ";
			*/
			xmp+= ">\n";

			try {
				scanHeaders();
				xmp+="<info ";
				xmp+= "width=\"" + width +"\" ";
				xmp+= "height=\"" + height +"\" ";
				xmp+= "compression=\"" + compression +"\" ";
				xmp+= "colors=\"" + (int)Math.pow(2, bitsPerPixel) +"\" ";
				xmp+= "/>\n";
				xmp+= this.getXMP();
			}
			// FG 2004-10-09
			// TODO, better Exception handling in case of guilty image
			catch (JpegException e) {
				// careful, no XMP is highly possible in a jpeg
				// don't send too much to the log
				log("No XMP in "+srcFile);
				log(e.getLocalizedMessage());
			}

			xmp+="\n</jpeginfo>";

			FileOutputStream out=new FileOutputStream(destFile);
			out.write(xmp.getBytes());
			log ("  --  xmp extracted from jpeg\n" + srcFile + "\n"+ destFile );
		}
		catch (FileNotFoundException e) {
			throw new BuildException("FileNotFoundException:" +e);
		}
		catch (IOException e) {
			throw new BuildException("IOException:" +e);
		}
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

    /**
       Give basename of a file (without extension)
     */
    public static String getBasename(File file) {
        String name=file.getName();
        if (name.lastIndexOf('.') < 1) return name;
        return name.substring(0, name.lastIndexOf('.'));
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

	public class FileComparator implements java.util.Comparator {
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
            else compare=radical1.compareToIgnoreCase(radical2);
            // if not enough, separe on lang
            if (compare==0) {
                if (lang1.equals(lang) && !lang2.equals(lang)) compare=-1;
                else if (!lang1.equals(lang) && lang2.equals(lang)) compare=1;
                else if (lang1.equals(lang) && lang2.equals(lang)) compare=0;
                // TODO an ordering table of language should be prefered
                else compare=lang1.compareToIgnoreCase(lang2);
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

    public class FileFilterImage implements java.io.FileFilter {
		public boolean accept(File file) {
			if (file.isDirectory()) return true;
			// readable ?
			String extension=getExtension(file);
			if ("jpg".equals(extension)
			 || "jpeg".equals(extension)
			 || "JPG".equals(extension)
			 || "png".equals(extension)
			 || "gif".equals(extension)
			) return true;
			else return false;
		}
	}

    /**
     * From a file, get previous, with a go down directories
     * how to stop somewhere ?
     */
    public File getPrevImage(File file) {
		return getPrevImage(file, 0);
	}


    public File getPrevImage(File file, int depth) {
		// for each go up depth is incremented and should have a stop to
		// not parse the world
		if (depth > 3) return null;
		// root of this disk
        if (file.getParentFile() == null) return null;
		File[] contents;
        contents = file.getParentFile().listFiles(new FileFilterImage());
        Arrays.sort(contents, new FileComparator());
		int i=0;
		for (i=0; i < contents.length; i++) {
			if (file.compareTo(contents[i]) == 0) break;
		}

		// given file is not an image or a directory, something better could be done
		if (i >= contents.length ) return null; // return getPrevImage(file.getParentFile(), count++);
		// given file is the first of the directory, continue to search on parent
		if (i == 0) return getPrevImage(file.getParentFile(), depth++);
		// here is the file
		if (contents[i-1].isFile()) return contents[i-1];
		// prev is a directory, get the last
        File directory = contents[i-1];
        int loop=5;
        while (loop > 0) {
			contents=directory.listFiles(new FileFilterImage());
			Arrays.sort(contents, new FileComparator());
			// this dir is empty, pass it to search before, no need to increment depth
			if (contents.length < 1 ) return getPrevImage(directory, depth);
			// last file of this dir could be returned
			if (contents[contents.length - 1].isFile()) return contents[contents.length - 1];
			// last file of this dir is a dir, go down
			directory=contents[contents.length - 1];
			loop--;
		}
		return null;
    }

    public File getNextImage(File file) {
		return getNextImage(file, 0);
	}

    public File getNextImage(File file, int depth) {
		// for each go up depth is incremented and should have a stop to
		// not parse the world
		if (depth > 3) return null;
		// root of this disk
        if (file.getParentFile() == null) return null;
		File[] contents;
        contents = file.getParentFile().listFiles(new FileFilterImage());
        Arrays.sort(contents, new FileComparator());
		int i=0;
		for (i=0; i < contents.length; i++) {
			if (file.compareTo(contents[i]) == 0) break;
		}

		// given file is not an image or a directory, something better could be done
		if (i >= contents.length ) return null; // return getPrevImage(file.getParentFile(), count++);
		// given file is the first of the directory, continue to search on parent
		if (i == contents.length - 1) return getNextImage(file.getParentFile(), depth++);
		// here is the file
		if (contents[i+1].isFile()) return contents[i+1];
		// prev is a directory, get the last
        File directory = contents[i+1];
        int loop=5;
        while (loop > 0) {
			contents=directory.listFiles(new FileFilterImage());
			Arrays.sort(contents, new FileComparator());
			// this dir is empty, pass it to search before, no need to increment depth
			if (contents.length < 1 ) return getNextImage(directory, depth);
			// first file of this dir could be returned
			if (contents[0].isFile()) return contents[0];
			// first file of this dir is a dir, go down
			directory=contents[0];
			loop--;
		}
		return null;
    }

	/*


	XMPjpeg code


	*/

    protected InputStream    in;
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

