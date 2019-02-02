open Ast

type color =
  | White
  | Black

type node =
  { nb_depend : int
  ; neighbours : Graph.neighbours
  ; content : Graph.node_content
  ; color : color }

type order = node Mpos.t
type formula_label = Ast.pos

let empty_order = Mpos.empty

let build_node nb_depend content neighbours color =
  {nb_depend; content; neighbours; color}

let rec traversal f neigh order = Graph.fold_neighbours f neigh order

and add_node graph label order =
  let node_opt = Mpos.find_opt label order in
  let prev_color, node =
    match node_opt with
    | None ->
      let neigh, content = Graph.get_neighbours_content label graph in
      White, build_node 1 content neigh Black
    | Some ({color; _} as node) ->
      color, {node with nb_depend = node.nb_depend + 1; color = Black}
  in
  let order = Mpos.add label node order in
  match prev_color with
  | Black -> order
  | White -> traversal (add_node graph) node.neighbours order

let build_order_from_ (g : Graph.t) (label : Graph.nodeLabel) (order : order) =
  let neigh, content =
    try Graph.get_neighbours_content label g with Graph.NonExistingNode ->
      failwith "FormulaOrder.build_order_from_ : Non existing first node."
  in
  let order = Mpos.add label (build_node 0 content neigh Black) order in
  traversal (add_node g) neigh order

let build_order_from (g : Graph.t) (label : Graph.nodeLabel) : order =
  build_order_from_ g label empty_order

let build_order_from_all (g : Graph.t) (formulas : (pos * Ast.content) list) =
  let rec build_acc order = function
    | [] -> order
    | (label, _) :: tail ->
      (match Mpos.find_opt label order with
      | Some {color = Black; _} -> build_acc order tail
      | Some {color = White; _} ->
        failwith "FormulaOrder.build_order_from_all_from : WHAT ?"
      | None ->
        let order = build_order_from_ g label order in
        build_acc order tail)
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
      if nb_depend = 0 then (content, p) :: l else l )
    []
    binding

let remove_computed_formula pos order = Mpos.remove pos order

let update_neighbour pos (computable, order) =
  match Mpos.find_opt pos order with
  | None ->
    failwith "FormulaOrder.get_new_computable_pos : non-existing neighbour"
  | Some node ->
    let computable =
      if node.nb_depend = 1
      then (node.content, pos) :: computable
      else computable
    in
    computable, Mpos.add pos {node with nb_depend = node.nb_depend - 1} order

let get_new_computable_formulas pos_computed order =
  let neighbours =
    match Mpos.find_opt pos_computed order with
    | None -> failwith "FormulaOrder.get_new_computable_pos : no node"
    | Some node -> node.neighbours
  in
  let computable, order =
    Graph.fold_neighbours update_neighbour neighbours ([], order)
  in
  computable, Mpos.remove pos_computed order

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
        ^ "   neighbours = " );
      Graph.print_neighbours neighbours;
      print_endline "" )
    bind;
  print_endline ""
