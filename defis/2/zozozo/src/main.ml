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
  let data_filename, user_filename, _, change_filename, _ =
    parse_input Sys.argv in
  Format.printf "%s@." data_filename;
  let max_file_size = 100 in
  let t0 = Unix.gettimeofday () in
  let regions = Partitioner.cut_file_into_regions data_filename max_file_size in
  let t1 = Unix.gettimeofday () in
  let f, g = Spreadsheet.build_graph data_filename regions in
  let t2 = Unix.gettimeofday () in
  let _ = Spreadsheet.first_evaluation regions f g in
  let t3 = Unix.gettimeofday () in
  let _ = Spreadsheet.eval_changes regions user_filename change_filename g in
  print_execution_time t0 t1 t2 t3


let () = main ()
