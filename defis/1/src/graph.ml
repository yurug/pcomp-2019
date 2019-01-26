open Ast

exception ExistingNode
exception NonExistingNode

(* Label *)
type nodeLabel = pos

let region_to_set ({r = rmin; c = cmin}, {r = rmax; c = cmax}) =
  let rec add_one_row s pos =
    if pos.c > cmax
    then s
    else
      let s = Spos.add pos s in
      add_one_row s {pos with c = pos.c + 1}
  in
  let rec row_by_row s r =
    if r > rmax
    then s
    else
      let s = add_one_row s {r; c = cmin} in
      row_by_row s (r + 1)
  in
  row_by_row Spos.empty rmin

(* Neighbours *)
type neighbours = Spos.t

let empty_neighbours = Spos.empty
let union_neighbours = Spos.union
let cons_neighbour = Spos.add
let fold_neighbours = Spos.fold
let remove_neighbours = Spos.remove
let ( @@ ) = union_neighbours
let ( ++ ) = cons_neighbour

(* Node *)
type node_content = content

type node =
  { content : node_content
  ; neighbours : neighbours }

let build_node content = {content; neighbours = empty_neighbours}

(* Graph *)
type t = node Mpos.t

let empty = Mpos.empty

(* Functions *)

(** [add_neighbour g label neigh] either adds a node with label
   [neigh], content [Undefined] and a neighbour [label] if no such
   node exists or adds a neighbour [label] to the node [neigh] *)
let add_neighbour g label new_neighbour =
  let node_opt = Mpos.find_opt new_neighbour g in
  match node_opt with
  | None ->
    Mpos.add
      new_neighbour
      {content = Val Undefined; neighbours = label ++ empty_neighbours}
      g
  | Some {content; neighbours} ->
    Mpos.add new_neighbour {content; neighbours = label ++ neighbours} g

(** [add_neighbours g region edge] adds a edge [edge] to
   each node in the region [region] *)
let add_neighbours g region label =
  let s = region_to_set region in
  Spos.fold (fun neigh g -> add_neighbour g label neigh) s g

let add_neighbours_ g label {content; _} =
  match content with
  | Val _ -> g
  | Occ (region, _) -> add_neighbours g region label

(** [get_neighbours g label] returns the neighbours of node labelled
   [label] in graph [g] or raises [NonExistingNode]. *)
let get_neighbours g label =
  let node_opt = Mpos.find_opt label g in
  match node_opt with
  | None -> raise NonExistingNode
  | Some node -> node.neighbours

(** [add_node g label node] adds the node [node] with the label
   [label] to the graph [g]. If the added node if a formula, adds also
   the corresponding dependencies.Fails if [node] is already a
   non-[Undefined] value *)
let add_node g label ({content; neighbours} as node) =
  let existing_node_opt = Mpos.find_opt label g in
  let g =
    match existing_node_opt with
    | None -> Mpos.add label node g
    | Some {content = Val Undefined; neighbours = old_neighbours} ->
      Mpos.add label {content; neighbours = neighbours @@ old_neighbours} g
    | _ -> failwith "Graph.add_node : Ajout sur un noeud existant"
  in
  add_neighbours_ g label node

(** *)
let change_node g label ({content; neighbours} as node) =
  let existing_node_opt = Mpos.find_opt label g in
  let g =
    match existing_node_opt with
    | None -> Mpos.add label node g
    | Some {content = Val _; neighbours = old_neighbours} ->
      Mpos.add label {content; neighbours = neighbours @@ old_neighbours} g
    | Some {content = Occ (region, _); neighbours = old_neighbours} ->
      (* Aller voir tous les noeuds dans [region] et retirer dependance à label*)
      let g =
        fold_neighbours
          (fun lab gg ->
            match Mpos.find_opt lab gg with
            | None ->
              failwith
                "Graph.change_node : Non dependencies when we should have one."
            | Some nl ->
              let new_neigh = remove_neighbours label nl.neighbours in
              if new_neigh = empty_neighbours
              then
                match nl.content with
                | Val _ -> Mpos.remove lab gg
                | _ -> Mpos.add lab {nl with neighbours = new_neigh} gg
              else Mpos.add lab {nl with neighbours = new_neigh} gg )
          (region_to_set region)
          g
      in
      Mpos.add label {content; neighbours = neighbours @@ old_neighbours} g
  in
  add_neighbours_ g label node

let value_to_string value =
  match value with
  | Undefined -> "Undefined"
  | Int n -> "Int " ^ string_of_int n

let pos_to_string {r; c} = "(" ^ string_of_int r ^ "," ^ string_of_int c ^ ")"

let content_to_string content =
  match content with
  | Val v -> value_to_string v
  | Occ ((p1, p2), v) ->
    "Occ ("
    ^ pos_to_string p1
    ^ ", "
    ^ pos_to_string p2
    ^ "), "
    ^ value_to_string v

let print g =
  let bind = Mpos.bindings g in
  List.iter
    (fun (pos, {content; neighbours}) ->
      let cs = content_to_string content in
      print_string
        ( "pos = "
        ^ pos_to_string pos
        ^ "   content = "
        ^ cs
        ^ "   neighbours = " );
      Spos.iter
        (fun pos ->
          let s = pos_to_string pos in
          print_string (s ^ " ; ") )
        neighbours;
      print_endline "" )
    bind;
  print_endline ""

(* [del_node g label] devrait sortir les cases à recalculer *)
(*let del_node g label =
  if M.mem label g then
    match M.find label g with
    | CstN {edges;_} ->
    | FormulaN {content;_} ->
  else
    raise NonExistingNode*)
