module Make (D : Data.DATA) : sig
  type data

  (* data.csv to tab *)
  val parse_data : string -> data

  (* print files view0.csv, changes.txt, tab *)
  val output : data -> string -> string -> unit

  (* incremential action applied to the tab *)
  val update : data -> Ast.action -> data

  (* evaluation of one case*)
  val eval : data -> Ast.pos -> data
end
