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
  let error_message =
    "Bad Input, should be \"data.csv user.txt view0.csv changes.txt\""
  in
  match Sys.argv with
  | args when Array.length args = 5 ->
    let data_filename, user_filename, view0_filename, changes_filename =
      parse_args Sys.argv
    in
    to_things data_filename user_filename view0_filename changes_filename
  | exception Invalid_argument _ -> prerr_endline error_message
  | _ -> prerr_endline error_message

let () = main ()
