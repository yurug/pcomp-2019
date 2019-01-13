open Anagram

let read file =
  let rec aux l =
    match input_line file with
    | h -> aux ((string_to_charlist h)::l)
    | exception  End_of_file -> close_in file ; l in
  aux []

let main () =
  match Sys.argv with
  | args when Array.length args >=3 ->
    let dict = read (open_in args.(1)) in
    let words = List.rev (Array.to_list (Array.sub args 2 (Array.length args - 2))) in
    let anagrams = List.fold_left (fun all_ana word -> (word^":", all_anagrams dict word) :: all_ana) [] words in
    print_anagrams anagrams

  | exception Invalid_argument (_)  -> prerr_endline "Bad input, argments should be \"dict_filename word1 word2 ...\""

  | _ ->  prerr_endline "Bad input, argments should be \"dict_filename word1 word2 ...\""

;;

main ()
