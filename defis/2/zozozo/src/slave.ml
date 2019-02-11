open Ast

module D = Data.DataArray

let try_int_of_string err s =
  try int_of_string s with Failure _ -> failwith err


let parse_value err vstr =
  match vstr with
  | "P" -> Ast.Undefined
  | "E" -> Ast.Empty
  | v -> Ast.Int (try_int_of_string err v)


let parse_formula err h c1 r2 c2 v =
    let rmin =
      if String.sub h 0 3 = "=#("
      then try_int_of_string err (String.sub h 3 (String.length h - 3))
      else failwith err
    in
    let cmin, rmax, cmax =
      ( try_int_of_string err c1
      , try_int_of_string err r2
      , try_int_of_string err c2 )
    in
    let v =
      try String.sub v 0 (String.length v - 1) with Invalid_argument _ ->
        failwith err
    in
    let v = parse_value err v in
    Ast.Occ ((build_pos rmin  cmin, build_pos rmax cmax), v)


(** [parse_formulas_in_line line_nb formulas line] returns all the
   formulas parsed from [line] and adds then to the accumulator
   [formulas]. [line_nb] is the number of the line parsed. It is used
   to compute the position of the found formulas. *)
let parse_formulas_in_line line_nb formulas line =
  let bad_format_err = "Bad format in user.txt file" in
  String.split_on_char ';' line
  |> List.fold_left
    (fun (i, l) cell  ->
       if String.sub (String.trim cell) 0 1 = "="
       then (i+1, (i, cell)::l)
       else  i+1, l )
    (0, [])
  |> snd
  |> List.fold_left
    (fun fs (i, formula) ->
       String.split_on_char ',' formula
       |> List.map String.trim
       |> (function
           | h :: c1 :: r2 :: c2 :: v :: [] ->
             let formula = parse_formula
                 bad_format_err h c1 r2 c2 v in
             (build_pos line_nb i, formula) :: fs
           | _ -> failwith bad_format_err))
    formulas

(** [parse_formulas_in_region dr file l0] parses the region of the
   file [file] between line [l0] and [l0+region_depth-1] and outputs
   the list of formulas with their positions in this region.  *)
let parse_formulas_in region_depth file l0 =
  let rec aux n formulas =
    if n = region_depth then
      formulas
    else
      let formulas =
        try (input_line file
             |> parse_formulas_in_line (l0 + n) formulas)
        with End_of_file -> raise (End formulas)
      in aux (n+1) formulas
  in
  aux 0 []

(** [build_neighbours l0 lf map formula] *)
let build_neighbours l0 lf map formula =
  let pos, (Occ ((p1, p2), _) as formula) = formula in
  let build_neighbour l0 lf p1 p2  =
    match narrowing p1 p2 l0 lf with
    | None       -> None
    | Some (a,b) -> Some Graph.{formula = formula; subregion = a, b}
  in
  match build_neighbour l0 lf p1 p2 with
  | None -> map
  | Some t -> Mpos.add pos t map

(** [build_neighbours_map dr formulas rlabel] *)
let build_neighbours_map region_depth formulas rlabel =
  let l0 = rlabel * region_depth in
  List.fold_left
    (build_neighbours l0 (l0+region_depth-1))
    Mpos.empty
    formulas


(** [find_formula_opt dr pos graph]*)
let find_formula_opt region_depth pos graph =
  let region = pos_to_region region_depth pos in
  Graph.get_content region graph
  |> Mpos.find_opt pos
  |> (function | None -> None |Some f -> Some f)


let apply_change filename region_depth region pos v =
  let prel = relative_pos (region_depth*region) pos in
  let data = D.init filename in
  let data = D.set prel (create_cell v) data in
  D.output_init data filename


let eval_occ data p p' v =
  D.fold_rect
    (fun acc cell -> if Ast.value cell = v then acc + 1 else acc)
    0
    (p, p')
    data

(* TODO : pour l'instant on construit data ici *)
(** [partial_eval computable filename]*)
let partial_eval computable_formulas filename l0 lf =
  let data = D.init filename in
  List.map
    (fun f ->
       match f with
       | (pos, (Occ ((p1, p2), v))) ->
         let (pm, pM) =
           match narrowing p1 p2 l0 lf with
           | None -> failwith "Spreadsheet.partial_eval : should not happens."
           | Some (pm, pM) -> relative_pos l0 pm, relative_pos l0 pM
         in
         pos, Occurrence, eval_occ data pm pM v)
    computable_formulas

(* TODO *)
(* Travail du slave [pos_to_region region_depth pos]. L'esclave envoie aussi de nouvelles tasks au master *)
(*let rec update_cell (type a) region_depth pos (new_cell: a content) graph : Graph.t =
  let fopt = find_formula_opt region_depth pos graph in
  match fopt, new_cell with
  | None,   (Val _ as cell) -> change_value_for_value pos cell g
raph
  | Some f, (Val _ as cell) -> change_formula_for_value pos f cell graph
  | None,   (Occ (_, _) as cell) -> change_value_for_formula pos cell graph
  | Some f, (Occ (_, _) as cell) -> change_formula_for_formula pos f cell graph

and change_value_for_value pos new_value graph =
  assert false
and change_formula_for_value pos old_formula new_value graph =
  assert false
and change_value_for_formula pos new_formula graph =
  assert false
and change_formula_for_formula pos old_formula new_formula graph =
  assert false*)
