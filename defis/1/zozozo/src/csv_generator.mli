(* [generate_csv b n] will genere [n] csv file in the folder tests/gen_X called
   data.csv. Where gen_X is the x-th generated folder
   The folders gen_X will be created if it does not exists.
   Each folder will also contain a change.txt

   if [b] is set to true, then some random formulas will be placed inside the csv.
   Otherwise, the csv file will only contains values ranging from 0 to 255 (inclusive)

  [FIXME] : formula generation hasn't been properly implemented yet
 *)
val generate_csv ?formula:bool -> int -> unit
