open Ast
open Parser

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

let compute_cuts filename file_max_size =
  let ic = open_in filename in
  let work_by_line = Mint.empty in

  let rec prepos ic i wbl all_formulas =
    let end_of_file, formulas =
      try false, parse_formulas_in ic 0 1
      with End formulas -> true, formulas
    in
    let wbl = add_work formulas wbl in
    if end_of_file
    then i+1, wbl, (formulas::all_formulas)
    else prepos ic (i+1) wbl (formulas::all_formulas)
  in

  let lmax, wbl, formulas =
    prepos ic 0 work_by_line [] in

  let _ = close_in ic in
  (*LA*)
  let rec aux l acc =
    if l >= lmax then acc
    else
      let loff = l+file_max_size in
      aux loff ((l, loff-1)::acc)
    in
    match aux 0 [] with
    | [] -> failwith "Empty data.csv file."
    | (l0, _) :: xs -> List.rev ((l0, lmax) :: xs)

(* TODO optimize *)
let compute_f_to_pos (regs: region R.t) : pos -> id =
  fun p ->
  let r, _ = pos p in
  let bindings = R.bindings regs in
  let id, _ = List.find (fun (_,{area=(l0, l1);_}) -> l0 <= r && r <= l1) bindings in
  id
(*
  let rec find = function
    | [] ->
      let err =  "Partitionner.compute_f_to_pos: pos "^(string_of_pos p)^" not in file." in
      failwith err
    | (id, {area=(l0, l1); _}):: xs ->
      if l0 <= r && r <= l1 then
        id
      else
        find xs
  in
  find bindings*)

let compute_regions filename file_max_size  =
  let cuts =
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
  {regs; r_to_pos = compute_f_to_pos regs }


let cut_file_into_regions filename max_file_size =
  let regions = compute_regions filename max_file_size in

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
  cut first_file 0 0; close_in ic;
  regions

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
