(* row * column *)
type pos =
  { r : int
  ; c : int }

(* top left * bottom right *)
type formula = Occ of (pos * pos) * value
             | Val of value

and value =
  | Undefined
  | Int of int

type cell = {value : value}

type action = Set of pos * formula

(* FIXME: ugly hack, needs workaround *)
type spreadsheet = cell list list

(* [value cell] return the field value of type value from [cell]. *)
let value {value} = value

let string_of_value = function Int i -> string_of_int i | _ -> "P"
