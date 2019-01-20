open Data

(* Chosen Data Representation *)
module D = DataArray

(* Corresponding Spreadsheet *)
module Sp = Spreadsheet.Make (D)

let to_things data_filename _ _ _ : unit =
  let _ = Sp.parse_data data_filename in
  ()

let parse_args args = args.(1), args.(2), args.(3), args.(4)

let main () =
  if Array.length Sys.argv = 5
  then
    let data_filename, user_filename, view0_filename, changes_filename =
      parse_args Sys.argv
    in
    to_things data_filename user_filename view0_filename changes_filename
  else (
    prerr_endline "Usage: ws <data.csv> <user.txt> <view0.csv> <changes.txt>";
    exit 1 )

let () = main ()
