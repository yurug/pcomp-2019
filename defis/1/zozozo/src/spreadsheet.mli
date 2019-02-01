module Make (D : Data.DATA) : sig
  type data

  (** [init data.csv] parses the original data and returns the
     spreadsheet. *)
  val init : string -> data * (Ast.pos * Graph.node_content) list

  (** [build_graph formulas] creates a dependency graph from a list of
     [formulas]. *)
  val build_graph : (Ast.pos * Graph.node_content) list -> Graph.t

  (** [parse_action line] creates a user action from [line], an user
     supplied action string. *)
  val parse_action : string -> Ast.action

  (** [output data view0.csv] write the contents of [data]
      in the file [view0.csv], the file is created if it does not exist *)
  val output : data -> string -> unit

  val output_changes :
    (string * (Graph.nodeLabel * Ast.value) list) list -> string -> unit

  (** [update data graph action] applies the action [action] to [data]
     and updates [graph] accordingly.*)
  val update :
       data
    -> Graph.t
    -> Ast.action
    -> data * Graph.t * (Graph.nodeLabel * Ast.value) list

  (** [eval_init data graph formulas] evaluates the formulas in
      [formulas] is possible et updates [data] accordingly. *)
  val eval_init :
    data -> Graph.t -> (Ast.pos * Graph.node_content) list -> data
end
