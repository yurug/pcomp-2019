open Ast

(** [cut_file_into_region filename dr] reads the file named [filename]
   and cut it into piece with dr lines each (except last one). The
   name of the cut file is [filename_x.[ext]].  *)
val cut_file_into_region : string -> int -> unit

(** [build_graph filename dr] create the dependency graph from the
   data file named [filename] and with a region depth (nb of line by
   region) of [dr]. *)
val build_graph : string -> int -> (pos * is_formula content) list * Graph.t


(** [first_evaluation filename dr f g] *)
val first_evaluation : string -> int -> (pos * is_formula content) list -> Graph.t -> unit
