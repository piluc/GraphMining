
/**
 * This class creates the temporal graph of ICALP publications. Two files are
 * generated. One file icalp_ids.txt contains the list of authors with their
 * ids in the graph. The other file contains the list of temporal edges.
 */

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.*;

import org.dblp.mmdb.Field;
import org.dblp.mmdb.Person;
import org.dblp.mmdb.PersonName;
import org.dblp.mmdb.Publication;
import org.dblp.mmdb.RecordDb;
import org.dblp.mmdb.RecordDbInterface;
import org.dblp.mmdb.TableOfContents;
import org.xml.sax.SAXException;

class ICALPAuthorsWithPapers {
    public static RecordDbInterface read_xml_file() {
        String dblpXmlFilename = "dblp.xml";
        String dblpDtdFilename = "dblp.dtd";
        System.out.println("building the dblp main memory DB ...");
        long start = System.currentTimeMillis();
        RecordDbInterface dblp = null;
        try {
            dblp = new RecordDb(dblpXmlFilename, dblpDtdFilename, false);
        } catch (final IOException ex) {
            System.err.println("cannot read dblp XML: " + ex.getMessage());
            System.exit(-1);
        } catch (final SAXException ex) {
            System.err.println("cannot parse XML: " + ex.getMessage());
            System.exit(-1);
        }
        long end = System.currentTimeMillis();
        System.out.format("MMDB created in %d seconds ", (end - start) / 1000);
        System.out.format("and ready: %d publs, %d pers\n\n", dblp.numberOfPublications(), dblp.numberOfPersons());
        return dblp;
    }


    public static void main(String[] args) {
        System.setProperty("entityExpansionLimit", "10000000");
        RecordDbInterface dblp = read_xml_file();
        try {
            
            Integer[] arr_years={1972,1974,1976,1977,1978,1979,1980,1981,1982,1983,1984,1985,1986,1987,1988,1989,1990,1991,1992,1993,1994,1995,
                1996,1997,1998,1999,2000,2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021};

            //Loading the map between authors and integers
            String line=null;
            Map<String, Integer> map_authors = new HashMap<String, Integer>();
            FileReader fileReader = new FileReader("icalp_id_author.txt");
            BufferedReader bufferedReader = new BufferedReader(fileReader);
            while((line = bufferedReader.readLine()) != null) {
                String yy=line.split(" ")[0];
                map_authors.put(line.substring(yy.length()+1),Integer.parseInt(yy));     
            } 
            bufferedReader.close(); 
            fileReader.close();

            PrintWriter out = new PrintWriter("./icalpAuthorsWithPaperTitles.txt");
            Set<Person> authors = new HashSet<Person>();

            for (Integer year : arr_years){
                
                TableOfContents icalp;
                if (year<2000){
                    icalp = dblp.getToc("db/conf/icalp/icalp" + (year-1900) + ".bht");
                }else{
                    icalp = dblp.getToc("db/conf/icalp/icalp" + year + ".bht");
                    
                }
                if (icalp==null) {
                    icalp = dblp.getToc("db/conf/icalp/icalp" + year + "-1.bht");
                    for (Publication publ : icalp.getPublications()) {
                        for (PersonName name : publ.getNames()) {
                            Person pers = name.getPerson();
                            authors.add(pers);
                        }
                    }
                    icalp = dblp.getToc("db/conf/icalp/icalp" + year + "-2.bht");
                    for (Publication publ : icalp.getPublications()) {
                        for (PersonName name : publ.getNames()) {
                            Person pers = name.getPerson();
                            authors.add(pers);
                        }
                    }

                }else{
                    for (Publication publ : icalp.getPublications()) {
                        for (PersonName name : publ.getNames()) {
                            Person pers = name.getPerson();
                            authors.add(pers);
                        }
                    }
                }
            }
            
            System.out.println("Getting papers");
            for (Person auth : authors){
                out.format("%d\n",map_authors.get(auth.getPrimaryName().name()));
                for (Publication pub : auth.getPublications()){
                    String title="";
                    for (Field f : pub.getFields("title")){
                        title = title.concat(f.value());
                    }
                    long count = title.chars().filter(ch -> ch == ',').count();
                    if (count<=3){
                        out.format("%s ...%d\n",title,pub.getYear());
                    }
                    
                }
                out.format("\n");
            }
            
            out.close();
        } catch (Exception e) {
            e.printStackTrace();
            System.exit(-1);
        }
        System.out.println("Done.");
    }
}
