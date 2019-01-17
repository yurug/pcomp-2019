module type Spreadsheet = sig
  type tab
  type action

  (* data.csv to tab *)
  val parse_data : string -> tab

  (* print files view0.csv, changes.txt, tab *)
  val output : string -> string -> tab -> unit

  (* incremential action applied to the tab *)
  val update : action -> tab -> tab
end

module Spreadsheet = struct
  type action =
    | Set of Ast.pos * Ast.cell

  type tab = unit
  let parse_data data_filename =
    failwith "Student! This is your job!"

  let output view0 changes tab =
    failwith "Student! This is your job!"

  let update action tab =
    failwith "Student! This is your job!"
end
