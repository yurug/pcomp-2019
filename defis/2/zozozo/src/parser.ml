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

let parse_formulas_in_line formulas row line =
  let bad_format_err = "Bad format in user.txt file" in
  let cells = String.split_on_char ';' line in
  let nb_cells = List.length cells in
  let f =
    List.fold_left
      (fun (i, l) cell  ->
         if is_formula_string cell
         then (i+1, (i, cell)::l)
         else (i+1, l)
      )
      (0, [])
      cells
    |> snd
    |> List.fold_left
      (fun fs (i, fstr) ->
         let formula = parse_formula bad_format_err fstr
         in
         (build_pos row i, formula) :: fs)
      formulas in
  nb_cells, f

(** [parse_formulas_in file l0 lf] parses the region of the file
   [file] between line [l0] and [l0+lf] and outputs a pair composed
   of
    - the maximum cells in a line of the region
    - the list of formulas with their positions in this region.  *)
let parse_formulas_in file l0 lf =
  let rec aux i formulas max_c =
    if i > lf then
      max_c, formulas
    else
      let nb_cells, formulas =
        try (input_line file
             |> parse_formulas_in_line formulas i)
        with End_of_file -> raise (End formulas)
      in
      let max_c = if max_c < nb_cells then nb_cells else max_c in
      aux (i+1) formulas max_c
  in
  aux l0 [] 0

let parse_value_in_line data l0 line =
  let err = "Bad format in user.txt file" in
  let cells = String.split_on_char ';' line |> List.map String.trim in
  List.iteri
    (fun i cell ->
       let p = build_pos l0 i in
       if is_formula_string cell
       then Regiondata.set data p (create_cell Undefined)
       else
         let v = parse_value err cell in
         Regiondata.set data p (create_cell v)
    )
    cells

let parse_and_write_value_in_region file data l0 lf : unit =
  let rec aux i =
    if i <= lf then
      try input_line file
          |> parse_value_in_line data (i - l0); aux (i+1)
      with End_of_file -> ()
  in
  aux l0

(* [parse_change err change] parse a change (ex : 1 1 =#(0,0, 0, 1,
   1)) and returns a 3-uplet (b, pos, d) where [pos] is the position of
   the changed cell and

   - [b] = true if [d] is a string for a formula - [b] = false if [d]
   is a string for a value *)
let parse_change err change : bool * pos * string =
  let change =
    String.split_on_char ' ' change in
  match change with
  | [] | _ :: [] | _ :: _ :: [] ->
    failwith err
  | r :: c :: x1 :: xs ->
    let r, c = try_int_of_string err r,
               try_int_of_string err c in
      let pos = build_pos r c in
    if is_formula_string x1 then
      (true, pos, String.concat "" (x1::xs))
    else
      match xs with
      | [] -> false, pos, x1
      | _ -> failwith err


let parse_changes filename : (pos*value) list * (pos*is_formula content) list =
  let err = "Bad format error in "^filename in
  let ic = open_in filename in
  let rec aux ic values formulas =
    try
      let line = input_line ic in
      let is_formula, pos, d = parse_change err line in
      if is_formula
      then aux ic values ((pos, parse_formula err d)::formulas)
      else aux ic ((pos, parse_value err d)::values) formulas
    with End_of_file -> values, formulas in
  aux ic [] []
