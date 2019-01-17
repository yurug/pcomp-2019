open Ast

type t

val create : int -> int -> t

val get : pos -> t -> value
val set : pos -> value -> t -> t

val set_rect : (pos * pos) -> value -> t -> t
val map_rect : (value -> value) -> (pos * pos) -> t -> t
val map_recti : (pos -> value -> value) -> (pos * pos) -> t -> t
