open Ast

module type DATA = sig
  type t

  val create : int -> int -> t
  val get : pos -> t -> cell
  val set : pos -> cell -> t -> t
  (*
val set_rect : (pos * pos) -> value -> t -> t
val map_rect : (value -> value) -> (pos * pos) -> t -> t
val map_recti : (pos -> value -> value) -> (pos * pos) -> t -> t
*)
end

module Data_arr : DATA
