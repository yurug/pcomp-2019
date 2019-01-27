open Ast

type color =
  | White
  | Black

type node =
  { nb_depend : int
  ; neighbours : Graph.neighbours
  ; content : Graph.node_content
  ; color : color }

type gdepend = node Mpos.t

let empty_gdepend = Mpos.empty

exception Cycle

let build_node nb_depend content neighbours color = {nb_depend; content ; neighbours; color}

let build_dependency_from (g : Graph.t) (label : Graph.nodeLabel) : gdepend =
  let neigh, content =
    try Graph.get_neighbours_content label g with Graph.NonExistingNode ->
      failwith "Dependency.build_dependency_from : Non existing first node."
  in
  let gdepend = Mpos.add label (build_node 0 content neigh Black) empty_gdepend in
  let rec build label gdepend =
    let node_opt = Mpos.find_opt label gdepend in
    let prev_color, node =
      match node_opt with
      | None ->
        let neigh, content = Graph.get_neighbours_content label g in
        White, build_node 1 content neigh Black
      | Some ({color; _} as node) ->
        color, {node with nb_depend = node.nb_depend + 1; color = Black}
    in
    let gdepend = Mpos.add label node gdepend in
    match prev_color with
    | Black -> gdepend
    | White -> traversal gdepend node.neighbours
  and traversal gdepend neigh = Graph.fold_neighbours build neigh gdepend in
  traversal gdepend neigh

let is_computable pos gdepend =
  match Mpos.find_opt pos gdepend with
  | None -> failwith "Dependency.is_computable: no node"
  | Some node -> node.nb_depend = 0

let get_non_computable_nodes gdepend =
  let binding = Mpos.bindings gdepend in
  List.fold_left (fun l (p, _) -> p::l ) [] binding

let remove_computed_node pos gdepend =
    Mpos.remove pos gdepend

let get_new_computable_nodes pos_computed gdepend =
  match Mpos.find_opt pos_computed gdepend with
  | None -> failwith "Dependency.get_new_computable_pos : no node"
  | Some node ->
    let computable, gdepend =
      Graph.fold_neighbours
      (fun pos (neigh, d) ->
         match Mpos.find_opt pos d with
         | None -> failwith "Dependency.get_new_computable_pos : non-existing neighbour"
         | Some node ->
           let neigh = if node.nb_depend = 1 then (node.content, pos) :: neigh else neigh in
           neigh, Mpos.add pos {node with nb_depend=node.nb_depend-1} d
      )
      node.neighbours
      ([], gdepend)
    in
    computable, Mpos.remove pos_computed gdepend



let print_dependency gdepend =
  let bind = Mpos.bindings gdepend in
  List.iter
    (fun (pos, {nb_depend; neighbours; color}) ->
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
