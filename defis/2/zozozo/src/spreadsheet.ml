open Ast
open Parser
open Partitioner
open Printer

(** [init_graph regions formulas] parses the file [ic] and initiates
   the dependency graph by adding the formulas to their corresponding
   region. Neighbours in [graph] are not taken care by this
   function. *)
let init_graph regions formulas =

  let rec aux (graph, curr_id, map) (pos, formulas)  =
    let id = pos_to_region regions pos in
    if id = curr_id then
      let map = Mpos.add pos {fin=formulas; eval= Undefined} map in
      graph, id, map
    else
      let graph = Graph.(add_node curr_id (build_node_no_neigh map) graph) in
      let map = Mpos.add pos {fin=formulas; eval= Undefined} Mpos.empty in
      graph, id, map
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
let build_graph filename regions formulas =
  let graph = init_graph regions formulas in
  let _ = Format.printf " nb regions : %d @." (number_regions regions) in
  let _ = Format.printf " formulas : %d @." (List.length formulas) in
  let graph = add_neighbours formulas graph regions in
  graph

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
              let diff = get_diff list_values zone v in
              if diff = 0 then (pos_compute :: pos_list),list_val
              else
                let region = pos_to_region regions pos_compute in
                let pos_region = Ast.relative_pos region pos_compute in
                let filename_region = get_region_filename regions region in
                let data = Data.DataArray.init filename_region in
                let old_value =
                  Ast.value (Data.DataArray.get pos_region data) in
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
                   (pos_compute,
                    (Int old_value, Int (old_value + diff))) :: list_val)
         ) ([],list_values) computables in
     let computables, order =
       FormulaOrder.get_new_computable_formulas pos_list order in
     something_to_value regions order computables list_values graph

