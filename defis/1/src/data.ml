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

module Data_arr : DATA = struct
  type t =
    { data : cell array array
    ; rows : int
    ; cols : int }

  let create rows cols =
    { data = Array.make_matrix rows cols {value = Undefined; formula = None}
    ; rows
    ; cols }

  let get pos t = t.data.(pos.r).(pos.c)

  let set pos v t =
    t.data.(pos.r).(pos.c) <- v;
    t

  (*
let set_rect (tl, br) v t =
  for r = tl.r to br.r do
    for c = tl.c to br.c do
      t.data.(r).(c) <- v
    done
  done

let map_rect f (tl, br) t =
  for r = tl.r to br.r do
    for c = tl.c to br.c do
      t.data.(r).(c) <- f t.data.(pos.r).(pos.c)
    done
  done

let map_recti f (tl, br) t =
  for r = tl.r to br.r do
    for c = tl.c to br.c do
      t.data.(r).(c) <- f {r; c} t.data.(pos.r).(pos.c)
    done
  done
*)
end
