type pos =
  { r : int
  ; c : int }

type content =
  | Occ of (pos * pos) * value
  | Val of value

and value =
  | Undefined
  | Int of int

type cell = {value : value}
type action = Set of pos * content

module Mpos : Map.S with type key = pos
module Spos : Set.S with type elt = pos

(** [value cell] return the field value of type value from [cell]. *)
val value : cell -> value

(** [pos i j] returns {r=i;c=j}. *)
val pos : int -> int -> pos

(** [compare_pos p1 p2] returns an int positive if p1>p2, negative if
   p1<p2, null if p1 = p2 (in lexigographical order) *)
val compare_pos : pos -> pos -> int

(* Debug function *)
val string_of_value : value -> string
val string_of_pos : pos -> string
val string_of_content : content -> string
