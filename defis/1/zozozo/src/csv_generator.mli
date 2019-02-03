(* [generate_csv b n] generates [n] `data.csv` files in each
   `tests/gen_X` directory, where gen_X is the x-th generated
   directory. The directory will be created if it does not exists.
   Each directory will also contain a `changes.txt` file.

   If [b] is true, then some random formulas will be placed inside the
   csv. Otherwise, the csv file will only contains values ranging
   from 0 to 255 (inclusive).

  [FIXME]: formula generation hasn't been properly implemented yet *)
val generate_csv : ?formula:bool -> int -> unit
