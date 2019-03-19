open Ast
open Partitioner

module D = Data.DataArray

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
let build_neighbours_map formulas l0 lf =
  List.fold_left
    (build_neighbours l0 lf)
    Mpos.empty
    formulas

(** [find_formula_opt dr pos graph]*)
let find_formula_opt region_depth pos graph =
  let region = pos_to_region region_depth pos in
  Graph.get_content region graph
  |> Mpos.find_opt pos
  |> (function | None -> None |Some f -> Some f)

let apply_change filename l0 pos v =
  let prel = relative_pos l0 pos in
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
