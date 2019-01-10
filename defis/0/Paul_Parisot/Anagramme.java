import java.util.*;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;

public class Anagramme{

    public static void main(String[] args){

	File file = new File(args[0]);
		try{
		    BufferedReader br = null;
		    String line;
		    
			for(int i = 1; i<args.length;i++){
				System.out.println(args[i]+" :");
				br = new BufferedReader(new FileReader(file));
				while ((line = br.readLine()) != null) {
			   		if(anagramme(args[i], line)){
			   			System.out.println(line);
			   		} 
			   	}
			}
		    
		    br.close();
		}
		catch(Exception e){
		     e.printStackTrace();
		}
    }

    public static boolean anagramme(String s1, String s2){
		if(s1.length() != s2.length()){
		    return false;
		}
		if(s1.equals(s2)){
		    return false;
		}        

		char[] charArray1 = s1.toCharArray();
		char[] charArray2 = s2.toCharArray();
		Arrays.sort(charArray1);
	    Arrays.sort(charArray2);
	    if(Arrays.equals(charArray1,charArray2)){
	    	return true;
	    }
	    return false;
    }
}