let eval_one_change line regions graph =
  let string_list = String.split_on_char ' ' line in
  match string_list with
  | [] | [_] | [_;_] -> failwith "Parsing incorrect line"
  | r :: c :: t -> (* ajoute un entier d en (r,c) *)
     let r = int_of_string r in
     let c = int_of_string c in
     let pos = Ast.build_pos r c in
     let region = pos_to_region regions pos in
     let pos_region = Ast.relative_pos region pos in
     let formulas_region = Graph.get_content region graph in
     let filename_data_region = get_region_filename regions region in
     let data = Data.DataArray.init filename_data_region in
     let old_value = Ast.value (Data.DataArray.get pos_region data) in
     match t with
     | [d] ->
        let new_value = int_of_string d in
        let graph =
          match Mpos.find_opt pos formulas_region with
          | None -> graph (* entier -> entier*)
          | Some {fin = Occ((p1,p2),_);_} -> (* formule -> entier*)
             let content = Graph.get_content region graph in
             let content = Mpos.remove pos content in
             let graph = Graph.change_content region content graph in
             let list_region = Partitioner.regions_within regions p1 p2 in
             List.fold_left
               (fun graph region ->
                 let neighbours = Graph.get_neighbours region graph in
                 let neighbours = Mpos.remove pos neighbours in
                 Graph.change_neighbours region neighbours graph
               ) graph list_region
        in
        begin
          match old_value with
          | Empty -> failwith "Empry n'existe pas"
          | Int old_v when old_v = new_value -> graph,[]
          | _ ->
             let formulas =
               Graph.(Mpos.fold
                        (fun pos_formula {subregion = zone; formula = f} l ->
                          if Ast.pos_in_area pos zone
                          then (pos_formula,f) :: l
                          else l
                        ) (Graph.get_neighbours region graph) []) in
             let order =
               FormulaOrder.build_order_from_all regions graph formulas in
             let computables = FormulaOrder.get_computable_formulas order in
             let fst_change = [(pos,(old_value,Int new_value))] in
             graph,
             snd (something_to_value regions order computables fst_change graph)
        end
     | t ->
        let data_cell = String.concat "" t in
        let ((Occ((p1,p2),_)) as formula) =
          Parser.parse_formula "L'erreur ajout formule" data_cell in
        match Mpos.find_opt pos formulas_region with
        | None -> (* entier -> formule *)
           let content = Graph.get_content region graph in
           let content =
             Mpos.add pos {fin = formula; eval = Undefined} content in
           let graph = Graph.change_content region content graph in
           let list_region = Partitioner.regions_within regions p1 p2 in
           let graph =
             List.fold_left
               ( fun graph region ->
                 let neighbours = Graph.get_neighbours region graph in
                 let l0, lf = Partitioner.get_region_area regions region in
                 let subregion = Ast.narrowing p1 p2 l0 lf in
                 match subregion with
                 | None ->
                    failwith "region_within et narrowing sont pas d'accord"
                 | Some subregion ->
                    let neighbour =
                      {Graph.formula = formula; subregion = subregion} in
                    let neighbours = Mpos.add pos neighbour neighbours in
                    Graph.change_neighbours region neighbours graph
               ) graph list_region in
           let order =
             FormulaOrder.build_order_from regions graph (pos,formula) in
           begin
             match FormulaOrder.get_computable_formulas order with
             | [] ->
                let non_computable =
                  FormulaOrder.get_non_computable_formulas order in
                graph,(List.map (fun pos -> (pos,Undefined)) non_computable)
             | [(pos_form,f)] when pos_form = pos ->
                let eval = eval_formulas regions [(pos,f)] in
                begin
                  match eval with
                  | [(pos_form,Int new_value)] when pos_form = pos ->
                     begin
                       match old_value with
                       | Empty -> failwith "Empty is bullshit"
                       | Int old_v when old_v = new_value ->
                          graph,[]
                       | _ ->
                          let computables, order =
                            FormulaOrder.get_new_computable_formulas [pos] order in
                          let fst_change = [(pos,(old_value, Int new_value))] in
                          let order,change =
                            something_to_value regions order
                              computables fst_change graph in
                          let change =
                            List.fold_left
                              (fun change pos ->
                                (pos,Undefined) :: change)
                              change (FormulaOrder.get_non_computable_formulas order)
                          in
                          graph,change
                     end
                  | _ -> failwith "eval_formulas ne renvoie pas la meme taille de liste"
                end
             | _ -> failwith "entier -> formule créer plus d'une computable ?"
           end
        | Some {fin = (Occ((p1',p2'),_));_} ->
           let content = Graph.get_content region graph in
           let content = Mpos.add pos {fin = formula; eval = Undefined} content in
           let graph = Graph.change_content region content graph in
           let list_old_reg = Partitioner.regions_within regions p1' p2' in
           let graph =
             List.fold_left
               (fun graph region ->
                 let content = Graph.get_content region graph in
                 let content = Mpos.remove pos content in
                 Graph.change_content region content graph
               ) graph list_old_reg in
           let list_new_reg = Partitioner.regions_within regions p1 p2 in
           let graph =
             List.fold_left
               (fun graph region ->
                 let lr,lc = Partitioner.get_region_area regions region in
                 let subzone = Ast.narrowing p1 p2 lr lc in
                 match subzone with
                 | None -> failwith "narrowing et regions_within en contradiction"
                 | Some subzone ->
                    let neighbours = Graph.get_neighbours region graph in
                    let neighbour = {Graph.formula = formula; subregion = subzone} in
                    let neighbours = Mpos.add pos neighbour neighbours in
                    Graph.change_neighbours region neighbours graph
               ) graph list_new_reg in
           let order = FormulaOrder.build_order_from regions graph (pos,formula) in
           let rec aux computable order changes =
             match computable with
             | [] ->
                let non_comput = FormulaOrder.get_non_computable_formulas order in
                List.fold_left
                  (fun changes pos -> (pos,Undefined) :: changes)
                changes non_comput
             | _ ->
                let new_changes = eval_formulas regions computable in
                let pos_list = List.map fst new_changes in
                let computable,order =
                  FormulaOrder.get_new_computable_formulas pos_list order in
                aux computable order (new_changes @ changes)
           in graph, aux (FormulaOrder.get_computable_formulas order) order []


let eval_changes regions filename_user filename_change graph =
  let channel_in = open_in filename_user in
  let channel_out = open_out filename_change in
  let rec aux graph =
    try
      let line = input_line channel_in in
      let graph, changes = eval_one_change line regions graph in
      let changes = List.sort (fun (p1,_) (p2,_) -> Ast.compare_pos p1 p2) changes in
      output_string channel_out ("after \""^line^"\"\n");
      List.iter (fun (pos,v) ->
          output_string channel_out ((Printer.string_of_pos pos)^" "^(Printer.string_of_value v)^"\n")
        ) changes;
      apply_changes regions changes;
      aux graph
    with End_of_file ->
      close_in channel_in;
      close_out channel_out;
      graph
  in aux graph



(*
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
    *)
