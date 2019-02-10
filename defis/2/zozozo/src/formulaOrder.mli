(** This module is used to defined a relation order (let's write it
   >>) between non-evaluated formulas.

   f1 >> f2 means f1 must be evaluated in order to evaluate f2.

   f1 >> f2 >> f1 is a typical cycle.

   f1 >> f2 ∧ f1 >> f3 means evaluating f1 is required to evaluate f2
   and f3.

    >> is only transitive.

    Once the order is defined (either from one specific position using
   [build_formulas_order_from] or from a list of formulas using
   [build_formulas_order_from_all], one can :

    - access the computable formulas, i.e. the formulas with no
   relation *going to it* on the previously defined order (f1 is
   computable if there exists no f2 such as f2 >> f1).

    - once a formula as been evaluated, remove it from the order to
   free and get the newly computable formulas.

    - and keep going recursively until every computable formulas have
   been evaluated. At this point, the only formulas still in the order
   are necessary involved in a local cycle and so non-computable. They
   then can be extracted to set their value to [Undefined].
   *)
open Ast

type order

(** [build_order_from g label] builds the relation order from the node
   labelled [label] in the graph [g].  *)
val build_order_from : int -> Graph.t -> (pos * is_formula content) -> order

(** [build_order_from_all g formulas] builds the relation order which
   links every formulas in [formulas] using the graph [g]. *)
val build_order_from_all :
  int -> Graph.t -> (pos* is_formula content) list -> order


(** [is_computable label order] returns true if the formula labelled
   [label] is computable. Returns false else. *)
val is_computable : pos-> order -> bool

(** [get_new_computable_formulas label order] returns the formulas
   that become computable once the formula labelled [label] as been
   evaluated and update [order] accordingly. *)
val get_new_computable_formulas :
  pos list -> order -> (pos * is_formula content) list * order

(** [get_computable_formulas order] returns the computable formulas in
   [order]. *)
val get_computable_formulas : order -> (pos * is_formula content) list

(** [get_non_computable_formulas order] returns all the still
   non-computable formulas in order. To obtain the formulas involved
   in a cycle, every computable formulas must have been evaluated. *)
val get_non_computable_formulas : order -> pos list

(** [remove_evaluated_formula label order] *)
val remove_evaluated_formula : pos list -> order -> order


(** [print_order order] *)
val print_order : order -> unit
