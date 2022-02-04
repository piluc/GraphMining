
/**
 * This class creates the temporal graph of ICALP publications. Two files are
 * generated. One file icalp_ids.txt contains the list of authors with their
 * ids in the graph. The other file contains the list of temporal edges.
 */

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Comparator;
import java.util.Map;
import java.util.TreeMap;

import org.dblp.mmdb.Person;
import org.dblp.mmdb.PersonName;
import org.dblp.mmdb.Publication;
import org.dblp.mmdb.RecordDb;
import org.dblp.mmdb.RecordDbInterface;
import org.dblp.mmdb.TableOfContents;
import org.xml.sax.SAXException;

class ICALPGraph {
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
        Map<String, Integer> author_id = new TreeMap<>();
        int current_id = 1;
        try {
            BufferedWriter tg_bw = new BufferedWriter(new FileWriter("icalp.tg"));
            System.out.println("finding publications of ICALP ...");
            for (int year = 72; year < 100; year++) {
                TableOfContents toc = dblp.getToc("db/conf/icalp/icalp" + year + ".bht");
                if (toc != null) {
                    current_id = analyse_toc(1900 + year, author_id, current_id, toc, tg_bw);
                }
            }
            for (int year = 2000; year < 2022; year++) {
                TableOfContents toc = dblp.getToc("db/conf/icalp/icalp" + year + ".bht");
                if (toc != null) {
                    current_id = analyse_toc(year, author_id, current_id, toc, tg_bw);
                } else {
                    toc = dblp.getToc("db/conf/icalp/icalp" + year + "-1.bht");
                    if (toc != null) {
                        int t1 = toc.getPublications().size();
                        Map<Person, Integer> authors = new TreeMap<>(cmp);
                        current_id = analyse_toc(year, author_id, current_id, authors, toc, tg_bw);
                        toc = dblp.getToc("db/conf/icalp/icalp" + year + "-2.bht");
                        int t2 = toc.getPublications().size();
                        current_id = analyse_toc(year, author_id, current_id, authors, toc, tg_bw);
                        System.out.format("%d\t %d \t %d\n", year, (t1 + t2), authors.size());
                    }
                }
            }
            tg_bw.close();
            BufferedWriter ai_bw = new BufferedWriter(new FileWriter("icalp_id_author.txt"));
            for (String author_name : author_id.keySet()) {
                ai_bw.write(author_id.get(author_name) + " " + author_name + "\n");
            }
            ai_bw.close();
        } catch (Exception e) {
            e.printStackTrace();
            System.exit(-1);
        }
        System.out.println("Done.");
    }
}
