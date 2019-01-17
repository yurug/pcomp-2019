type pos = { r : int; c : int}  (* row * column *)

type cell =
  { value : value; formula : formula option }

and formula =
  | Occ of (pos * pos) * value  (* top left * bottom right *)

and value =
  | Undefined
  | Int of int
