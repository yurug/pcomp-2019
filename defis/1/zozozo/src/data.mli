(** This module abstracts the representation of the spreadsheet.  *)
open Ast

(** Signature spreadsheet representations must implement.  *)
module type DATA = sig
  (** Abstract data type.  *)
  type t

  (** [init data_filename] initialize [t] and return the list of [formulas]. *)
  val init : string -> t * (pos * content) list

  (** [get pos t] returns the cell contained in [t] at position
     [pos]. An out-of-bounds access returns a cell with value
     Undefined. *)
  val get : pos -> t -> cell

  (** [set pos v t] sets the value [v] to the cell at position [pos]
     in [t]. An out-of-bounds access creates a cell, and might expand
     the underlying representation. *)
  val set : pos -> cell -> t -> t

  (** [set_rect (tl, br) v t] sets the value [v] to the region from
     the top-left cell position [tl] to the bottom-right cell position
     [br] in [t], both boundaries included. *)
  val set_rect : pos * pos -> cell -> t -> t

  val map_rect : (cell -> cell) -> pos * pos -> t -> t
  val map_recti : (pos -> cell -> cell) -> pos * pos -> t -> t
  val fold_rect : ('a -> cell -> 'a) -> 'a -> pos * pos -> t -> 'a
  val fold_recti : ('a -> pos -> cell -> 'a) -> 'a -> pos * pos -> t -> 'a
  val output_init : t -> string -> unit
end

module DataArray : DATA
