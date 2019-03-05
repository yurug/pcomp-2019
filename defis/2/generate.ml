let cout = open_out "big.csv"

let output = output_string cout

let random_bits =
  let x = ref (int_of_float (Unix.time ())) in
  fun () ->
  x := (166425 * !x + 1013904223) mod (1 lsl 32);
  !x

let random_int k =
  random_bits () mod k

let check_command_line_arguments =
  if Array.length Sys.argv < 3 then (
    Printf.eprintf "generate formula_ratio max_size\n";
    exit 1
  )

let formula_value_ratio = int_of_string Sys.argv.(1)

let max_size = int_of_string Sys.argv.(2)

let largeInt () = 1 + random_int max_size
let nbrows = largeInt ()
let nbcols = largeInt ()

let announce =
  Printf.printf
    "Generating a sheet with %d rows and %d cols.\n%!"
    nbrows nbcols

let random start stop =
  start + random_int (stop - start)

let random_value () = string_of_int (random_int 256)

let random_formula () =
  let rstart = random_int nbrows and cstart = random_int nbcols in
  let rstop = random rstart nbrows and cstop = random cstart nbcols in
  output "=#(";
  output (string_of_int rstart); output ", ";
  output (string_of_int cstart); output ", ";
  output (string_of_int rstop); output ", ";
  output (string_of_int cstop); output ", ";
  output (random_value ());
  output ")"

let random_cell () =
  if random_int formula_value_ratio = 0 then
    random_formula ()
  else
    output (random_value ())

let rec separated_list sep elem = function
  | 0 -> assert false
  | 1 -> elem ()
  | n -> elem (); output sep; separated_list sep elem (n - 1)

let random_row = separated_list ";" (fun () -> random_cell ())
let random_sheet = separated_list "\n" (fun () -> random_row nbcols)

let main =
  random_sheet nbrows;
  close_out cout
