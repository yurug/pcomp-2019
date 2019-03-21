open Ast
open Partitioner

val preprocessing : string -> int -> int -> (pos * is_formula content) list * regions * Graph.t

(** [first_evaluation filename dr f g] *)
val first_evaluation : regions -> (pos * is_formula content) list -> Graph.t -> unit

val eval_changes : regions -> string -> string -> Graph.t -> Graph.t
