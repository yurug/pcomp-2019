import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.*;

public class Anagram {

    public static void main(String[] args) {

        if (args.length < 2) {
            System.out.println("Nombre d'arguments incorrects");
            System.exit(-1);
        }

        HashMap<String, List<String>> map = new HashMap<>();
        BufferedReader reader = null;
        for (int i = 1; i < args.length; i++) {
            map.put(args[i], new ArrayList<>());
        }
        try {
            reader = new BufferedReader(new FileReader(args[0]));
            String line;
            while ((line = reader.readLine()) != null) {
                for (String word : map.keySet()) {
                    if (sort(word).equals(sort(line)) && !word.equals(line)) {
                        map.get(word).add(line);
                    }
                }
            }
            print(map);
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            try {
                Objects.requireNonNull(reader).close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    public static String sort(String word) {
        char[] wordChars = word.toCharArray();
        Arrays.sort(wordChars);
        return new String(wordChars);
    }

    public static void print(HashMap<String, List<String>> map) {
        for (String word : map.keySet()) {
            System.out.println(word + ":");
            for (String anagram : map.get(word)) {
                System.out.println(anagram);
            }
        }
    }
}
