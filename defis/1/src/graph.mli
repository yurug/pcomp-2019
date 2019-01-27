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

(** [add_node label node g] adds the node [node] with the label
   [label] to the graph [g]. If the added node if a formula, adds also
   the corresponding dependencies.Fails if [node] is already a
   non-[Undefined] value *)
val add_node : nodeLabel -> node -> t -> t

(** [change_node label node g] *)
val change_node : nodeLabel -> node -> t -> t

(** [add_neighbour label neigh g] either adds a node with label
   [neigh], content [Undefined] and a neighbour [label] if no such
   node exists or adds a neighbour [label] to the node [neigh] *)
val add_neighbour : nodeLabel -> nodeLabel -> t -> t

(** [add_neighbours region edge g] adds a edge [edge] to
   each node in the region [region] *)
val add_neighbours : nodeLabel * nodeLabel -> nodeLabel -> t -> t

(** [get_neighbours label g] returns the neighbours of node labelled
   [label] in graph [g] or raises [NonExistingNode]. *)
val get_neighbours : nodeLabel -> t -> neighbours

val get_neighbours_content : nodeLabel -> t -> neighbours*node_content

val fold_neighbours : (nodeLabel -> 'a -> 'a) -> neighbours -> 'a -> 'a
val print_neighbours : neighbours -> unit
val print_graph : t -> unit
(*val del_node : t -> nodeLabel ->  t*)
