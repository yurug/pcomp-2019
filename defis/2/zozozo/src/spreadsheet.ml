open Ast
open Partitioner
module D = Regiondata

(** [init_graph regions formulas] parses the file [ic] and initiates
   the dependency graph by adding the formulas to their corresponding
   region. Neighbours in [graph] are not taken care by this
   function. *)
let init_graph regions formulas =

  let aux (graph, curr_id, map) (pos, formulas)  =
    let id = pos_to_region regions pos in
    if id = curr_id then
      let map = Mpos.add pos {fin=formulas; eval= Undefined} map in
      graph, id, map
    else
      begin
        let graph = Graph.(add_node curr_id (build_node_no_neigh map) graph) in
        let map = Mpos.add pos {fin=formulas; eval= Undefined} Mpos.empty in
        graph, id, map
      end
  in
  let graph, last_id, map =
  List.fold_left
    aux
    (Graph.empty_graph, 0, Mpos.empty) formulas in

  Graph.(add_node last_id (build_node_no_neigh map) graph)


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
let build_graph regions formulas =
  let graph = init_graph regions formulas in
  let graph = add_neighbours formulas graph regions in
  graph


let preprocessing data_filename user_filename min_region_size max_nb_regions =
  let f, regions =
    Partitioner.compute_regions data_filename user_filename min_region_size max_nb_regions in
  Format.printf "Nb regions : %d@." (Partitioner.number_regions regions);
  Format.printf "Nb formulas : %d@." (List.length f);
  let _ = Partitioner.cut_file_into_regions data_filename regions in
  let g = build_graph regions f in
  f, regions, g


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
       let data = get_region_data regions id in
       Region.apply_change data l0 pos v
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
         let data = get_region_data regions id in
         let l0, lf = get_region_area regions id in
         Region.partial_eval tasks data l0 lf @ res
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


let rec something_to_value regions order computables list_values graph =
  match computables with
  | [] -> order,List.map (fun (p,(_,n)) -> (p,n)) list_values
  | _ ->
     let pos_list, list_values =
       List.fold_left
         (fun (pos_list,list_val) (pos_compute,Occ(zone,v)) ->
           match v with
           | Empty | Undefined -> failwith "On ne compte que des entiers"
           | Int v ->
             let region = pos_to_region regions pos_compute in
             let l0, _ = get_region_area regions region in
             let pos_region = Ast.relative_pos l0 pos_compute in
             let data = get_region_data regions region in
             let old_value = Ast.value (D.get data pos_region) in
             (pos_compute :: pos_list),
             (match old_value with
              | Empty -> failwith "C'est pas ta vrai form"
              | Undefined ->
                let content = Graph.get_content region graph in
                let {fin = formula;_} = try Mpos.find pos_compute content
                  with _ -> failwith "J'y crois 0" in
                let eval = eval_formulas regions [(pos_compute,formula)] in
                let eval = List.map
                    (fun (pos,new_val) -> (pos,(Undefined,new_val)))
                    eval in
                (eval @ list_values)
              | Int old_value ->
                let diff = get_diff list_values zone v in
                if diff = 0 then list_val
                else
                  (pos_compute,
                   (Int old_value, Int (old_value + diff))) :: list_val)
         ) ([],list_values) computables in
     let computables, order =
       FormulaOrder.get_new_computable_formulas pos_list order in
     something_to_value regions order computables list_values graph

let add_formula_neighbours regions p1 p2 graph pos formula =
  let list_region = Partitioner.regions_within regions p1 p2 in
  List.fold_left
    ( fun graph region ->
      let l0, lf = Partitioner.get_region_area regions region in
      let subregion = Ast.narrowing p1 p2 l0 lf in
      match subregion with
      | None ->
         failwith "region_within et narrowing sont pas d'accord"
      | Some subregion ->
         let neighbour = {Graph.formula = formula; subregion = subregion} in
         Graph.add_neighbour region pos neighbour graph
    ) graph list_region

let remove_formula_content regions p1 p2 graph pos =
  let list_old_reg = Partitioner.regions_within regions p1 p2 in
  List.fold_left
    (fun graph region ->
      Graph.remove_content region pos graph
    ) graph list_old_reg

let remove_formula_neighbours regions p1 p2 graph pos =
  let list_region = Partitioner.regions_within regions p1 p2 in
  List.fold_left
    (fun graph region ->
      Graph.remove_neighbour region pos graph
    ) graph list_region

let add_int regions region graph pos old_value new_value =
  match old_value with
  | Empty -> failwith "Empty n'existe pas"
  | Int old_v when old_v = new_value -> graph,[]
  | _ ->
     let neighbours = Graph.get_neighbours region graph in
     let formulas =
       Graph.(Mpos.fold
                (fun pos_formula {subregion = zone; formula = f} l ->
                  if Ast.pos_in_area pos zone
                  then (pos_formula,f) :: l
                  else l
                ) neighbours []) in
     let order =
       FormulaOrder.build_order_from_all regions graph formulas in
     let computables = FormulaOrder.get_computable_formulas order in
     let fst_change = [(pos,(old_value,Int new_value))] in
     graph,
     snd (something_to_value regions order computables fst_change graph)

