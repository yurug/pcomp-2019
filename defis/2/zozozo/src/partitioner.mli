open Ast

type id = int
type area = int * int
type regs
type regions = {regs : regs ; r_to_pos : pos -> id  }

val compute_regions : string -> int -> regions

val get_region_filename : regions -> id -> string

val get_region_area : regions -> id -> int * int

val pos_to_region : regions -> pos -> id

(** [regions_within regions p1 p2] returns the list of the regions in
   [regions] that are at least partially in the area described by
   ([p1], [p2]) *)
val regions_within : regions -> pos -> pos -> id list

val number_regions : regions -> int

val regions_fold : (id -> area -> 'b -> 'b) -> regions -> 'b -> 'b

val compute_regions : string -> int -> ((pos * is_formula content) list * regions)

val cut_file_into_regions : string -> regions -> int -> unit
