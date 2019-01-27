module Make (D : Data.DATA) : sig
  type data

  (** [parse_data data.csv] parses the original data and returns the
     spreadsheet. *)
  val parse_data : string -> data * (Ast.pos * Graph.node_content) list

  (** [output tab view0.csv] write the contents of [tab]
      in the file [view0.csv], the file is created if it does not exist *)
  val output : data -> string -> unit

  (* incremential action applied to the tab, given a dependency graph *)
  val update : data -> Graph.t -> Ast.action -> data

  (* evaluation of one cell *)
  val eval : data -> Graph.t -> Ast.content -> Ast.value
end
