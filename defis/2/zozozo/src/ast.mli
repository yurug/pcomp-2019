type pos

type is_formula = Is_formula
type not_formula = Not_formula

type 'a content =
  | Occ : (pos * pos) * value -> is_formula content
  | Val : value -> not_formula content

and value =
  | Empty
  | Undefined
  | Int of int

type 'a action = Set of pos * 'a content

module Mint : Map.S with type key = int
module Mpos : Map.S with type key = pos
module Spos : Set.S with type elt = pos


type cell = {value : value}

(** [create_cell v] return a [cell] with the [value]*)
val create_cell : value -> cell

(** [value cell] return the field value of type value from [cell]. *)
val value : cell -> value

(** *)
type formula = { fin : is_formula content ;
                 eval : value }

val build_formula : pos -> pos -> value -> formula

type formulas = formula Mpos.t

type fkind = Occurrence

exception End of ((pos * is_formula content) list)

val empty_formulas : formulas

(** [build_pos i j] returns {r=i;c=j}. *)
val build_pos : int -> int -> pos

val pos : pos -> int * int

val pos_to_region : int -> pos -> int

val pos_in_area : pos -> pos*pos -> bool

val relative_pos : int -> pos -> pos

val regions_within : int -> pos -> pos -> int list

val narrowing : pos -> pos -> int -> int -> (pos * pos) option

(** [compare_pos p1 p2] returns an int positive if p1>p2, negative if
   p1<p2, null if p1 = p2 (in lexigographical order) *)
val compare_pos : pos -> pos -> int

(* Debug function *)
val string_of_value : value -> string
val string_of_pos : pos -> string
val string_of_content : 'a content -> string
