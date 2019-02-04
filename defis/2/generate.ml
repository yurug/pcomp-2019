let init = Random.self_init ()

let check_command_line_arguments =
  if Array.length Sys.argv < 3 then (
    Printf.eprintf "generate formula_ratio max_size\n";
    exit 1
  )

let formula_value_ratio = int_of_string Sys.argv.(1)

let max_size = int_of_string Sys.argv.(2)

let largeInt () = 1 + Random.int max_size
let nbrows = largeInt ()
let nbcols = largeInt ()

let announce =
  Printf.printf
    "Generating a sheet with %d rows and %d cols.\n%!"
    nbrows nbcols

let random start stop =
  start + Random.int (stop - start)

let random_value () = string_of_int (Random.int 256)

let random_formula () =
  let rstart = Random.int nbrows and cstart = Random.int nbcols in
  let rstop = random rstart nbrows and cstop = random cstart nbcols in
  Printf.sprintf "=#(%d, %d, %d, %d, %s)"
    rstart cstart rstop cstop (random_value ())

let random_cell () =
  if Random.int formula_value_ratio = 0 then
    random_formula ()
  else
    random_value ()

let rec separated_list sep elem (out : string -> unit) = function
  | 0 -> assert false
  | 1 -> elem ()
  | n -> elem (); out sep; separated_list sep elem out (n - 1)

let random_row out = separated_list ";" (fun () -> out (random_cell ())) out
let random_sheet out = separated_list "\n" (fun () -> random_row out nbcols) out

let main =
  let cout = open_out "big.csv" in
  random_sheet (output_string cout) nbrows;
  close_out cout
