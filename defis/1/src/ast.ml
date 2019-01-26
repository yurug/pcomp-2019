(* row * column *)
type pos =
  { r : int
  ; c : int }

(* top left * bottom right *)
type formula = Occ of (pos * pos) * value

and value =
  | Undefined
  | Int of int

type cell =
  { value : value }

type action = Set of pos * cell

(* FIXME: ugly hack, needs workaround *)
type spreadsheet = cell list list
