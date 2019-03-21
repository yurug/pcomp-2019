let print_execution_time t0 tprep teval tuser =
  Format.eprintf "Global execution time (real): @.";
  Format.eprintf "  Preprocessing : %f s @." (tprep -. t0);
  Format.eprintf "  Fist  Eval    : %f s @." (teval -. tprep);
  Format.eprintf "  User changes  : %f s @." (tuser -. teval);
  Format.eprintf "Total         : %f s @." (tuser -. t0)

let parse_input argv =
  if Array.length argv = 5
  then argv.(1), argv.(2), argv.(3), argv.(4), false
  else if Array.length argv = 6
  then argv.(1), argv.(2), argv.(3), argv.(4), argv.(5) = "--verbose"
  else (
    prerr_endline "Usage: ws <data.csv> <user.txt> <view0.csv> <changes.txt>";
    exit 1 )

let main () =
  let data_filename, user_filename, view0_filename, change_filename, _ =
    parse_input Sys.argv in
  Format.printf "%s@." data_filename;
  let max_nb_regions = 1000 in
  let min_region_size = 25 in (* line nb *)
  let t0 = Unix.gettimeofday () in
  let f, regions, g = Spreadsheet.preprocessing data_filename min_region_size max_nb_regions in
  let t1 = Unix.gettimeofday () in
  let _ = Spreadsheet.first_evaluation regions f g in
  let _ =  Partitioner.recombine_regions view0_filename regions in
  let t2 = Unix.gettimeofday () in
  let _ = Partitioner.free_all regions in
  let t3 = Unix.gettimeofday () in
  (*let _ = Spreadsheet.eval_changes regions user_filename change_filename g in*)
  print_execution_time t0 t1 t2 t3


let () = main ()
