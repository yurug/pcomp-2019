open Ast
open Parser
open Printer

type id = int

module R =
  Map.Make (struct
    type t = id
    let compare = compare end)

type area = int * int
type region = {filename : string ; area : area }

type regs = region R.t

type regions = {regs : regs ; r_to_pos : pos -> id}

exception Endfile of int

let build_name_file_region filename id =
  let ext, filename =
    String.split_on_char '.' filename
    |> List.rev
    |> (function
        | [] -> failwith "Master.build_name_region : empty filename."
        | ext :: xs ->
          let xs = List.rev xs in
          ext, String.concat "." xs) in
  filename^"_"^(string_of_int id)^"."^ext

let add_map key q map =
  match Mint.find_opt key map with
  | None -> Mint.add key q map
  | Some w -> Mint.add key (q+w) map

let add_work formulas wbl =
  let rec aux q l0 lf wbl =
    if l0 > lf then
      wbl
    else
      let w = add_map l0 q wbl in
      aux q (l0+1) lf w
  in
  List.fold_left
    (fun w (p, formulas) ->
       (* quantité de travail pour une formule = 2 (arbitraire) *)
       let rf, _ = pos p in
       let w = add_map rf 2 w in

       (* pour chaque ligne i nécessaire pour calculer une formule on
          ajoute (c2-c1) en travail à la ligne i*)
       match formulas with
       | Occ ((p1, p2), _) ->
         let (r1, c1) = pos p1 in
         let (r2, c2) = pos p2 in
         if c2 >= c1 then
           let q = c2 - c1 + 1 in
           aux q r1 r2 w
         else w
    )
    wbl
    formulas

let preproc_file filename =
  let rec preproc row wbl all_formulas max_col ic =
    let end_of_file, nb_col, formulas =
      try
        let nb_col, formulas = parse_formulas_in ic row row in
        false, nb_col, formulas
      with End formulas -> true, max_col, formulas
    in
    let wbl = add_work formulas wbl in
    let max_col = if nb_col > max_col then nb_col else max_col in
    if end_of_file
    then (close_in ic ; row, max_col, wbl, (formulas::all_formulas))
    else preproc (row+1) wbl (formulas::all_formulas) max_col ic
  in
  let max_row, max_col, wbl, formulas =
    open_in filename
    |> preproc 0 Mint.empty [] 0 in
  let formulas = List.flatten formulas in
  formulas, max_row, max_col, wbl


let compute_cuts filename file_max_size =

  let formulas, max_row, max_col, wbl =
    preproc_file filename in

  let total_work = Mint.fold (fun _ q acc -> q + acc) wbl 0 in
  let max_lines_by_reg =
    if max_col = 0 then file_max_size else file_max_size / max_col + 1 in
  (* Nombre minimal de region : au mieux les régions ont toute la
     taille max = la taille optimale.*)
  let min_nb_reg = max_row / max_lines_by_reg + 1 in
  (* Travail max par region : idéalement, on veut *)
  let max_q = total_work / min_nb_reg + 1 in
  (*Format.printf "maxline : %d minreg : %d max_q : %d" max_lines_by_reg min_nb_reg max_q ;*)
  let rec aux l0 lcurr acc current_q =
    if lcurr >= max_row then (l0, lcurr)::acc
    else if lcurr - l0 + 1 >= max_lines_by_reg then
      aux (lcurr+1) (lcurr+1) ((l0, lcurr)::acc) 0
    else
      let work =
        match Mint.find_opt lcurr wbl with
        | None -> 0+current_q
        | Some w -> w+current_q
      in
      if current_q >= max_q then
        aux lcurr (lcurr+1) ((l0, lcurr-1)::acc) (current_q - work)
      else
        aux l0 (lcurr+1) acc work
  in
  match aux 0 0 [] 0 with
  | [] -> failwith "Empty data.csv file."
  | (l0, _) :: xs -> formulas, List.rev ((l0, max_row) :: xs)

let compute_f_to_pos (regs: region R.t) : pos -> id =
  fun p ->
  let r, _ = pos p in
  let bindings = R.bindings regs in
  let tmp = List.find_opt  (fun (_,{area=(l0, l1);_}) -> l0 <= r && r <= l1) bindings in
  match tmp with
    | None -> failwith "Partioner.compute_f_to_pos "
    | Some (id, _) -> id

let compute_regions filename file_max_size  =
  let formulas, cuts =
    compute_cuts filename file_max_size in
  let regs =
    List.fold_left
      (fun (i, map) cut ->
         let r = {filename = build_name_file_region filename i;
                  area = cut} in
         (i+1, R.add i r map)
      )
      (0, R.empty)
      cuts
    |> snd
  in
  formulas, {regs; r_to_pos = compute_f_to_pos regs }

(* to redo *)
let cut_file_into_regions filename regions max_file_size =
  let ic = open_in filename in
  let rec cut file nb_line region =
    try
      if nb_line = (region+1)*max_file_size then
        let _ = close_out file in
        let new_region = region + 1 in
        let new_name = build_name_file_region filename new_region in
        let new_file = open_out new_name in
        cut new_file nb_line new_region
      else
        ( input_line ic
          |> Printf.fprintf file "%s\n" );
           cut file (nb_line+1) region
    with End_of_file -> close_out file

  in
  let first_file = open_out (build_name_file_region filename 0) in
  cut first_file 0 0; close_in ic

let get_region_filename regions id =
  (R.find id regions.regs).filename

let get_region_area regions id =
  (R.find id regions.regs).area

let pos_to_region regions p =
  regions.r_to_pos p

let regions_within regions p1 p2 =
  let rmin = pos_to_region regions p1 in
  let rmax = pos_to_region regions p2 in
  let rec aux rm rM =
    if rm = rM then [rm]
    else rm :: aux (rm+1) rM in
  aux rmin rmax

let number_regions regions =
  R.cardinal regions.regs

let regions_fold f regions =
  R.fold (fun id {area;_} -> f id area)
    regions.regs
