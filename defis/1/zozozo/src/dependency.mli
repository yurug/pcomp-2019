(** This module is used to defined a order relation (let's write it >>) between formulas.

    f1 >> f2 means f1 must be evaluated to evaluate f2.contents
    f1 >> f2 >> f1 is a typical cycle.
    f1 >> f2 ∧ f1 >> f3 means evaluating f1 is required to evaluate f2 and f3

    >> is only transitive.
    - not symetrical
    - not reflexive
    - not anti-symetrical...

*)

type gdepend

exception Cycle

val build_dependency_from : Graph.t -> Graph.nodeLabel -> gdepend

val build_dependency_from_all :
  Graph.t -> (Graph.nodeLabel * Ast.content) list -> gdepend

val is_computable : Ast.pos -> gdepend -> bool
val get_non_computable_nodes : gdepend -> Graph.nodeLabel list
val get_computable_nodes : gdepend -> (Ast.content * Graph.nodeLabel) list

val get_new_computable_nodes :
  Ast.pos -> gdepend -> (Graph.node_content * Graph.nodeLabel) list * gdepend

val remove_computed_node : Ast.pos -> gdepend -> gdepend
val print_dependency : gdepend -> unit
