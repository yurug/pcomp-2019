open Ast
open Parser
open Partitioner

(** [init_graph regions ic] parses the file [ic] to find all formulas
   and initiates the dependency graph by adding the found formulas to
   their corresponding region. Neighbours in [graph] are not taken
   care by this function. *)
let init_graph regions ic =

  let rec aux all_formulas id graph =
    let l0, l1 = get_region_area regions id in

    let end_of_file, formulas =
      try false, parse_formulas_in ic l0 l1
      with End formulas -> true, formulas
    in

    let graph =
      match formulas with
      | [] -> graph
      | _  ->
        let mapFormulas =
          List.fold_left
            (fun map (pos, formula) ->
               Mpos.add pos {fin=formula; eval= Undefined} map)
            Mpos.empty
            formulas
        in
        Graph.(add_node id (build_node_no_neigh mapFormulas) graph)
    in

    if end_of_file
    then graph, (formulas::all_formulas)
    else
      aux (formulas :: all_formulas) (id+1) graph

  in
  aux [] 0 Graph.empty_graph

(** [add_neighbours formulas g regions] goes through all regions
   [regions] and add their neigbours to the graph [g] i.e. the
   formulas whose value are dependant on some part of the region. *)
let add_neighbours formulas graph regions =
  let aux id  (l0, l1) g =
    let neighbours =
      Region.build_neighbours_map formulas l0 l1 in
    Graph.change_neighbours id neighbours g
  in
  regions_fold aux regions graph

(** [build_graph filename regions] create the dependency graph from
   the data file named [filename] and with the regions defined in
   [regions] as node.*)
let build_graph filename regions =
  let ic = open_in filename in
  let graph, formulas = init_graph regions ic in
  let formulas = List.concat formulas in
  let _ = Format.printf " nb regions : %d @." (number_regions regions) in
  let _ = Format.printf " formulas : %d @." (List.length formulas) in
  let _= close_in ic in
  let graph = add_neighbours formulas graph regions in
  formulas, graph

(* TODO : optimiser ! *)
(** [tasks_by_region regions c] takes a list of computable formulus
   [c] and returns a map mapping region label (int) to a list of
   formulas that has to be partially evaluated in the corresponding
   region. *)
let tasks_by_region regions computable =
  let tasks_sorted_by_region =
    List.map
      (fun ((_, Occ ((p1, p2), _)) as formula) ->
         let regions = regions_within regions p1 p2 in
         List.map
           (fun r -> (r, formula))
           regions
      )
      computable
    |> List.concat
    |> List.sort (fun (r1, _) (r2, _) -> compare r1 r2)
  in
  let rec build_map map acc r0 = function
    | [] ->
      if r0 <> -1 then
        Mint.add r0 acc map
      else
        map
    | (r, f) :: xs ->
      if r = r0 then
        build_map map (f :: acc) r0 xs
      else
        begin
          if r0 <> -1 then
            let map = Mint.add r0 acc map in
            build_map map [f] r xs
          else
            build_map map [f] r xs
        end
  in
  build_map Mint.empty [] (-1) tasks_sorted_by_region


(** [combine_evals sorted_partial] take the partial evaluations of
   each computed formulas and combines then to obtain the global
   evaluation. [sorted_partial] must be sorted by position (their
   first projection). *)
let combine_evals sorted_partial =
  let rec aux acc_res acc_eval prev_pos = function
    | [] ->
      if prev_pos = build_pos (-1) (-1)
      then []
      else (prev_pos, Ast.Int acc_eval) :: acc_res
    | (p1, Occurrence, v) :: xs ->
      if prev_pos = p1 then
        aux acc_res (acc_eval + v) prev_pos xs
      else
        begin
          if prev_pos = build_pos (-1) (-1)
          then aux acc_res v p1 xs
          else
            aux ((prev_pos, Ast.Int acc_eval) :: acc_res) v p1 xs
        end
  in
  aux [] 0 (build_pos (-1) (-1)) sorted_partial


