open Ast

let try_int_of_string err s =
  try int_of_string s with Failure _ -> failwith err

let parse_value err vstr =
  match vstr with
  | "P" -> Undefined
  | "E" -> Empty
  | v -> Int (try_int_of_string err v)

let parse_h err h =
    if String.sub h 0 3 = "=#("
    then try_int_of_string err
        (String.sub h 3 (String.length h - 3))
    else failwith err

let parse_formula err fstr =
  let h, c1, r2, c2, v =
    String.split_on_char ',' fstr
    |> List.map String.trim
    |> (function
        | h :: c1 :: r2 :: c2 :: v :: []  ->
          h, c1, r2, c2, v
        | _ -> failwith err)
  in
  let rmin = parse_h err h
  in
  let cmin, rmax, cmax =
    ( try_int_of_string err c1
    , try_int_of_string err r2
    , try_int_of_string err c2 )
  in
  let v =
    try String.sub v 0 (String.length v - 1)
    with Invalid_argument _ -> failwith err
  in
    let v = parse_value err v in
    let p1 = build_pos rmin cmin in
    let p2 = build_pos rmax cmax in
    Occ ((p1, p2), v)

let is_formula_string string =
  String.sub (String.trim string) 0 1 = "="

(** [parse_formulas_in_line formulas row line] returns all the
   formulas parsed from [line] and adds then to the accumulator
   [formulas].*)
let parse_formulas_in_line formulas row line =
  let bad_format_err = "Bad format in user.txt file" in
  String.split_on_char ';' line
  |> List.fold_left
    (fun (i, l) cell  ->
       if is_formula_string cell
       then (i+1, (i, cell)::l)
       else (i+1, l)
    )
    (0, [])
  |> snd
  |> List.fold_left
    (fun fs (i, fstr) ->
       let formula = parse_formula bad_format_err fstr
       in
       (build_pos row i, formula) :: fs)
    formulas

(** [parse_formulas_in file l0 lf] parses the region of the
   file [file] between line [l0] and [l0+lf] and outputs
   the list of formulas with their positions in this region.  *)
let parse_formulas_in file l0 lf =
  let rec aux i formulas =
    if i > lf then
      formulas
    else
      let formulas =
        try (input_line file
             |> parse_formulas_in_line formulas (l0+i))
        with End_of_file -> raise (End formulas)
      in aux (i+1) formulas
  in
  aux 0 []
