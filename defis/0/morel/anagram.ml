module CM = Occurences.Make ( struct
    type t = char
    let compare = Pervasives.compare
  end
  )

let string_to_charlist s = List.init (String.length s) (String.get s)

let charlist_to_string l = String.concat "" (List.map Char.escaped l)

let rec is_anagram word_map word_dict =
  match word_dict with
  | [] -> true && (word_map = CM.empty)
  | first :: rest   ->
      try
        let new_map = CM.decr word_map first in
        is_anagram new_map rest
      with
        Not_found -> false

let all_anagrams dict word_ref =
  let lword = string_to_charlist word_ref in
  let size = List.length lword in
  let word_map = CM.convert lword in

  let rec build_anagrams dict res =
    match dict with
    | [] -> res
    | word :: rs
      when List.length word = size &&
           is_anagram word_map word ->
      let word =  charlist_to_string word in
      build_anagrams rs (word::res)
    | _ :: rs -> build_anagrams rs res

  in
  build_anagrams dict []

let print_anagrams =
  List.iter
    (fun (word, ana) -> Format.printf "%s@." word ; List.iter (Format.printf "%s@.") ana)
