
/**
 * This class creates the temporal graph of ICALP publications. Two files are
 * generated. One file icalp_ids.txt contains the list of authors with their
 * ids in the graph. The other file contains the list of temporal edges.
 */

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.*;

import org.dblp.mmdb.Person;
import org.dblp.mmdb.PersonName;
import org.dblp.mmdb.Publication;
import org.dblp.mmdb.RecordDb;
import org.dblp.mmdb.RecordDbInterface;
import org.dblp.mmdb.TableOfContents;
import org.xml.sax.SAXException;

class ICALPedgesAuthor {
    static Comparator<Person> cmp = (Person o1,
            Person o2) -> o1.getPrimaryName().name().compareTo(o2.getPrimaryName().name());

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

    public static int analyse_toc(int year, Map<String, Integer> author_id, int current_id,
            Map<Person, Integer> authors, TableOfContents toc,
            BufferedWriter tg_bw) {
        for (Publication publ : toc.getPublications()) {
            for (PersonName name : publ.getNames()) {
                Person pers = name.getPerson();
                if (!authors.containsKey(pers)) {
                    authors.put(pers, 1);
                }
            }
        }
        return update_tg(year, author_id, current_id, toc, tg_bw);
    }

    public static int analyse_toc(int year, Map<String, Integer> author_id, int current_id, TableOfContents toc,
            BufferedWriter tg_bw) {
        Map<Person, Integer> authors = new TreeMap<>(cmp);
        for (Publication publ : toc.getPublications()) {
            for (PersonName name : publ.getNames()) {
                Person pers = name.getPerson();
                if (!authors.containsKey(pers)) {
                    authors.put(pers, 1);
                }
            }
        }
        System.out.format("%d\t %d \t %d\n", year, toc.getPublications().size(), authors.size());
        return update_tg(year, author_id, current_id, toc, tg_bw);
    }

    public static int update_tg(int year, Map<String, Integer> author_id, int current_id, TableOfContents toc,
            BufferedWriter tg_bw) {
        try {
            for (Publication publ : toc.getPublications()) {
                String[] author_name = new String[publ.getNames().size()];
                int current_author = 0;
                for (PersonName name : publ.getNames()) {
                    author_name[current_author] = name.getPrimaryName().name();
                    current_author = current_author + 1;
                    Person pers = name.getPerson();
                    if (!author_id.containsKey(pers.getPrimaryName().name())) {
                        author_id.put(pers.getPrimaryName().name(), current_id);
                        current_id = current_id + 1;
                    }
                }
                for (int a1 = 0; a1 < author_name.length; a1++) {
                    for (int a2 = a1 + 1; a2 < author_name.length; a2++) {
                        int id1 = author_id.get(author_name[a1]);
                        int id2 = author_id.get(author_name[a2]);
                        if (id1 < id2) {
                            tg_bw.write(id1 + " " + id2 + " " + year
                                    + "\n");
                        } else {
                            tg_bw.write(id2 + " " + id1 + " " + year
                                    + "\n");
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            System.out.println(-1);
        }
        return current_id;
    }

    public static void main(String[] args) {
        System.setProperty("entityExpansionLimit", "10000000");
        RecordDbInterface dblp = read_xml_file();
        //Map<String, Integer> author_id = new TreeMap<>();
        try {
            
            Integer[] arr_years={1972,1974,1976,1977,1978,1979,1980,1981,1982,1983,1984,1985,1986,1987,1988,1989,1990,1991,1992,1993,1994,1995,
                1996,1997,1998,1999,2000,2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021};
            //Comparator<Person> cmp = (Person o1,
            //        Person o2) -> o1.getPrimaryName().name().compareTo(o2.getPrimaryName().name());
            //Comparator<Publication> cmp_pub = (Publication p1,
            //    Publication p2) -> p1.getKey().compareTo(p2.getKey());

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

            PrintWriter out = new PrintWriter("./icalpEdges.txt");
            for (Integer year : arr_years){
                
                PrintWriter out1 = new PrintWriter("./graphs/icalp/icalpEdges"+ year +".txt");
                PrintWriter out2 = new PrintWriter("./graphs/icalpw/icalpwEdges"+ year +".txt");
                Set<Person> authors = new HashSet<Person>();
                
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
                //System.out.format("authors collected : %d\n",authors.size());
                List<Person> authors_list = new ArrayList<Person>();
                authors_list.addAll(authors);
                for (int i = 0; i < authors_list .size(); i++){
                    for (int j = i + 1; j < authors_list .size(); j++){
                        Integer num_collab =0;
                        Person p1= authors_list.get(i);
                        Person p2= authors_list.get(j);
                        //System.out.format("%s %s\n",p1.getPrimaryName().name(),p2.getPrimaryName().name());
                        List<Publication> p1_pub=p1.getPublications();
                        List<Publication> p2_pub=p2.getPublications();
                        
                        for (int ii=0;ii<p1_pub.size();ii++){
                            for(int jj=0;jj<p2_pub.size();jj++){
                                if (p1_pub.get(ii).getKey()==p2_pub.get(jj).getKey() && p1_pub.get(ii).getYear()==year){
                                    num_collab++;
                                }
                            }
                        }
                        if (num_collab>0){
                            if (map_authors.get(p1.getPrimaryName().name()) < map_authors.get(p2.getPrimaryName().name())){
                                out1.format("%d,%d\n",map_authors.get(p1.getPrimaryName().name()),map_authors.get(p2.getPrimaryName().name()));
                                out2.format("%d,%d,%d\n",map_authors.get(p1.getPrimaryName().name()),map_authors.get(p2.getPrimaryName().name()),num_collab);
                                out.format("%d,%d,%d,%d\n",map_authors.get(p1.getPrimaryName().name()),map_authors.get(p2.getPrimaryName().name()),num_collab,year);
                            }else{
                                out.format("%d,%d,%d,%d\n",map_authors.get(p2.getPrimaryName().name()),map_authors.get(p1.getPrimaryName().name()),num_collab,year);
                                out1.format("%d,%d\n",map_authors.get(p2.getPrimaryName().name()),map_authors.get(p1.getPrimaryName().name()));
                                out2.format("%d,%d,%d\n",map_authors.get(p2.getPrimaryName().name()),map_authors.get(p1.getPrimaryName().name()),num_collab);
                            }
                        }
                    }
                }
                
                out1.close();
                out2.close();
                //System.out.format("end of year\n");
            }
            out.close();
        } catch (Exception e) {
            e.printStackTrace();
            System.exit(-1);
        }
        System.out.println("Done.");
    }
}