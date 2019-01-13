module CM : Occurences.S with type t = char

val string_to_charlist : string -> char list

val charlist_to_string : char list -> string

val is_anagram : int CM.M.t -> char list -> bool

val all_anagrams : char list list -> string -> string list

val print_anagrams : (string * string list) list -> unit
