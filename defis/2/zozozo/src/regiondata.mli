open Ast

type t

(** [init id rows cols] creates a new region of with an [id], of size
   [rows]×[cols] cells.  *)
val init : string -> int -> int -> t

(** [free t] frees the memory and removes the file allocated. *)
val free : t -> unit

(** [get t pos] returns the cell contained in [t] at position
   [pos]. An out-of-bounds access returns a cell crashes the
   program. *)
val get : t -> pos -> cell

(** [set t pos v] sets the value [v] to the cell at position [pos] in
   [t]. An out-of-bounds access crashes the program. Positions are
   relative to [t]. *)
val set : t -> pos -> cell -> unit

(** [fold_rect f a (tl, br) t] folds [f] with initial value [a] from
   top-left [tl] position to bottom-right [br] position in [t]. *)
val fold_rect : ('a -> cell -> 'a) -> 'a -> pos * pos -> t -> 'a

val output_row : t -> int -> out_channel -> unit
val output : t -> out_channel -> unit
