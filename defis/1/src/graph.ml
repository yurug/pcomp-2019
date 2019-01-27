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

let add_neighbours g region label =
  let s = region_to_set region in
  Spos.fold (fun neigh g -> add_neighbour g label neigh) s g

let add_neighbours_ g label {content; _} =
  match content with
  | Val _ -> g
  | Occ (region, _) -> add_neighbours g region label

let get_neighbours g label =
  let node_opt = Mpos.find_opt label g in
  match node_opt with
  | None -> raise NonExistingNode
  | Some node -> node.neighbours

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
      Mpos.add
        label
        { content
        ; neighbours = neighbours @@ remove_neighbours label old_neighbours }
        g
  in
  add_neighbours_ g label node

let print_neighbours neigh =
  Spos.iter
    (fun pos ->
      let s = string_of_pos pos in
      print_string (s ^ " ; ") )
    neigh;
  print_endline ""

let print_graph g =
  let bind = Mpos.bindings g in
  List.iter
    (fun (pos, {content; neighbours}) ->
      let cs = string_of_content content in
      print_string
        ( "pos = "
        ^ string_of_pos pos
        ^ "   content = "
        ^ cs
        ^ "   neighbours = " );
      print_neighbours neighbours )
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
