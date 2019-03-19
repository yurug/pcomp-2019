(* row * column *)
type pos =
  { r : int
  ; c : int }

let pos {r;c} = r, c
let build_pos r c = {r; c}

type is_formula = Is_formula
type not_formula = Not_formula

type 'a content =
  | Occ : (pos * pos) * value -> is_formula content
  | Val : value -> not_formula content

and value =
  | Empty
  | Undefined
  | Int of int

type 'a action = Set of pos * 'a content

exception End of ((pos * is_formula content) list)

let string_of_value = function
  | Int i -> string_of_int i
  | Undefined -> "P"
  | Empty -> " "

let string_of_pos {r; c} = "(" ^ string_of_int r ^ "," ^ string_of_int c ^ ")"

let string_of_content (type a) (content : a content) =
  match content with
  | Val v -> string_of_value v
  | Occ ((p1, p2), v) ->
    "Occ ("
    ^ string_of_pos p1
    ^ ", "
    ^ string_of_pos p2
    ^ "), "
    ^ string_of_value v
    ^ ") "

let compare_pos {r = r1; c = c1} {r = r2; c = c2} =
  let res = compare r1 r2 in
  if res = 0 then compare c1 c2 else res

module Mint = Map.Make (struct
  type t = int

  let compare = compare
end)

module Mpos = Map.Make (struct
  type t = pos

  let compare = compare_pos
end)

module Spos = Set.Make (struct
  type t = pos

  let compare = compare_pos
end)

type formula = { fin : is_formula content ;
                 eval : value }

type formulas = formula Mpos.t

(* différents types de formules *)
type fkind = Occurrence

type cell = {value : value}
let create_cell v = {value = v}
let value {value=v} = v

let empty_formulas = Mpos.empty

let build_formula p1 p2 v =
  {fin = Occ ((p1, p2), v) ; eval = Undefined}

let pos_to_region lf p =
  let r, _ = pos p in
  r / lf

let pos_in_area p0 (p1, p2) =
  let (r0, c0), (r1, c1), (r2, c2) = pos p0, pos p1, pos p2 in
  r0 >= r1 && r0 <= r2 && c0 >= c1 && c0 <= c2

let relative_pos l0 p =
  let r, c = pos p in
  build_pos (r-l0) c


(** [narrowing p1 p2 l0 lf] returns the intersection between the area
   defined by ([p1], [p2]) and the area between lines [l0] and [lf].
   *)
let narrowing p1 p2 l0 lf =
  let (r1, c1), (r2, c2) = pos p1, pos p2 in
  let ropt =
    if r1 > lf || r2 < l0 then None
    else (if r1 <= l0
          then (if r2 >= lf then Some (l0, lf)
                else Some (l0, r2))
          else (if r2 >= lf then Some (r1, lf)
                else Some (r1, r2))) in
  match ropt with
  | None -> None
  | Some (r1, r2) -> Some (build_pos r1 c1, build_pos r2 c2)
