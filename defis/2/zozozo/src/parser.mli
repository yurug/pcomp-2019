(* Parsing function
*)

open Ast

val try_int_of_string : string -> string -> int

val parse_value : string -> string -> value

val parse_formula : string -> string -> is_formula content

val is_formula_string : string -> bool


(** [parse_formulas_in file l0 lf] parses the region of the file
   [file] between line [l0] and [l0+lf] and outputs a pair composed
   of
    - the maximum cells in a line of the region
    - the list of formulas with their positions in this region.  *)
val parse_formulas_in : in_channel -> int -> int -> int * (pos * is_formula content) list

val parse_and_write_value_in_region : in_channel -> Regiondata.t -> int -> int -> unit

val parse_change : string -> string -> bool * pos * string

val parse_changes : string ->(pos*value) list * (pos*is_formula content) list
