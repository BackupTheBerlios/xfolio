
import java.io.File;
import java.io.IOException;
import java.util.Enumeration;
import java.util.regex.PatternSyntaxException;

import org.apache.tools.ant.Project;
import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.DirectoryScanner;
import org.apache.tools.ant.types.FileSet;
import org.apache.tools.ant.types.FilterSet;
import org.apache.tools.ant.types.FilterSetCollection;
import org.apache.tools.ant.taskdefs.Move;




public class AntMoveNormalize extends Move {


    /**
     * Override copy's doFileOperations to move the
     * files instead of copying them.
     */
    public void doFileOperations() {
        //Attempt complete directory renames, if any, first.
        if (completeDirMap.size() > 0) {
            Enumeration e = completeDirMap.keys();
            while (e.hasMoreElements()) {
                File fromDir = (File) e.nextElement();
                File toDir = (File) completeDirMap.get(fromDir);
                boolean renamed = false;
                try {
                    log("Attempting to rename dir: " + fromDir
                        + " to " + toDir, verbosity);
                    renamed =
                        renameFile(fromDir, toDir, filtering, forceOverwrite);
                } catch (IOException ioe) {
                    String msg = "Failed to rename dir " + fromDir
                        + " to " + toDir
                        + " due to " + ioe.getMessage();
                    throw new BuildException(msg, ioe, getLocation());
                }
                if (!renamed) {
                    FileSet fs = new FileSet();
                    fs.setProject(getProject());
                    fs.setDir(fromDir);
                    addFileset(fs);
                    DirectoryScanner ds = fs.getDirectoryScanner(getProject());
                    String[] files = ds.getIncludedFiles();
                    String[] dirs = ds.getIncludedDirectories();
                    scan(fromDir, toDir, files, dirs);
                }
            }
        }
        int moveCount = fileCopyMap.size();
        if (moveCount > 0) {   // files to normalize

        // [FG] change to move

            log("Normalize in " + destDir.getAbsolutePath());

            Enumeration e = fileCopyMap.keys();
            while (e.hasMoreElements()) {
                String fromFile = (String) e.nextElement();

                File f = new File(fromFile);
                boolean selfMove = false;
                if (f.exists()) { //Is this file still available to be moved?
                    String[] toFiles = (String[]) fileCopyMap.get(fromFile);
                    for (int i = 0; i < toFiles.length; i++) {
                        String toFile = (String) toFiles[i];

						// [FG] normalize here

						File tmp=new File(toFile);
						toFile = normalize(tmp).getAbsolutePath();
						if (!toFile.equals(tmp.getAbsolutePath())) {
							log (toFile);
						}

                        if (fromFile.equals(toFile)) {
                            log("Skipping self-move of " + fromFile, verbosity);
                            selfMove = true;

                            // if this is the last time through the loop then
                            // move will not occur, but that's what we want
                            continue;
                        }

						// Windows bug in renaming
						if(fromFile.equalsIgnoreCase(toFile)) {
                            log("An ignoreCase self-move (MS.bug) " + fromFile, verbosity);
							tmp=new File(fromFile+"~");
							f.renameTo(tmp);
							f=tmp;
						}

                        File d = new File(toFile);
                        if ((i + 1) == toFiles.length && !selfMove) {
                            // Only try to move if this is the last mapped file
                            // and one of the mappings isn't to itself
                            moveFile(f, d, filtering, forceOverwrite);
                        } else {
                            copyFile(f, d, filtering, forceOverwrite);
                        }
                    }
                }
            }
        }

        if (includeEmpty) {
            Enumeration e = dirCopyMap.keys();
            int createCount = 0;
            while (e.hasMoreElements()) {
                String fromDirName = (String) e.nextElement();
                String[] toDirNames = (String[]) dirCopyMap.get(fromDirName);
                boolean selfMove = false;
                for (int i = 0; i < toDirNames.length; i++) {


						// [FG] normalize here

						File tmp=new File(toDirNames[i]);
						toDirNames[i] = normalize(tmp).getAbsolutePath();


                    if (fromDirName.equals(toDirNames[i])) {
                        log("Skipping self-move of " + fromDirName, verbosity);
                        selfMove = true;
                        continue;
                    }

                    File d = new File(toDirNames[i]);
                    if (!d.exists()) {
                        if (!d.mkdirs()) {
                            log("Unable to create directory "
                                + d.getAbsolutePath(), Project.MSG_ERR);
                        } else {
                            createCount++;
                        }
                    }
                }

                File fromDir = new File(fromDirName);
                if (!selfMove && okToDelete(fromDir)) {
                    deleteDir(fromDir);
                }

            }

            if (createCount > 0) {
                log("Moved " + dirCopyMap.size()
                    + " empty director"
                    + (dirCopyMap.size() == 1 ? "y" : "ies")
                    + " to " + createCount
                    + " empty director"
                    + (createCount == 1 ? "y" : "ies") + " under "
                    + destDir.getAbsolutePath());
            }
        }
    }






