open Ast

(** [build_neighbours_map formulas l0 lf] *)
val build_neighbours_map : (pos * is_formula content) list -> int -> int -> Graph.neighbours

(** [apply_change data l0 pos v] *)
val apply_change : Regiondata.t -> int -> pos -> value -> unit

(** [partial_eval computable data l0 lf] *)
val partial_eval :
  (pos * is_formula content) list -> Regiondata.t -> int -> int -> (pos * fkind * int) list