let apply_changes regions evaluated_formulas =
  List.iter
    (fun (pos, v) ->
       let id = pos_to_region regions pos in
       let l0, _ = get_region_area regions id in
       let filename = get_region_filename regions id in
       Region.apply_change filename l0 pos v
    )
    evaluated_formulas

let eval_formulas regions computable =
  let tasks_list_map =
    tasks_by_region regions computable in
  (* Les taches sont triées par label de region = label d'esclaves *)
  if tasks_list_map = Mint.empty then []
  else
    Mint.fold
      (fun id tasks res ->
         let filename = get_region_filename regions id in
         let l0, lf = get_region_area regions id in
         Region.partial_eval tasks filename l0 lf @ res
      )
      tasks_list_map
      []
    |> List.sort (fun (p1, _, _) (p2, _, _) -> compare_pos p1 p2)
    |> (fun x -> combine_evals x)

let rec loop_eval regions order computable =
  let formulas_evaluated = eval_formulas regions computable in
  let () = apply_changes regions formulas_evaluated in
  let pos_evaluated =
    List.map (fun (p, _) -> p) formulas_evaluated in
  let new_computable, order =
    FormulaOrder.get_new_computable_formulas pos_evaluated order in
  let order =
    FormulaOrder.remove_evaluated_formula pos_evaluated order in
  match new_computable with
  | [] -> formulas_evaluated, order
  | _  ->
    let fe, order =
      (loop_eval regions order new_computable) in
        fe @ formulas_evaluated, order

(** [first_evaluation regions f g] *)
let first_evaluation regions formulas graph =
  let order =
    FormulaOrder.build_order_from_all regions graph formulas in
  let computable =
    FormulaOrder.get_computable_formulas order in
  let _, order = loop_eval regions order computable in
  let formulas_indefined =
    FormulaOrder.get_non_computable_formulas order
    |> List.map (fun p -> (p, Undefined)) in
  apply_changes regions formulas_indefined

  (*
  let tasks_list_map =
    tasks_by_region region_depth computable in
  (* Les taches sont triées par label de region = label d'esclaves *)
  Mint.fold
    (fun region tasks res ->
       let filename = build_name_file_region filename region in
       Region.partial_eval tasks filename (region*region_depth) ((region+1)*region_depth-1)::res
    )
    tasks_list_map
    []
  |> List.concat
  |> List.sort (fun (p1, _, _) (p2, _, _) -> compare_pos p1 p2)
  |> (fun x -> combine_evals x)
  |> List.iter
    (fun (p1, eval) ->
       Format.printf "Formule en %s vaut %d@." (string_of_pos p1) eval)*)
let get_diff list_values zone value =
    List.fold_left
      (fun n (pos_value,(old_v,new_v)) -> (*old_v <> new_v*)
        if not(Ast.pos_in_area pos_value zone)
        then n
        else
          match old_v,new_v with
          | Int i, _ when value = i -> n-1
          | _, Int i when value = i -> n+1
          | _ -> n
      ) 0 list_values

let rec value_to_value region_depth data_filename order computables list_values =
  match computables with
  | [] -> List.map (fun (p,(_,n)) -> (p,n)) list_values
  | _ ->
     let pos_list, list_values =
       List.fold_left
         (fun (pos_list,list_val) (pos_compute,Occ(zone,v)) ->
           match v with
           | Empty | Undefined -> failwith "On ne compte que des entiers"
           | Int v ->
              let diff = get_diff list_values zone v in
              if diff = 0 then pos_list,list_val
              else
                let region = Ast.pos_to_region region_depth pos_compute in
                let pos_region = Ast.relative_pos region pos_compute in
                let filename_region = build_name_file_region data_filename region in
                let data = Data.DataArray.init filename_region in
                let old_value = Ast.value (Data.DataArray.get pos_region data) in
                match old_value with
                | Empty | Undefined -> failwith "C'est pas vrai"
                | Int old_value ->
                   (pos_compute :: pos_list),
                   ((pos_compute,(Int old_value, Int (old_value + diff))) :: list_val)
         ) ([],list_values) computables in
     let computables, order = FormulaOrder.get_new_computable_formulas pos_list order in
     value_to_value region_depth data_filename order computables list_values



let eval_one_change data_filename change_filename line region_depth graph =
  let string_list = String.split_on_char ' ' line in
  match string_list with
  | [] | [_] | [_;_] -> failwith "Parsing incorrect line"
  | r :: c :: d :: [] -> (* ajoute un entier d en (r,c) *)
     let r = int_of_string r in
     let c = int_of_string c in
     let d = int_of_string d in
     let pos = Ast.build_pos r c in
     let region = Ast.pos_to_region region_depth pos in
     let pos_region = Ast.relative_pos region pos in
     let formulas_region = Graph.get_neighbours region graph in
     let filename_data_region = build_name_file_region data_filename region in
     let data = Data.DataArray.init filename_data_region in
     let old_value = Ast.value (Data.DataArray.get pos_region data) in
     match Mpos.find_opt pos formulas_region with
     | None -> (*L'ancienne valeur est un entier*)
        begin
          match old_value with
          | Empty -> failwith "Empty n'existe pas"
          | Undefined -> failwith "Un entier est forcement défini"
          | Int old_value ->
             if old_value = d then graph,[]
             else(*L'ancienne et la nouvelle valeur sont différentes*)
               let formulas =
                 Graph.(Mpos.fold
                          (fun pos {subregion = zone; formula = f} l ->
                            if Ast.pos_in_area pos zone
                            then (pos,f) :: l
                            else l
                 ) formulas_region []) in
               let order = FormulaOrder.build_order_from_all region_depth graph formulas in
               let computables = FormulaOrder.get_computable_formulas order in
               let fst_change = [(pos,(Int old_value,Int d))] in
               graph,(value_to_value region_depth data_filename order computables fst_change)
        end
     | Some f ->  (*L'ancienne valeur est une formule*)
        match old_value with
        | Empty -> failwith "Empty n'existe pas"
        | Undefined -> graph,[(Ast.build_pos r c,Int d)] (*Ajouter un entier n'ajoute pas de cycle *)
        | Int i -> graph,[]



  (* | r :: c :: t ->
   *    let data_cell = String.concat "" t in
   *    let data_cell = String.split_on_char ',' data_cell in
   *    let data_cell = List.map String.trim data_cell in
   *    data_cell *)

(* Probablement à optimiser (linéaire ici). Peut-être construire une
   map de formulas. A voir en fonction des autres utilisations de
   formulas. *)
let find_formulas pos formulas : (pos * is_formula content) option =
  List.find_opt (fun (p, _) -> p = pos) formulas

(* [read_change err change] return a 3-uplet (b, pos, d) where [pos]
   is the position of the changed cell and

   - [b] = true if [d] is a string for a formula
   - [b] = false if [d] is a string for a value
*)
let read_change err change : bool * pos * string =
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

(* J'ai mis des arguments mais il faut probablement les revoir *)
let rec apply_one_change regions formulas graph change =
  let err = "Bad format in user.txt file" in
  let (is_new_formula, pos, d) = read_change err change
  in
  let old_form_opt = find_formulas pos formulas in
  if is_new_formula then
    let new_formula = parse_formula err d in
    match old_form_opt with
    | None ->
      change_value_with_formula graph pos new_formula
    | Some (_, old_formula) ->
      change_formula_with_formula graph pos old_formula new_formula
  else
    let new_value = Val (parse_value err d) in
    match old_form_opt with
    | None ->
      change_value_with_value graph pos new_value
    | Some (_, old_formula) ->
      change_formula_with_value graph pos old_formula new_value

and change_formula_with_value graph pos old_formula new_value =
  failwith "TODO"

and change_formula_with_formula graph pos old_formula new_formula =
  failwith "TODO"

and change_value_with_value graph pos new_value =
    failwith "TODO"

and change_value_with_formula graph pos new_formula =
    failwith "TODO"
