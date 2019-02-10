open Ast

type color =
  | White
  | Black

type node =
  { nb_depend : int
  ; neighbours : (is_formula content) Mpos.t
  ; content : is_formula content
  ; color : color }

type order = node Mpos.t

let empty_order = Mpos.empty

let build_node nb_depend content neighbours color =
  {nb_depend; content; neighbours; color}

(* Calcul local *)
let get_dependent_formulas dr pos graph =
  let region = pos_to_region dr pos in
  let neigh = Graph.get_neighbours region graph in
  Mpos.fold
    ( fun p Graph.{formula ; subregion} formulas ->
        if pos_in_area pos subregion then
          Mpos.add p formula formulas
        else
          formulas
    )
    neigh
    Mpos.empty

let rec traversal f neigh order = Mpos.fold f neigh order

and add_node region_depth graph pos formula order =
  let node_opt = Mpos.find_opt pos order in
  let prev_color, node =
    match node_opt with
    | None ->
      let neighbours = get_dependent_formulas region_depth pos graph in
      White, build_node 1 formula neighbours Black
    | Some ({color; _} as node) ->
      color, {node with nb_depend = node.nb_depend + 1; color = Black}
  in
  let order = Mpos.add pos node order in
  match prev_color with
  | Black -> order
  | White -> traversal (add_node region_depth graph) node.neighbours order


let build_order_from_ region_depth graph (pos, formula) (order : order) =
  let neighbours = get_dependent_formulas region_depth pos graph in
  let order = Mpos.add pos (build_node 0 formula neighbours Black) order in
  traversal (add_node region_depth graph) neighbours order

let build_order_from region_depth graph (pos, formula) : order =
  build_order_from_ region_depth graph (pos, formula) empty_order

let build_order_from_all region_depth graph (formulas : (pos * is_formula content) list) =
  let rec build_acc order = function
    | [] -> order
    | (pos, formula) :: xs ->
      (match Mpos.find_opt pos order with
      | Some {color = Black; _} -> build_acc order xs
      | Some {color = White; _} ->
        failwith "FormulaOrder.build_order_from_all_from : WHAT ?"
      | None ->
        let order = build_order_from_ region_depth graph (pos, formula) order in
        build_acc order xs)
  in
  build_acc empty_order formulas

let is_computable label order =
  match Mpos.find_opt label order with
  | None -> failwith "FormulaOrder.is_computable: no node"
  | Some node -> node.nb_depend = 0

let get_non_computable_formulas (order : order) =
  let binding = Mpos.bindings order in
  List.fold_left
    (fun l (p, {nb_depend; _}) -> if nb_depend > 0 then p :: l else l)
    []
    binding

let get_computable_formulas order =
  let binding = Mpos.bindings order in
  List.fold_left
    (fun l (p, {nb_depend; content; _}) ->
      if nb_depend = 0 then (p, content) :: l else l )
    []
    binding

let remove_evaluated_formula pos order =
  List.fold_left
    (fun o p ->
       Mpos.remove p o)
    order
    pos

let update_neighbour pos_neigh _ (computable, order) =
  match Mpos.find_opt pos_neigh order with
  | None ->
    failwith "FormulaOrder.get_new_computable_pos : non-existing neighbour"
  | Some node ->
    let computable =
      if node.nb_depend = 1
      then (pos_neigh, node.content) :: computable
      else computable
    in
    computable, Mpos.add pos_neigh {node with nb_depend = node.nb_depend - 1} order

let get_new_computable_formulas_  order pos_evaluated =
  let neighbours =
    match Mpos.find_opt pos_evaluated order with
    | None -> failwith "FormulaOrder.get_new_computable_pos : no node"
    | Some node -> node.neighbours
  in
  let computable, order =
    Mpos.fold update_neighbour neighbours ([], order)
  in
  computable, Mpos.remove pos_evaluated order

let get_new_computable_formulas pos_evaluated order =
  List.fold_left
    (fun (acc, o) pos ->
       let l, no = get_new_computable_formulas_ o pos in
       l@acc, no
    )
    ([], order)
    pos_evaluated


let print_order order =
  let bind = Mpos.bindings order in
  List.iter
    (fun (pos, {nb_depend; neighbours; color; _}) ->
      print_string
        ( "pos = "
        ^ string_of_pos pos
        ^ "   nb_depend = "
        ^ string_of_int nb_depend
        ^ "   color = "
        ^ (match color with White -> "White" | Black -> "Black")
        ^ "   neighbours = ") ;
      print_endline "";
      (Mpos.iter (fun pos formula ->
           let str =
             "     pos = "
             ^ (string_of_pos pos)
             ^ "  f = "
             ^ (string_of_content formula)
           in
           print_endline str)
          neighbours );
      print_endline "" )
    bind;
  print_endline ""
