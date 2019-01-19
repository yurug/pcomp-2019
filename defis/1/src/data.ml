open Ast

module type DATA = sig
  type t

  val create : int -> int -> t
  val resize : int -> int -> t -> t
  val get : pos -> t -> cell
  val set : pos -> cell -> t -> t
  val set_rect : pos * pos -> cell -> t -> t
  val map_rect : (cell -> cell) -> pos * pos -> t -> t
  val map_recti : (pos -> cell -> cell) -> pos * pos -> t -> t
  val fold_rect : ('a -> cell -> 'a) -> 'a -> pos * pos -> t -> 'a
  val fold_recti : ('a -> pos -> cell -> 'a) -> 'a -> pos * pos -> t -> 'a
end

module DataArray : DATA = struct
  type t =
    { data : cell array array
    ; rows : int
    ; cols : int }

  let create rows cols =
    { data = Array.make_matrix rows cols {value = Undefined; formula = None}
    ; rows
    ; cols }

  let resize rows cols t =
    let obj = create rows cols in
    for r = 0 to min rows t.rows - 1 do
      for c = 0 to min cols t.cols - 1 do
        obj.data.(r).(c) <- t.data.(r).(c)
      done
    done;
    obj

  let get pos t = t.data.(pos.r).(pos.c)

  let set pos v t =
    let t =
      let more_rows, more_cols = pos.r > t.rows - 1, pos.c > t.cols - 1 in
      if more_rows || more_cols then
        let more b t p = if b then (if p > 2 * t then p else 2 * t) else t in
        let rows = more more_rows t.rows pos.r in
        let cols = more more_cols t.cols pos.c in
        resize rows cols t
      else t
    in
    t.data.(pos.r).(pos.c) <- v;
    t

  let set_rect (tl, br) v t =
    for r = tl.r to br.r do
      for c = tl.c to br.c do
        t.data.(r).(c) <- v
      done
    done;
    t

  let map_rect f (tl, br) t =
    for r = tl.r to br.r do
      for c = tl.c to br.c do
        t.data.(r).(c) <- f t.data.(r).(c)
      done
    done;
    t

  let map_recti f (tl, br) t =
    for r = tl.r to br.r do
      for c = tl.c to br.c do
        t.data.(r).(c) <- f {r; c} t.data.(r).(c)
      done
    done;
    t

  let fold_rect f a (tl, br) t =
    let a' = ref a in
    for r = tl.r to br.r do
      for c = tl.c to br.c do
        a' := f !a' t.data.(r).(c)
      done
    done;
    !a'

  let fold_recti f a (tl, br) t =
    let a' = ref a in
    for r = tl.r to br.r do
      for c = tl.c to br.c do
        a' := f !a' {r; c} t.data.(r).(c)
      done
    done;
    !a'
end
