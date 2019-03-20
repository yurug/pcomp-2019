open Ast
open Printer

(* Label *)
type nodeLabel = int

(* Neighbours *)
type neighbourLabel = pos
type neighbour = { formula : is_formula content;
                   subregion : pos*pos }



type neighbours = neighbour Mpos.t

let empty_neighbours = Mpos.empty
let cons_neighbour = Mpos.add
let singleton_neighbour pos x = cons_neighbour pos x empty_neighbours
(*let union_neighbours = Spos.union
let cons_neighbour = Spos.add
let fold_neighbours = Spos.fold
let remove_neighbours = Spos.remove
let ( @@ ) = union_neighbours
  let ( ++ ) = cons_neighbour*)

(* Content *)
type content = formulas
let empty_content = empty_formulas

(* Node *)
type node =
  {
    content : content ; (* dans une région on a des formules *)
    neighbours : neighbours (* formules dépendantes de cette région *)
  }

let build_node_no_neigh content =
  {content; neighbours = empty_neighbours}

let build_node content neighbours =
  {content; neighbours}

(* Graph *)
type t = node Mint.t

let empty_graph = Mint.empty

(* Exception *)
exception ExistingNode of nodeLabel
exception NonExistingNode of nodeLabel

(* Functions *)
(** [add_node label node g] adds a new node [node] labelled [label] in
   [g]. *)
let add_node label node g =
  match Mint.find_opt label g with
  | Some _ -> raise (ExistingNode label)
  | None ->
    Mint.add label node g

(** [add_neighbour label_node label_neighbour new_neighbour g] *)
let add_neighbour label_node label_neighbour new_neighbour g =
  match Mint.find_opt label_node g with
  | Some node ->
    let new_node = {node with
                    neighbours =
                      cons_neighbour label_neighbour new_neighbour node.neighbours } in
    Mint.add label_node new_node g
  | None ->
    let new_node =
      build_node empty_content (singleton_neighbour label_neighbour new_neighbour) in
    Mint.add label_node new_node g

let change_neighbours label_node neighbours g =
  match Mint.find_opt label_node g with
  | Some node ->
    let new_node = {node with
                    neighbours = neighbours} in
    Mint.add label_node new_node g
  | None ->
    let new_node = build_node empty_content neighbours in
    Mint.add label_node new_node g

let change_content label_node content g =
  let new_node =
    match Mint.find_opt label_node g with
    | Some node ->
       {node with content = content}
    | None ->
       build_node content empty_neighbours in
  Mint.add label_node new_node g

let get_neighbours label (graph:t) =
  match Mint.find_opt label graph with
  | None -> raise (NonExistingNode label)
  | Some n -> n.neighbours

let get_content label graph =
  match Mint.find_opt label graph with
  | None -> raise (NonExistingNode label)
  | Some n -> n.content

let get_neighbours_content label graph =
  match Mint.find_opt label graph with
  | None -> raise (NonExistingNode label)
  | Some n -> n.content, n.neighbours

let fold_neighbours f (neighbours:neighbours) =
  Mpos.fold f neighbours


let print_graph graph =
  Mint.iter
    (fun i r ->
       Format.printf "Region : %d@." i;
       Format.printf "  In : @.";
       Mpos.iter
         (fun pos formula ->
            Format.printf "  %s at pos %s with value %s@."
              (string_of_content formula.fin)
              (string_of_pos pos)
              (string_of_value formula.eval))
       r.content;
       Format.printf "  Neigh : @.";
       Mpos.iter
         (fun pos n ->
            Format.printf " %s (at %s) limited to (%s, %s) @."
              (string_of_content n.formula)
              (string_of_pos pos)
              (string_of_pos (fst n.subregion)) (string_of_pos (snd n.subregion)))
         r.neighbours;
       Format.printf "@."
    )
    graph
