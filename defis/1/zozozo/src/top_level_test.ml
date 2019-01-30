module D = Data.DataArray
module Sp = Spreadsheet.Make (D)

(* Exemple : test de quelques fonctions du module Graph  *)
open Graph

(* Incrémentalement *)
let graph = empty
let graph = add_node (Ast.pos 0 0) (build_node (Val (Int 1))) graph
let () = print_graph graph
let graph = add_node (Ast.pos 0 1) (build_node (Val (Int 2))) graph
let () = print_graph graph

let graph =
  add_node
    (Ast.pos 0 2)
    (build_node (Occ ((Ast.pos 0 0, Ast.pos 0 1), Int 1)))
    graph

let () = print_graph graph

(* En un bloc *)
let () =
  empty
  |> add_node (Ast.pos 0 0) (build_node (Val (Int 1)))
  |> add_node (Ast.pos 0 1) (build_node (Val (Int 2)))
  |> add_node
       (Ast.pos 0 2)
       (build_node (Occ ((Ast.pos 0 0, Ast.pos 0 1), Int 1)))
  |> print_graph