let get_old_value regions region pos =
  let l0, _ = get_region_area regions region in
  let pos_region = Ast.relative_pos l0 pos in
  let data = get_region_data regions region in
  Ast.value (D.get data pos_region)

let string_to_pos r c =
  let r = int_of_string r in
  let c = int_of_string c in
  Ast.build_pos r c

let rec complete_eval regions computable order changes =
  match computable with
  | [] ->
     let non_comput = FormulaOrder.get_non_computable_formulas order in
     List.fold_left (fun changes pos -> (pos,Undefined) :: changes) changes non_comput
  | _ ->
     let new_changes = eval_formulas regions computable in
     let pos_list = List.map fst new_changes in
     let computable,order = FormulaOrder.get_new_computable_formulas pos_list order in
     complete_eval regions computable order (new_changes @ changes)

let add_formula ((Occ((p1,p2),_)) as formula) regions graph formulas_region pos region old_value =
  match Mpos.find_opt pos formulas_region with
  | Some {fin = (Occ((p1',p2'),_));_} -> (*formule -> formule*)
     let graph = remove_formula_content regions p1' p2' graph pos in
     let graph = add_formula_neighbours regions p1 p2 graph pos formula in
     let order = FormulaOrder.build_order_from regions graph (pos,formula) in
     graph, complete_eval regions (FormulaOrder.get_computable_formulas order) order []
  | None -> (* entier -> formule *)
     let graph = add_formula_neighbours regions p1 p2 graph pos formula in
     let order = FormulaOrder.build_order_from regions graph (pos,formula) in
     match FormulaOrder.get_computable_formulas order with
     | [] ->
        let non_computable = FormulaOrder.get_non_computable_formulas order in
        graph,(List.map (fun pos -> (pos,Undefined)) non_computable)
     | [(pos_form,f)] when pos_form = pos -> (* car ne retire pas de cycle*)
        let eval = eval_formulas regions [(pos,f)] in
        begin
          match eval with
          | [(pos_form,Int new_value)] when pos_form = pos ->
             begin
               match old_value with
               | Empty -> failwith "Empty is bullshit"
               | Int old_v when old_v = new_value -> graph,[]
               | _ ->
                  let computables, order =
                    FormulaOrder.get_new_computable_formulas [pos] order in
                  let fst_change = [(pos,(old_value, Int new_value))] in
                  let order,change =
                    something_to_value regions order computables fst_change graph in
                  let change =
                    List.fold_left
                      (fun change pos -> (pos,Undefined) :: change)
                      change (FormulaOrder.get_non_computable_formulas order)
                  in
                  graph,change
             end
          | _ -> failwith "eval_formulas ne renvoie pas la meme taille de liste"
        end
     | _ ->  failwith "entier -> formule créer plus d'une computable ?"


let eval_one_change line regions graph =
  let string_list = String.split_on_char ' ' line in
  match string_list with
  | [] | [_] | [_;_] -> failwith "Parsing incorrect line"
  | r :: c :: t -> (* ajoute un entier d en (r,c) *)
     let pos = string_to_pos r c in
     let region = pos_to_region regions pos in
     let old_value = get_old_value regions region pos in
     let formulas_region = Graph.get_content region graph in
     let t = String.concat "" t in
     let t = String.split_on_char ',' t in
     match t with
     | [d] ->
        let new_value = int_of_string d in
        let graph =
          match Mpos.find_opt pos formulas_region with
          | None -> graph (* entier -> entier*)
          | Some {fin = Occ((p1,p2),_);_} -> (* formule -> entier*)
             let graph = Graph.remove_content region pos graph in
             remove_formula_neighbours regions p1 p2 graph pos
        in
        add_int regions region graph pos old_value new_value

     | _ :: _ :: _ :: _ :: _ :: [] ->
        let data_cell = String.concat "," t in
        let formula = Parser.parse_formula "Erreur ajout formule" data_cell in
        let graph = Graph.add_content region pos {fin = formula; eval = Undefined} graph in
        add_formula formula regions graph formulas_region pos region old_value
     | _ -> failwith "changes incorrect"


let eval_changes regions filename_user filename_change graph =
  let ic = open_in filename_user in
  let oc = open_out filename_change in
  let rec aux graph =
    try
      let line = input_line ic in
      let graph, changes = eval_one_change line regions graph in
      let changes = List.sort (fun (p1,_) (p2,_) -> Ast.compare_pos p1 p2) changes in
      output_string oc ("after \""^line^"\":\n");
      List.iter (fun (pos,v) ->
          output_string oc ((Printer.string_of_pos pos)^" "^(Printer.string_of_value v)^"\n")
        ) changes;
      apply_changes regions changes;
      aux graph
    with End_of_file ->
      close_in ic;
      close_out oc;
      graph
  in aux graph
