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

val build_node : node_content -> node

val add_node : t -> nodeLabel -> node -> t

val change_node : t -> nodeLabel -> node -> t

val add_neighbour : t -> nodeLabel -> nodeLabel -> t

val add_neighbours : t -> nodeLabel*nodeLabel -> nodeLabel -> t

val get_neighbours : t -> nodeLabel -> neighbours

val fold_neighbours : (nodeLabel -> 'a -> 'a ) -> neighbours -> 'a -> 'a

(*
val del_node : t -> nodeLabel ->  t*)