	public File normalize(File file) {
		File output=file;
		String to;
        try {
			to=file.getCanonicalPath();
        	if ( file.isFile() && file.getName().lastIndexOf('.') > 1) {
        		to=to.substring(0, to.lastIndexOf('.'))+to.substring(to.lastIndexOf('.')).toLowerCase() ;
			}
        	to = new String(to.getBytes("ISO-8859-1"));
        	// arabic ?
			// greek ?
			// ANSI letters
            // replace some letters in non desired encodings to avoid some desagrements
			to=to.replaceAll("[*?\"<>|]", "");
			output= new File(to);
        } catch (PatternSyntaxException e) {
			// for debug only
            throw new BuildException(e);
		} catch (IOException e) {
            throw new BuildException(e);
		} catch (Exception e) {
            // jvm < 1.4, problem ?
        }
		return output;
	}


/*
copy/paste of original protected methods
*/

    /**
     * Try to move the file via a rename, but if this fails or filtering
     * is enabled, copy the file then delete the sourceFile.
     */
    private void moveFile(File fromFile, File toFile,
                          boolean filtering, boolean overwrite) {
        boolean moved = false;
        try {
            log("Attempting to rename: " + fromFile
                + " to " + toFile, verbosity);
            moved = renameFile(fromFile, toFile, filtering, forceOverwrite);
        } catch (IOException ioe) {
            String msg = "Failed to rename " + fromFile
                + " to " + toFile
                + " due to " + ioe.getMessage();
            throw new BuildException(msg, ioe, getLocation());
        }

        if (!moved) {
            copyFile(fromFile, toFile, filtering, overwrite);
            if (!fromFile.delete()) {
                throw new BuildException("Unable to delete "
                                        + "file "
                                        + fromFile.getAbsolutePath());
            }
        }
    }

    /**
     * Copy fromFile to toFile.
     * @param fromFile
     * @param toFile
     * @param filtering
     * @param overwrite
     */
    private void copyFile(File fromFile, File toFile,
                          boolean filtering, boolean overwrite) {
        try {
            log("Copying " + fromFile + " to " + toFile,
                verbosity);

            FilterSetCollection executionFilters =
                new FilterSetCollection();
            if (filtering) {
                executionFilters
                    .addFilterSet(getProject().getGlobalFilterSet());
            }
            for (Enumeration filterEnum =
                    getFilterSets().elements();
                filterEnum.hasMoreElements();) {
                executionFilters
                    .addFilterSet((FilterSet) filterEnum
                                .nextElement());
            }

            getFileUtils().copyFile(fromFile, toFile, executionFilters,
                                    getFilterChains(),
                                    forceOverwrite,
                                    getPreserveLastModified(),
                                    getEncoding(),
                                    getOutputEncoding(),
                                    getProject());

        } catch (IOException ioe) {
            String msg = "Failed to copy " + fromFile
                + " to " + toFile
                + " due to " + ioe.getMessage();
            throw new BuildException(msg, ioe, getLocation());
        }
    }




}