(* row * column *)
type pos =
  { r : int
  ; c : int }

type cell =
  { value : value
  ; formula : formula option }

(* top left * bottom right *)
and formula = Occ of (pos * pos) * value

and value =
  | Undefined
  | Int of int

type action = Set of pos * cell

(* FIXME: ugly hack, needs workaround *)
type spreadsheet = cell list list
