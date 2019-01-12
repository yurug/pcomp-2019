

let rec input_lines file =
  match
    try
      [input_line file]
    with End_of_file -> []
  with
    [] -> []
  | line -> line @ input_lines file

let input_word =
  let len = Array.length (Sys.argv) - 2 in
  Array.to_list
    (Array.sub Sys.argv 2 len)
and dict =
  let dict_file = open_in Sys.argv.(1) in
  input_lines dict_file
  

(*search all anagrammes*)
let is_anagram_of w1 w2 =
  let form_canonique (word:string) =
    String.concat "" (
        List.sort String.compare (
            Str.(split (regexp "") word)
          )
      )
  in
  if (form_canonique w1) = (form_canonique w2)
  then true
  else false    
  
  
open List
let anagrammes_of_words =
  let anagrammes_of_word_in_dict dict word  =    
    filter (is_anagram_of word) dict
  in
  map (anagrammes_of_word_in_dict dict) input_word

(*display anagrammes*)
let _ =        
  let print_anagram_of_word word anagrams =
    print_string (word ^ ":\n");
    (map
      (( fun w -> print_string ( w ^ "\n")))
      anagrams)
  in
  map2 print_anagram_of_word
    input_word anagrammes_of_words
    
    
