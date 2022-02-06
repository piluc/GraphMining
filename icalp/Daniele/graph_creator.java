import java.io.*;
import java.util.*;

public class graph_creator{
    public static void main(String [] args) {

    String fileName = "icalp.txt";

    String line = null;

    Map<String, Integer> map = new HashMap<String, Integer>();
    
    try {
        FileReader fileReader = new FileReader(fileName);
        BufferedReader bufferedReader = new BufferedReader(fileReader);
        while((line = bufferedReader.readLine()) != null) {
            if (map.keySet().contains(line)){
                map.put(line, map.get(line) + 1);
            }else{
                map.put(line,1);
            }

        }  
        bufferedReader.close();         
    } catch(FileNotFoundException ex) {
        System.out.println("Unable to open file '" + fileName + "'");                
    }
    catch(IOException ex) {
        System.out.println("Error reading file '"  + fileName + "'");                  
    }

    int[] arr= {1972,1974,1976,1977,1978,1979,1980,1981,1982,1983,1984,1985,1986,1987,1988,1989,1990,1991,1992,1993,1994,1995,
        1996,1997,1998,1999,2000,2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021};
    for (int i=0; i< arr.length; i++){
        Map<String, Integer> temp_map = new HashMap<String, Integer>();
        Integer num_line=0;
        try {
            PrintWriter out1 = new PrintWriter("./graphs/icalp/icalp"+ String.valueOf(arr[i]) +".lg");
            PrintWriter out2 = new PrintWriter("./graphs/icalpw/icalpw"+ String.valueOf(arr[i]) +".lg");
            for (Map.Entry<String, Integer> entry : map.entrySet()) {
                String key = entry.getKey();
                String[] line_temp= key.split(" ");
                String new_key =line_temp[0]+" "+line_temp[1];
                Integer value = entry.getValue();
                if (Integer.parseInt(line_temp[2])<= arr[i]){
                    if (temp_map.keySet().contains(new_key)){
                        temp_map.put(new_key, temp_map.get(new_key) + value);
                    }else{
                        temp_map.put(new_key,value);
                        num_line++;
                    }
                }
            }
            out1.println(String.valueOf(num_line)+",8845,u,graph");
            out2.println(String.valueOf(num_line)+",8845,u,graph");
            for (Map.Entry<String, Integer> entry : temp_map.entrySet()) {
                String key = entry.getKey();
                String[] line_temp= key.split(" ");
                Integer value = entry.getValue();
                out1.println(line_temp[0]+","+line_temp[1]);
                out2.println(line_temp[0]+","+line_temp[1]+","+value);
            }
            out1.close();
            out2.close();     
        }
        catch(IOException ex) {
            System.out.println("Error reading file '"  + fileName + "'");                  
        }
    }
   
}
}