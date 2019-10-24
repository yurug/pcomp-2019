(* [generate_csv n] generates [n] `data.csv` files in each
   `tests/gen_X` directory, where gen_X is the x-th generated
   directory. The directory will be created if it does not exists.
   Each directory will also contain a `changes.txt` file.
 *)
val generate_csv : int -> unit
