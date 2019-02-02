(* row * column *)
type pos =
  { r : int
  ; c : int }

let pos r c = {r; c}

(* top left * bottom right *)
type content =
  | Occ of (pos * pos) * value
  | Val of value

and value =
  | Empty
  | Undefined
  | Int of int

type cell = {value : value}
type action = Set of pos * content

let create_cell v = {value = v}
let value {value} = value

let string_of_value = function
  | Int i -> string_of_int i
  | Undefined -> "P"
  | Empty -> " "

let string_of_pos {r; c} = "(" ^ string_of_int r ^ "," ^ string_of_int c ^ ")"

let string_of_content content =
  match content with
  | Val v -> string_of_value v
  | Occ ((p1, p2), v) ->
    "Occ ("
    ^ string_of_pos p1
    ^ ", "
    ^ string_of_pos p2
    ^ "), "
    ^ string_of_value v

let compare_pos {r = r1; c = c1} {r = r2; c = c2} =
  let res = compare r1 r2 in
  if res = 0 then compare c1 c2 else res

module Mpos = Map.Make (struct
  type t = pos

  let compare = compare_pos
end)

module Spos = Set.Make (struct
  type t = pos

  let compare = compare_pos
end)
