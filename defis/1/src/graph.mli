open Ast

type neighbours
type nodeLabel = pos
type node_content = content
type node
type t

val empty : t
val empty_neighbours : neighbours

exception ExistingNode
exception NonExistingNode

(** [build_node content] build a node with content [content] and no
   neighbour. *)
val build_node : node_content -> node

(** [add_node g label node] adds the node [node] with the label
   [label] to the graph [g]. If the added node if a formula, adds also
   the corresponding dependencies.Fails if [node] is already a
   non-[Undefined] value *)
val add_node : t -> nodeLabel -> node -> t

(** [change_node g label node] *)
val change_node : t -> nodeLabel -> node -> t

(** [add_neighbour g label neigh] either adds a node with label
   [neigh], content [Undefined] and a neighbour [label] if no such
   node exists or adds a neighbour [label] to the node [neigh] *)
val add_neighbour : t -> nodeLabel -> nodeLabel -> t

(** [add_neighbours g region edge] adds a edge [edge] to
   each node in the region [region] *)
val add_neighbours : t -> nodeLabel * nodeLabel -> nodeLabel -> t

(** [get_neighbours g label] returns the neighbours of node labelled
   [label] in graph [g] or raises [NonExistingNode]. *)
val get_neighbours : t -> nodeLabel -> neighbours

val fold_neighbours : (nodeLabel -> 'a -> 'a) -> neighbours -> 'a -> 'a
val print_neighbours : neighbours -> unit
val print_graph : t -> unit
(*val del_node : t -> nodeLabel ->  t*)
