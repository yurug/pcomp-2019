open Ast

(** [build_neighbours_map formulas l0 lf] *)
val build_neighbours_map : (pos * is_formula content) list -> int -> int -> Graph.neighbours

(** [apply_change filename dr region pos v] *)
val apply_change : string -> int -> pos -> value -> unit

(** [partial_eval computable filename] *)
val partial_eval : (pos * is_formula content) list -> string -> int -> int -> (pos * fkind * int) list
