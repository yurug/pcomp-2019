open Data

(* Chosen Data Representation *)
module D = DataArray

(* Corresponding Spreadsheet *)
module Sp = Spreadsheet.Make (D)

let parse_input argv =
  if Array.length argv = 5
  then argv.(1), argv.(2), argv.(3), argv.(4), false
  else if Array.length argv = 6
  then argv.(1), argv.(2), argv.(3), argv.(4), argv.(5) = "--verbose"
  else (
    prerr_endline "Usage: ws <data.csv> <user.txt> <view0.csv> <changes.txt>";
    exit 1 )

(*
  let _ = Format.eprintf "%s %s %s %s@."
      data_filename user_filename view0_filename changes_filename in
  data_filename, user_filename, view0_filename, changes_filename*)

let print_execution_time t0 tinit tprintv0 tuser =
  Format.eprintf "Global execution time (real): @.";
  Format.eprintf "  Initialisation : %f s @." (tinit -. t0);
  Format.eprintf "  Print view0    : %f s @." (tprintv0 -. tinit);
  Format.eprintf "  Loop changes   : %f s @." (tuser -. tprintv0);
  Format.eprintf "Total            : %f s @." (tuser -. t0)

let print_initialisation_time t0 tinit tgraph teval =
  Format.eprintf "Initialisation execution time (real): @.";
  Format.eprintf "  Data init  : %f s @." (tinit -. t0);
  Format.eprintf "  Graph init : %f s @." (tgraph -. tinit);
  Format.eprintf "  First eval : %f s @." (teval -. tgraph);
  Format.eprintf "Total        : %f s \n @." (teval -. t0)

let pre_evaluation data graph formulas = Sp.eval_init data graph formulas

let initialisation data_filename ~verbose =
  let t0 = Unix.gettimeofday () in
  let data, formulas = Sp.init data_filename in
  let t1 = Unix.gettimeofday () in
  let graph = Sp.build_graph formulas in
  let t2 = Unix.gettimeofday () in
  let data = pre_evaluation data graph formulas in
  let t3 = Unix.gettimeofday () in
  if verbose then print_initialisation_time t0 t1 t2 t3;
  data, graph, formulas

let write_view0 view0_filename data = Sp.output data view0_filename

let write_final_result view0_filename data (* debug function *) =
  let ll = String.split_on_char '/' view0_filename in
  match List.rev ll with
  | [] -> ()
  | _ :: dir ->
    let dir = List.rev dir in
    let view_final_filename = String.concat "/" dir ^ "/" ^ "view_final.csv" in
    Sp.output data view_final_filename

let get_action user_file =
  let line = String.trim (input_line user_file) in
  Sp.parse_action line, line

let loop_user user_filename changes_filename data graph =
  let user_file = open_in user_filename in
  let rec loop data graph all_changes =
    match get_action user_file with
    | act, act_str ->
      let data, graph, changes = Sp.update data graph act in
      loop data graph ((act_str, changes) :: all_changes)
    | exception End_of_file ->
      close_in user_file;
      List.rev all_changes, data
  in
  let all_changes, data = loop data graph [] in
  Sp.output_changes all_changes changes_filename;
  data

let main () =
  let data_filename, user_filename, view0_filename, changes_filename, verbose =
    parse_input Sys.argv
  in
  let t0 = Unix.gettimeofday () in
  let data, graph, _ = initialisation data_filename ~verbose in
  let t1 = Unix.gettimeofday () in
  write_view0 view0_filename data;
  let t2 = Unix.gettimeofday () in
  let data = loop_user user_filename changes_filename data graph in
  let t3 = Unix.gettimeofday () in
  if verbose then print_execution_time t0 t1 t2 t3;
  (* debug *)
  write_final_result view0_filename data

let () = main ()
