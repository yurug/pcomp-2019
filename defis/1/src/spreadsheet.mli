

module Make : functor (D:Data.DATA) -> sig 
  type data

  (* data.csv to tab *)
  val parse_data : string -> data

  (* print files view0.csv, changes.txt, tab *)
  val output : string -> string -> data -> unit

  (* incremential action applied to the tab *)
  val update : Ast.action -> data -> data
end
