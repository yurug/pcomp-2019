open Ast

type t = {data : cell array; rows : int; cols : int}

let create rows cols =
  {data = Array.create_matrix rows cols; rows = rows; cols = cols}

let get pos t =
  t.data.(pos.r).(pos.c)

let set pos v t =
  t.data.(pos.r).(pos.c) <- v

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
