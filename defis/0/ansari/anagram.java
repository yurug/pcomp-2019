import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

public class anagram {
    public static void main(String[] args) {

        Map<String, String> words = new HashMap<>();
        Map<String, Set<String>> wordsAnagrams = new HashMap<>();
        BufferedReader reader;

        for (int i = 1; i < args.length; i++) {
            String sortedWord = sortedString(args[i]);
            words.put(args[i], sortedWord);
            wordsAnagrams.putIfAbsent(sortedWord, new HashSet<>());
        }

        if (words.size() == 0) {
            return;
        }

        try {
            reader = new BufferedReader(new FileReader(args[0]));
            String line;

            while ((line = reader.readLine()) != null) {
                String sortedLine = sortedString(line);
                if (wordsAnagrams.containsKey(sortedLine)) {
                    wordsAnagrams.get(sortedLine).add(line);
                }
            }

            reader.close();

            for (int i = 1; i < args.length; i++) {
                System.out.println(args[i] + ":");
                String key = words.get(args[i]);
                ArrayList<String> values = new ArrayList<>(wordsAnagrams.get(key));
                Collections.sort(values);
                for (String value : values) {
                    System.out.println(value);
                }
            }
        } catch (FileNotFoundException e) {
            System.out.println("Fichier introuvable");
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private static String sortedString(String value) {
        char[] valueCharArray = value.toCharArray();
        Arrays.sort(valueCharArray);
        return new String(valueCharArray);
    }
}