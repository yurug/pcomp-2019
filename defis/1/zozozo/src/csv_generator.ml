open Random

(* [FIXME] : how to avoid code duplication ? *)
let new_csv_file n =
  let folder = Printf.sprintf "tests/gen_%d" n in
  try
    Unix.mkdir folder 0o755;
    let s = Printf.sprintf "tests/gen_%d/data.csv" n in
    open_out s
  with _ ->
    let s = Printf.sprintf "tests/gen_%d/data.csv" n in
    open_out s

let new_change_file n =
  let s = Printf.sprintf "tests/gen_%d/change.txt" n in
  open_out s

let generate_formula a b =
  let a, b = a / 2, b / 2 in
  let x, y = int a, int b in
  let x', y' = int a, int b in
  let v = int 256 in
  Printf.sprintf "=#(%d, %d, %d, %d, %d)" x y x' y' v

let generate_value () = string_of_int (int 256)

let generate_element rate a b =
  if float 1. < rate then generate_formula a b else generate_value ()

let generate_line rate a b n =
  let rec aux acc = function
    | 0 -> acc
    | n -> generate_element rate a b :: aux acc (n - 1)
  in
  aux [] n

let write_line file sep l =
  let s = String.concat sep l in
  Printf.fprintf file "%s\n" s

let generate_size max n =
  let x = (32 + ((n - 1) * ((31191 / max) - 1))) / 2 in
  x, x

let rec write_file rate a b out sep lines = function
  | 0 -> close_out out
  | n ->
    write_line out sep (generate_line rate a b lines);
    write_file rate a b out sep lines (n - 1)

let write_files rate csv change lines columns =
  write_file rate lines columns csv ";" lines columns;
  write_file rate 3 10 change " " 3 10

let compute_rate x y = 1. /. (0.10 *. float_of_int (x * y))

let rec generator max = function
  | 0 -> ()
  | n ->
    let out = new_csv_file n in
    let lines, columns = generate_size max n in
    let rate = compute_rate lines columns in
    let change = new_change_file n in
    write_files rate out change lines columns;
    generator max (n - 1)

let generate_csv n =
  self_init ();
  generator n n
