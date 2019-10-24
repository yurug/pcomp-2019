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

let data, formulas =
  D.init "/home/pierre/ProgCOmp/pcomp-2019/defis/1/zozozo/tests/1/data.csv"

let value = D.get (Ast.pos 0 0) data
let value = D.get (Ast.pos 2 1) data
let value = D.get (Ast.pos 2 0) data
let value = D.get (Ast.pos 1 1) data
let data' = D.set (Ast.pos 1 1) (Ast.create_cell (Int 1)) data
let value_new = D.get (Ast.pos 1 1) data'

(*value_new = 1*)
let value_old = D.get (Ast.pos 1 1) data

(*value_old = 4*)

(*Les deux fichiers doivent être identique car ça affiche le tableau initiale*)
let () = D.output_init data "view_test.csv"
let () = D.output_init data' "view_test2.csv"

(*Test set_rect*)
let data_set_rect =
  D.set_rect (Ast.pos 0 0, Ast.pos 1 1) (Ast.create_cell (Int 32)) data

let value_0_0 = D.get (Ast.pos 0 0) data_set_rect

(*value_0_0 = 32*)
let value_0_1 = D.get (Ast.pos 0 1) data_set_rect

(*value_0_1 = 32*)
let value_1_0 = D.get (Ast.pos 1 0) data_set_rect

(*value_1_0 = 32*)
let value_1_1 = D.get (Ast.pos 1 1) data_set_rect

(*value_1_1 = 32*)
let value_2_0 = D.get (Ast.pos 2 0) data_set_rect

(*value_2_0 = 5*)
let value_2_1 = D.get (Ast.pos 2 1) data_set_rect

(*value_2_1 = Undefined*)

let value_old_0_0 = D.get (Ast.pos 0 0) data

(*value_old_0_0 = 1*)
let value_old_0_1 = D.get (Ast.pos 0 1) data

(*value_old_0_1 = 2*)
let value_old_1_0 = D.get (Ast.pos 1 0) data

(*value_old_1_0 = 3*)
let value_old_1_1 = D.get (Ast.pos 1 1) data

(*value_old_1_1 = 4*)
let value_old_2_0 = D.get (Ast.pos 2 0) data

(*value_old_2_0 = 5*)
let value_old_2_1 = D.get (Ast.pos 2 1) data

(*value_old_2_1 = Undefined*)

(*Test fold_rect*)
let sum =
  D.fold_rect
    (fun sum {value = v} -> match v with Int i -> i + sum | _ -> sum)
    0
    (Ast.pos 0 0, Ast.pos 2 1)
    data

(*sum = 15*)

let data_fold_recti =
  D.fold_recti
    (fun data pos {value = v} ->
      match v with
      | Int i -> D.set pos (Ast.create_cell (Int (i + 1))) data
      | _ -> data )
    data
    (Ast.pos 0 0, Ast.pos 2 1)
    data

(*sum = 15*)

let value_0_0 = D.get (Ast.pos 0 0) data_fold_recti

(*value_0_0 = 2*)
let value_0_1 = D.get (Ast.pos 0 1) data_fold_recti

(*value_0_1 = 3*)
let value_1_0 = D.get (Ast.pos 1 0) data_fold_recti

(*value_1_0 = 4*)
let value_1_1 = D.get (Ast.pos 1 1) data_fold_recti

(*value_1_1 = 5*)
let value_2_0 = D.get (Ast.pos 2 0) data_fold_recti

(*value_2_0 = 6*)
let value_2_1 = D.get (Ast.pos 2 1) data_fold_recti

(*value_2_1 = Undefined*)

(* Test map_rect *)
let data_map_rect =
  D.map_rect
    (fun ({value = v} as c) ->
      match v with Int i -> Ast.create_cell (Int (i + 1)) | _ -> c )
    (Ast.pos 0 0, Ast.pos 2 1)
    data

let value_0_0 = D.get (Ast.pos 0 0) data_map_rect
let value_0_0 = D.get (Ast.pos 0 0) data

(*value_0_0 = 2*)
let value_0_1 = D.get (Ast.pos 0 1) data_map_rect

(*value_0_1 = 3*)
let value_1_0 = D.get (Ast.pos 1 0) data_map_rect

(*value_1_0 = 4*)
let value_1_1 = D.get (Ast.pos 1 1) data_map_rect

(*value_1_1 = 5*)
let value_2_0 = D.get (Ast.pos 2 0) data_map_rect

(*value_2_0 = 6*)
let value_2_1 = D.get (Ast.pos 2 1) data_map_rect

(*value_2_1 = Undefined*)

let data_map_recti =
  D.map_recti
    (fun pos {value = v} ->
      match v with
      | Int i -> Ast.create_cell (Int (i + (pos.r + pos.c)))
      | _ -> Ast.create_cell (Int (pos.r + pos.c)) )
    (Ast.pos 0 0, Ast.pos 2 1)
    data

let value_0_0 = D.get (Ast.pos 0 0) data_map_recti
let value_0_0 = D.get (Ast.pos 0 0) data

(*value_0_0 = 2*)
let value_0_1 = D.get (Ast.pos 0 1) data_map_recti

(*value_0_1 = 3*)
let value_1_0 = D.get (Ast.pos 1 0) data_map_recti

(*value_1_0 = 4*)
let value_1_1 = D.get (Ast.pos 1 1) data_map_recti

(*value_1_1 = 5*)
let value_2_0 = D.get (Ast.pos 2 0) data_map_recti

(*value_2_0 = 6*)
let value_2_1 = D.get (Ast.pos 2 1) data_map_recti

(*value_2_1 = Undefined*)
