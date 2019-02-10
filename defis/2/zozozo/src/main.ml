
let print_execution_time t0 tcut tgraph teval =
  Format.eprintf "Global execution time (real): @.";
  Format.eprintf "  Cut         : %f s @." (tcut -. t0);
  Format.eprintf "  Graph init  : %f s @." (tgraph -. tcut);
  Format.eprintf "  First eval  : %f s @." (teval -. tgraph);
  Format.eprintf "Total         : %f s @." (teval -. t0)

let parse_input argv =
  if Array.length argv = 5
  then argv.(1), argv.(2), argv.(3), argv.(4), false
  else if Array.length argv = 6
  then argv.(1), argv.(2), argv.(3), argv.(4), argv.(5) = "--verbose"
  else (
    prerr_endline "Usage: ws <data.csv> <user.txt> <view0.csv> <changes.txt>";
    exit 1 )

let main () =
  let data_filename, _, _, _, _ =
    parse_input Sys.argv in
  let dr = 100 in
  let t0 = Unix.gettimeofday () in
  let () = Master.cut_file_into_region data_filename dr in
  let t1 = Unix.gettimeofday () in
  let f, g = Master.build_graph data_filename dr in
  let t2 = Unix.gettimeofday () in
  let _ = Master.first_evaluation data_filename dr f g in
  let t3 = Unix.gettimeofday () in
  print_execution_time t0 t1 t2 t3

 (* Graph.print_graph g ;
  print_endline " ************************* ";
    FormulaOrder.print_order o;*)




let () = main ()
