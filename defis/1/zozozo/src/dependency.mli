type gdepend

exception Cycle

val build_dependency_from : Graph.t -> Graph.nodeLabel -> gdepend

val build_dependency_from_all :
  Graph.t -> (Graph.nodeLabel * Ast.content) list -> gdepend

val print_dependency : gdepend -> unit
val is_computable : Ast.pos -> gdepend -> bool
val get_non_computable_nodes : gdepend -> Graph.nodeLabel list
val get_computable_nodes : gdepend -> (Ast.content * Graph.nodeLabel) list
val remove_computed_node : Ast.pos -> gdepend -> gdepend

val get_new_computable_nodes :
  Ast.pos -> gdepend -> (Graph.node_content * Graph.nodeLabel) list * gdepend
