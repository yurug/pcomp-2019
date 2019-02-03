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

let generate_size min max = int max + min

let generate_formula a b =
  let a, b = a / 2, b / 2 in
  let x, y = int a, int b in
  let x', y' = int a, int b in
  let v = int 256 in
  Printf.sprintf "=#(%d, %d, %d, %d, %d)" x y x' y' v

let generate_value () = string_of_int (int 256)

(* [FIXME] : latter switch between either a formula or a value  *)
let generate_element () = generate_value ()

let generate_line n =
  let rec aux acc = function
    | 0 -> acc
    | n -> generate_element () :: aux acc (n - 1)
  in
  aux [] n

let write_line file sep l =
  let s = String.concat sep l in
  Printf.fprintf file "%s\n" s

let generate_size max n =
  let x = (32 + ((n - 1) * ((31191 / max) - 1))) / 2 in
  x, x

let rec write_file out sep lines = function
  | 0 -> close_out out
  | n ->
    write_line out sep (generate_line lines);
    write_file out sep lines (n - 1)

let write_files csv change lines columns =
  write_file csv ";" lines columns;
  write_file change " " 3 10

let rec generator max formula = function
  | 0 -> ()
  | n ->
    let out = new_csv_file n in
    let lines, columns = generate_size max n in
    let change = new_change_file n in
    write_files out change lines columns;
    generator max formula (n - 1)

let generate_csv ?(formula = false) n =
  self_init ();
  generator n formula n
