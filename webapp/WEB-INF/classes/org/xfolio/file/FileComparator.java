package org.xfolio.file;
import java.io.File;
import java.util.Comparator;

    public class FileComparator implements Comparator {
        public int compare(Object o1, Object o2) {
            // TODO, be more efficient here
            // String lang=(String)ObjectModelHelper.getContext(objectModel).getAttribute("xfolio.lang");
            // some hard coded nationalism
            String lang="fr";
            // default, equal
            int compare=0;
            String radical1=FileUtils.getRadical((File)o1);
            String radical2=FileUtils.getRadical((File)o2);
            String lang1=FileUtils.getLang((File)o1);
            String lang2=FileUtils.getLang((File)o2);
            String extension1=FileUtils.getExtension((File)o1);
            String extension2=FileUtils.getExtension((File)o2);
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

