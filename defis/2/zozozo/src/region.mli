open Ast

(** [parse_formulas_in_region dr file l0] parses the region of the
   file [file] between line [l0] and [l0+region_depth-1] and outputs
   the list of formulas with their positions in this region.  *)
val parse_formulas_in : int -> in_channel -> int -> (pos * is_formula content) list

(** [build_neighbours_map dr formulas rlabel] *)
val build_neighbours_map : int -> (pos * is_formula content) list -> int -> Graph.neighbours

(** [apply_change filename dr region pos v] *)
val apply_change : string -> int -> int -> pos -> value -> unit

(** [partial_eval computable filename] *)
val partial_eval : (pos * is_formula content) list -> string -> int -> int -> (pos * fkind * int) list
