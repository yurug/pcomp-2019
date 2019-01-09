package main

// Being overly pedantic, iterate on words using UTF-8 codepoints.  I
// could also normalize the input, and convert to lower, but I think
// it’s unnecessary.

// I don’t assume that the dictionary is sorted (which it should,
// otherwise it shouldn’t be called a dictionary), so I need to sort
// things out.

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"sort"
)

func build_freqs(s string) (m map[rune]int) {
	m = make(map[rune]int)
	for _, r := range s {
		m[r] += 1
	}
	return
}

func freqs_eq(f1 map[rune]int, f2 map[rune]int) bool {
	for k, v := range f1 {
		if f2[k] != v {
			return false
		}
	}
	return true
}

func is_anagram(freqs map[rune]int, s string) bool {
	m := build_freqs(s)
	return freqs_eq(freqs, m) && freqs_eq(m, freqs)
}

func main() {
	if len(os.Args) < 3 {
		log.Fatal("Usage: anagram <mydict> word [words...]")
	}

	file, err := os.Open(os.Args[1])
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()

	nwords := len(os.Args) - 2
	freqs := make([](map[rune]int), nwords)
	anagrams := make([]([]string), nwords)
	for i := 0; i < nwords; i++ {
		anagrams[i] = make([]string, 0)
		freqs[i] = build_freqs(os.Args[i+2])
	}

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		for i, freq := range freqs {
			word := scanner.Text()
			if is_anagram(freq, word) {
				anagrams[i] = append(anagrams[i], word)
			}
		}
	}
	if err := scanner.Err(); err != nil {
		log.Fatal(err)
	}

	for i, words := range anagrams {
		fmt.Print(os.Args[i+2], ":\n")
		sort.Strings(words)
		for _, word := range words {
			fmt.Println(word)
		}
	}
}
