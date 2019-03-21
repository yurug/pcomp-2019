open Ast
open Parser

type id = int

module R =
  Map.Make (struct
    type t = id
    let compare = compare end)

type area = int * int
type region = {area : area ; data : Regiondata.t}
type regs = region R.t
type regions = {regs : regs ; r_to_pos : pos -> id}

let string_of_id = string_of_int

let number_regions regions =
  R.cardinal regions.regs

let get_region_area regions id =
  (R.find id regions.regs).area

let get_region_data regions id =
  (R.find id regions.regs).data

let pos_to_region regions p =
  regions.r_to_pos p

let regions_within regions p1 p2 =
  let rmin = pos_to_region regions p1 in
  let rmax = pos_to_region regions p2 in
  let rec aux rm rM =
    if rm = rM then [rm]
    else rm :: aux (rm+1) rM in
  aux rmin rmax

let regions_fold f regions =
  R.fold (fun id {area;_} -> f id area)
    regions.regs

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
    then (close_in ic ; row-1, max_col, wbl, (formulas::all_formulas))
    else preproc (row+1) wbl (formulas::all_formulas) max_col ic
  in
  let max_row, max_col, wbl, formulas =
    open_in filename
    |> preproc 0 Mint.empty [] 0 in
  let formulas = List.flatten formulas in
  formulas, max_row, max_col, wbl

let compute_cuts filename min_region_size max_regions_nb =
  let formulas, rows, cols, wbl =
    preproc_file filename in

  let total_work = Mint.fold (fun _ q acc -> q + acc) wbl 0 in
  let line_by_region = max min_region_size (rows/max_regions_nb) in
  let regions_nb = rows/line_by_region in
  let work_by_region = total_work / regions_nb + 1 in

  let rec aux l0 lcurr acc current_q =
    if lcurr >= rows then (l0, lcurr)::acc
    else
      let work =
        match Mint.find_opt lcurr wbl with
        | None -> 0+current_q
        | Some w -> w+current_q
      in
      if current_q >= work_by_region then
        aux lcurr (lcurr+1) ((l0, lcurr-1)::acc) (current_q - work)
      else
        aux l0 (lcurr+1) acc work
  in
  match aux 0 0 [] 0 with
  | [] -> failwith "Empty data.csv file."
  | (l0, _) :: xs -> List.rev formulas, List.rev ((l0, rows) :: xs), cols

let compute_f_to_pos (regs: region R.t) : pos -> id =
  fun p ->
  let r, _ = pos p in
  let bindings = R.bindings regs in
  let tmp = List.find_opt  (fun (_,{area=(l0, l1);_}) -> l0 <= r && r <= l1) bindings in
  match tmp with
    | None -> failwith "Partioner.compute_f_to_pos "
    | Some (id, _) -> id

let compute_regions filename min_region_size max_regions_nb  =
  let formulas, cuts, max_col =
    compute_cuts filename min_region_size max_regions_nb in
  Format.printf "nbfile : %d@." (List.length cuts);
  let regs =
    List.fold_left
      (fun (i, map) ((l0, lf) as cut) ->
         let r = { area = cut ;
                   data = Regiondata.init (string_of_id i) (lf-l0+1) max_col } in
         (i+1, R.add i r map)
      )
      (0, R.empty)
      cuts
    |> snd
  in
  formulas, {regs; r_to_pos = compute_f_to_pos regs }

let cut_file_into_regions filename regions =
  let ic = open_in filename in
  R.iter
    (fun _ { area = (l0, lf) ; data} ->
       parse_and_write_value_in_region ic data l0 lf
    )
    regions.regs ; close_in ic

(* Defi programmation fonctionnelle pure, vous avez dit ? oups ...*)
let free_all regions : unit =
  R.iter
    (fun _ {data;_} ->
       Regiondata.free data
    )
     regions.regs

let recombine_regions filename regions : unit =
  let oc = open_out filename in
  R.iter
    (fun _ {data;_} ->
       Regiondata.output data oc
    )
    regions.regs
