open Ast

type color =
  | White
  | Black

type node =
  { nb_depend : int
  ; neighbours : Graph.neighbours
  ; color : color }

type gdepend = node Mpos.t

let empty_gdepend = Mpos.empty

exception Cycle

let build_node nb_depend neighbours color = {nb_depend; neighbours; color}

let build_dependency_from (g : Graph.t) (label : Graph.nodeLabel) : gdepend =
  let neigh =
    try Graph.get_neighbours label g with Graph.NonExistingNode ->
      failwith "Dependency.build_dependency_from : Non existing first node."
  in
  let gdepend = Mpos.add label (build_node 0 neigh Black) empty_gdepend in
  let rec build label gdepend =
    let node_opt = Mpos.find_opt label gdepend in
    let prev_color, node =
      match node_opt with
      | None ->
        let neigh = Graph.get_neighbours label g in
        White, build_node 1 neigh Black
      | Some ({color; _} as node) ->
        color, {node with nb_depend = node.nb_depend + 1; color = Black}
    in
    let gdepend = Mpos.add label node gdepend in
    match prev_color with
    | Black -> gdepend
    | White -> traversal gdepend node.neighbours
  and traversal gdepend neigh = Graph.fold_neighbours build neigh gdepend in
  traversal gdepend neigh

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
