
(* Exemple : test de quelques fonctions du module Graph  *)
open Ast
open Master

module D = Data.DataArray

let file = "../tests/5/data.csv"

(* region_depth *)
let dr = 5
let () = Master.cut_file_into_region file dr
let f, g = Master.build_graph file dr
let _ = Graph.print_graph g
(*let o = build_order_from_all dr g f
let _ = print_order o*)

let _ = Master.first_evaluation file dr f g

let file0 = "../tests/5/data_0.csv"
let data = D.init file0;;
let data = D.set (build_pos 2 1) (create_cell (Int 1)) data;;
let _ = D.output_init data file0 ;;
let data = D.init file0;;
let data = D.set (build_pos 0 1) (create_cell (Int 2)) data;;
let _ = D.output_init data file0 ;;
let data = D.init file0;;
let _ = D.output_init data file0 ;;
