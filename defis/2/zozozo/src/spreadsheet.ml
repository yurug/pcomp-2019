open Ast

(* Optimisation possible : découper le fichier par quantité de travail
   plutot que par nombre de ligne.

   Difficultés :

   1- l'essentiel du travail consiste à faire les évaluations
   partielles de formules à l'initialisation ou quand une nouvelle
   formule est ajoutée. Comme on parallélise sur les données et non
   sur les tâches, il possible de séparer équitablement le travail
   pour l'évaluation initiale mais il sera plus difficile de le
   séparer ensuite dynamiquement quand de nouvelles formules vont
   s'ajouter.

   2- Beaucoup de fonctions sont paramétrées sur la profondeur des
   régions + les régions sont identifiées par un unique label

   Solution à 2 : - On peut garder un identifiant entier et ajouter au
   contenu d'un noeud (= une région) dans le graphe les informations
   utiles pour savoir découper la région (pos des caractères de début
   et de fin) puis modifier les fonctions impactées.

*)
let build_name_file_region filename region =
  let ext, filename =
    String.split_on_char '.' filename
    |> List.rev
    |> (function | [] -> failwith "Master.build_name_region : empty filename."
                 | ext :: xs ->
                   let xs = List.rev xs in
                   ext, String.concat "." xs) in
  filename^"_"^(string_of_int region)^"."^ext

let cut_file_into_region filename region_depth =
  let ic = open_in filename in

  let rec cut file nb_line region =
    try
      if nb_line = (region+1)*region_depth then
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



(** [init_graph dr ic] parses the file [ic] to find all formulas and
   initiates the dependency graph by adding the found formulas to
   their corresponding region. Neighbours are not taken care in this
   function. *)
let init_graph region_depth ic   =

  let rec aux all_regions all_formulas line_nb region graph =

    let end_of_file, formulas =
      try
        false,
        Region.parse_formulas_in region_depth ic line_nb
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
        Graph.(add_node region (build_node_no_neigh mapFormulas) graph) in

    if end_of_file
    then region :: all_regions, graph, (formulas::all_formulas)
    else
      let regions = region :: all_regions in
      aux regions
        (formulas :: all_formulas)
        (line_nb+region_depth)
        (region+1)
        graph

  in
  aux [] [] 0 0 Graph.empty_graph


(** [add_neighbours dr f g regions] goes through all regions [regions]
   and add their neigbours to the graph [g] i.e. the formulas whose
   value are dependant on some part of the region. *)
let add_neighbours region_depth formulas graph regions =
  List.fold_left
    (fun g rl ->
       let neighbours =
         Region.build_neighbours_map region_depth formulas rl in
       Graph.change_neighbours rl neighbours g)
      graph
      regions


(** [build_graph filename dr] create the dependency graph from the data file named [filename] and with a region depth (nb of line by region) of [dr]. *)
let build_graph filename region_depth =
  let ic = open_in filename in
  let regions, graph, formulas = init_graph region_depth ic in
  let formulas = List.concat formulas in
  let _ = Format.printf " nb regions : %d @." (List.length regions) in
  let _ = Format.printf " formulas : %d @." (List.length formulas) in
  let _= close_in ic in
  let graph = add_neighbours region_depth formulas graph regions in
  formulas, graph

(* TODO : optimiser ! *)
(** [tasks_by_region dr c] takes a list of computable formulus [c] and
   returns a map mapping region label (int) to a list of formulas that
   has to be partially evaluated in the corresponding region.  *)
let tasks_by_region region_depth computable =
  let tasks_sorted_by_region =
    List.map
      (fun ((_, Occ ((p1, p2), _)) as formula) ->
         let regions = regions_within region_depth p1 p2 in
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


let apply_changes filename region_depth evaluated_formulas =
  List.iter
    (fun (pos, v) ->
       let region = Ast.pos_to_region region_depth pos in
       let filename = build_name_file_region filename region in
       Region.apply_change filename region_depth region pos v
    )
    evaluated_formulas


let eval_formulas filename region_depth computable =
  let tasks_list_map =
    tasks_by_region region_depth computable in
  (* Les taches sont triées par label de region = label d'esclaves *)
  if tasks_list_map = Mint.empty then []
  else
    Mint.fold
      (fun region tasks res ->
         let filename = build_name_file_region filename region in
         Region.partial_eval tasks filename (region*region_depth) ((region+1)*region_depth-1) @ res
      )
      tasks_list_map
      []
    |> List.sort (fun (p1, _, _) (p2, _, _) -> compare_pos p1 p2)
    |> (fun x -> combine_evals x)

let rec loop_eval filename region_depth order computable =
  (* Les taches sont triées par label de region = label d'esclaves *)
  let formulas_evaluated = eval_formulas filename region_depth computable in
  let () = apply_changes filename region_depth formulas_evaluated in
  let pos_evaluated = List.map (fun (p, _) -> p) formulas_evaluated in
  let new_computable, order =
    FormulaOrder.get_new_computable_formulas pos_evaluated order in
  let order = FormulaOrder.remove_evaluated_formula pos_evaluated order in
  match new_computable with
  | [] -> formulas_evaluated, order
  | _  ->
    let fe, order =
      (loop_eval filename region_depth order new_computable) in
        fe @ formulas_evaluated, order

(** [first_evaluation filename dr f g] *)
let first_evaluation filename region_depth formulas graph =
  let order =
    FormulaOrder.build_order_from_all region_depth graph formulas in
  let computable =
    FormulaOrder.get_computable_formulas order in
  let formulas_evaluated, order = loop_eval filename region_depth order computable in
  let formulas_indefined =
    FormulaOrder.get_non_computable_formulas order
    |> List.map (fun p -> (p, Undefined)) in
  let () = apply_changes filename region_depth formulas_indefined in
  ()
  (*List.iter
    (fun (p1, eval) ->
       Format.printf "Formule en %s vaut %d@." (string_of_pos p1) eval)
    formulas_evaluated;
  List.iter
    (fun p ->
       Format.printf "Formule pas calculable en %s" (string_of_pos p))
    formulas_indefined*)

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
