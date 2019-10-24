open Ast

let string_of_value = function
  | Int i -> string_of_int i
  | Undefined -> "P"
  | Empty -> " "

let string_of_pos p =
  let r, c = pos p in
  string_of_int r ^ " " ^ string_of_int c

let string_of_content (type a) (content : a content) =
  match content with
  | Val v -> string_of_value v
  | Occ ((p1, p2), v) ->
    "Occ ("
    ^ string_of_pos p1
    ^ ", "
    ^ string_of_pos p2
    ^ "), "
    ^ string_of_value v
    ^ ") "
