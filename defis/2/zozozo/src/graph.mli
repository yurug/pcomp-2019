open Ast


type t

type nodeLabel = int
type node

type neighbourLabel = pos
type neighbour = { formula : is_formula content;
                   subregion : pos*pos }
type neighbours = neighbour Mpos.t

type content = formulas

val empty_content : content
val empty_graph : t
val empty_neighbours : neighbours

exception ExistingNode of nodeLabel
exception NonExistingNode of nodeLabel

(** [build_node_no_neigh content] build a node with content [content] and no
   neighbour. *)
val build_node_no_neigh : content -> node

(** [build_node content neighbours] build a node with content
   [content] and neighbours [neighbours]. *)
val build_node : content ->  neighbours -> node

(** [add_node label node g] adds a new node [node] labelled [label] in
   [g] if no such node exists and raises [ExistingNode] else. *)
val add_node : nodeLabel -> node -> t -> t

(** [add_neighbour label_node label_neighbour new_neighbour g] *)
val add_neighbour : nodeLabel -> neighbourLabel -> neighbour -> t -> t
val change_neighbours : nodeLabel -> neighbours -> t -> t
val change_content : nodeLabel -> content -> t -> t

(** [get_neighbours label g] returns the neighbours of node labelled
   [label] in graph [g] or raises [NonExistingNode]. *)
val get_neighbours : nodeLabel -> t -> neighbours
val get_content : nodeLabel -> t -> content
val get_neighbours_content : nodeLabel -> t -> content * neighbours

(** [fold_neighbours f neighbours init] *)
val fold_neighbours : (neighbourLabel -> neighbour -> 'a -> 'a) -> neighbours -> 'a -> 'a

val print_graph : t -> unit
