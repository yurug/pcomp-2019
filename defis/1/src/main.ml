open Data

(* Chosen Data Representation *)
module D = DataArray

(* Corresponding Spreadsheet *)
module Sp = Spreadsheet.Make (D)

let main () =
  if Array.length Sys.argv <> 5
  then (
    prerr_endline "Usage: ws <data.csv> <user.txt> <view0.csv> <changes.txt>";
    exit 1 );

  let data_filename, user_filename, view0_filename, changes_filename =
    Sys.argv.(1), Sys.argv.(2), Sys.argv.(3), Sys.argv.(4)
  in
  let _ = Format.eprintf "%s %s %s %s@."
      data_filename user_filename view0_filename changes_filename in
  (* Initialisation *)
  let data, formulas = Sp.parse_data data_filename in
  let graph = Sp.build_graph formulas in
  let data = Sp.eval_init data graph formulas in
  let () = Sp.output data view0_filename in

  (* Loop user *)
  let user = open_in user_filename in
  Sp.output data view0_filename;
  let rec loop data graph =
    let line = input_line user in
    let action = Sp.parse_action line in
    let data, graph, changes = Sp.update data graph action in
    loop data graph
  in
  try loop data graph with End_of_file -> close_in user;
    (* for testing *)
    Sp.output data changes_filename


let () = main ()
