type pos =
  { r : int
  ; c : int }

val pos : int -> int -> pos

type content =
  | Occ of (pos * pos) * value
  | Val of value

and value =
  | Undefined
  | Int of int

type cell = {value : value}
type action = Set of pos * content

(* FIXME *)
type spreadsheet = cell list list

(* [value cell] return the field value of type value from [cell]. *)
val value : cell -> value
val string_of_value : value -> string
val string_of_pos : pos -> string
val string_of_content : content -> string
val compare_pos : pos -> pos -> int

module Mpos : Map.S with type key = pos
module Spos : Set.S with type elt = pos
