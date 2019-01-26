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

and content = Cst of value | Formula of formula

type action = Set of pos * content

(* FIXME: ugly hack, needs workaround *)
type spreadsheet = cell list list

(* [value cell] return the field value of type value from [cell]. *)
let value {value} = value

let string_of_value = function Int i -> string_of_int i | _ -> "P"

let compare_pos {r=r1; c=c1} {r=r2; c=c2} =
  let res = compare r1 r2 in
  if res = 0 then compare c1 c2
  else res


module Mpos = Map.Make(struct
    type t = pos
    let compare = compare_pos
  end )

module Spos = Set.Make(struct
    type t = pos
    let compare = compare_pos
  end )
