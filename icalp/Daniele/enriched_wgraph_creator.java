import java.io.*;
import java.util.HashMap;
import java.util.Map;

public class enriched_wgraph_creator{
    public static void main(String [] args) {
        String line = null;
        int[] arr= {1972,1974,1976,1977,1978,1979,1980,1981,1982,1983,1984,1985,1986,1987,1988,1989,1990,1991,1992,1993,1994,1995,
            1996,1997,1998,1999,2000,2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021};

        
        for (int i=0; i< arr.length; i++){

            Map<String, Integer> temp_map = new HashMap<String, Integer>();
            try {

                PrintWriter newGraphWeighted = new PrintWriter("./graphs/icalpw/icalpwEnriched"+ String.valueOf(arr[i]) +".lg");
                PrintWriter newGraph = new PrintWriter("./graphs/icalp/icalpEnriched"+ String.valueOf(arr[i]) +".lg");
                FileReader fr2= new FileReader("./graphs/icalpw/icalpwEdges"+ String.valueOf(arr[i]) +".txt");
                BufferedReader f2 = new BufferedReader(fr2);
                Integer sizef2=0;
                
                if (i==0){
                    while((line = f2.readLine()) != null) {
                        String[] arr_line=line.split(",");
                        String key= arr_line[0]+","+arr_line[1];
    
                        if (temp_map.keySet().contains(key)){
                            temp_map.put(key, temp_map.get(key) + Integer.parseInt(arr_line[2]));
                        }else{
                            temp_map.put(key,Integer.parseInt(arr_line[2]));
                            sizef2++;
                        }
                    }
                    f2.close();
                    newGraphWeighted.println(String.valueOf(sizef2)+",8845,u,graph");
                    newGraph.println(String.valueOf(sizef2)+",8845,u,graph");
                    for (Map.Entry<String, Integer> entry : temp_map.entrySet()) {
                        String key = entry.getKey();
                        Integer value = entry.getValue();
                        newGraphWeighted.println(key+","+String.valueOf(value));
                        newGraph.println(key);
                    }
                    newGraphWeighted.close();
                    newGraph.close();
                    continue;
                }
                FileReader fr1= new FileReader("./graphs/icalpw/icalpw"+ String.valueOf(arr[i-1]) +".lg");
                BufferedReader f1 = new BufferedReader(fr1); 
                Integer sizef1 =Integer.parseInt(f1.readLine().split(",")[0]);
                while((line = f1.readLine()) != null) {
                    String[] arr_line=line.split(",");
                    temp_map.put(arr_line[0]+","+arr_line[1], Integer.parseInt(arr_line[2]));
                } 
                f1.close();
                while((line = f2.readLine()) != null) {
                    String[] arr_line=line.split(",");
                    String key= arr_line[0]+","+arr_line[1];

                    if (temp_map.keySet().contains(key)){
                        temp_map.put(key, temp_map.get(key) + Integer.parseInt(arr_line[2]));
                    }else{
                        temp_map.put(key,Integer.parseInt(arr_line[2]));
                        sizef2++;
                    }
                }
                f2.close();
                newGraphWeighted.println(String.valueOf(sizef1+sizef2)+",8845,u,graph");
                newGraph.println(String.valueOf(sizef1+sizef2)+",8845,u,graph");
                for (Map.Entry<String, Integer> entry : temp_map.entrySet()) {
                    String key = entry.getKey();
                    Integer value = entry.getValue();
                    newGraphWeighted.println(key+","+String.valueOf(value));
                    newGraph.println(key);
                }
                newGraphWeighted.close();
                newGraph.close();

            } catch(FileNotFoundException ex) {
                ex.printStackTrace();              
            }
            catch(IOException ex) {
                ex.printStackTrace();                  
            }

        }
    }
}
