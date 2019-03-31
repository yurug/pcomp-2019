(**

   This program produces the files [data.csv] and [user.txt] for the
   challenges 1, 2 and 3.

*)

(*
  TODOS:
  - Introduce cycles
  - Use better data structures to avoid quadratic search

*)

let _ = Random.self_init ()

(******************************************************************************)
(*                    Command-line processing                                 *)
(******************************************************************************)

let area_size                   = ref 1000
let nb_rows                     = ref 10
let nb_cols                     = ref 10
let depth                       = ref 10
let branching_factor            = ref 10
let level_depth                 = ref 10
let user_formulas_inverse_ratio = ref 10
let nb_user_actions             = ref 1000

let options = Arg.(align [
  "--area-size", Set_int area_size, " Limit length for area (default = 100)";
  "--nb-rows"  , Set_int nb_rows,   " Limit number of rows  (default = 5000)";
  "--nb-cols"  , Set_int nb_cols,   " Limit number of cols  (default = 5000)";

  "--branching-factor", Set_int branching_factor,
  " Arity limit in the dependency graph (default = 10)";

  "--depth", Set_int depth,
  " Depth limit of the dependency graph (default = 10)";

  "--level-depth", Set_int level_depth,
  " Length limit of a graph level (default = 10)";

  "--user-edit-inverse-ratio",
  Set_int user_formulas_inverse_ratio,
  " Ratio of formula edits in user commands (default = 1/10)";

  "--nb-user-actions",
  Set_int nb_user_actions,
  " Limit number of user edits (default = 100)"
])

let usage = "generator [options]"

let no_argument _ = failwith "Invalid command line argument."

let _parse_command_line = Arg.parse options no_argument usage

(******************************************************************************)
(*                    Utilities                                               *)
(******************************************************************************)

let random_positive k =
  if k = 1 then 1 else 1 + Random.int (k - 1)

let make_list n f =
  let rec aux k accu =
    if k = 0 then
      accu
    else
      aux (k - 1) (f k :: accu)
  in
  aux n []

let rec take m l =
  if m = 0 then
    ([], l)
  else
    match l with
    | [] -> ([], l)
    | x :: xs -> let (g, l) = take (m - 1) xs in (x :: g, l)

(******************************************************************************)
(*                    Dependency Graph datatypes                              *)
(******************************************************************************)

type position = { row : int; col : int }

type area = {
    row_min : int;
    row_max : int;
    col_min : int;
    col_max : int;
}

let all_space () = {
    row_min = 0;
    row_max = !nb_rows;
    col_min = 0;
    col_max = !nb_cols;
}


let area_of_position p = {
    row_min = p.row;
    col_min = p.col;
    row_max = p.row;
    col_max = p.col;
}

type identifier = int

(** (f, g) represents [f] depends on [g]. This implies that the
    position of [g] is included in the area of [f]. *)
type dependency = identifier * identifier

type dependencies = dependency list

type formula = {
    identifier : identifier;
    position   : position option;
    area       : area option;
}

let area f = match f.area with None -> assert false | Some a -> a

let position f = match f.position with None -> assert false | Some p -> p

type space = {
    reserved_areas : area list;
}

let position_in_area p a =
  p.row >= a.row_min && p.row <= a.row_max
  && p.col >= a.col_min && p.col <= a.col_max

let intersect a1 a2 =
     a1.col_min < a2.col_max
  && a1.col_max > a2.col_min
  && a1.row_min < a2.row_max
  && a1.row_max > a2.row_min

let intersection a1 a2 =
  let col_min = max a1.col_min a2.col_min
  and col_max = min a1.col_max a2.col_max
  and row_min = max a1.row_min a2.row_min
  and row_max = min a1.row_max a2.row_max in
  if col_min <= col_max && row_min <= row_max then
    Some { col_min; col_max; row_min; row_max }
  else
    None

(** [extend a1 a2] extends [a1] to include [a2]. *)
let extend a1 a2 =
  let col_min = min a1.col_min a2.col_min
  and col_max = max a1.col_max a2.col_max
  and row_min = min a1.row_min a2.row_min
  and row_max = max a1.row_max a2.row_max in
  { col_min; col_max; row_min; row_max }

let random_expansion_step () =
  random_positive !area_size

let random_expansion a =
  let col_min = max 0 (a.col_min - random_expansion_step ()) in
  let col_max = a.col_max + random_expansion_step () in
  let row_min = max 0 (a.row_min - random_expansion_step ()) in
  let row_max = a.row_max + random_expansion_step () in
  { col_min; col_max; row_min; row_max }

let random_position a =
  { row = a.row_min + Random.int (a.row_max - a.row_min + 1);
    col = a.col_min + Random.int (a.col_max - a.col_min + 1) }

let random_global_position () =
  random_position (all_space ())

let rec random_area () =
  let row_min = Random.int !nb_rows in
  let col_min = Random.int !nb_cols in
  let row_max = row_min + Random.int !area_size in
  let col_max = col_min + Random.int !area_size in
  { row_min; row_max; col_min; col_max }

let string_of_position p =
  Printf.sprintf "%d:%d" p.row p.col

let string_of_area a =
  Printf.sprintf "%d-%d:%d-%d" a.row_min a.row_max a.col_min a.col_max

let string_of_formula f =
  Printf.sprintf "{ id = %d; position = %s; area = %s }"
    f.identifier
    (match f.position with None -> "?" | Some p -> string_of_position p)
    (match f.area with None -> "?" | Some p -> string_of_area p)

(******************************************************************************)
(*                    Formula placement                                       *)
(******************************************************************************)

(** [allocate space [f1; ..; fn] g] tries to assign a position to [g]
   and areas to [f1] ... [fn] such that the position of [g] is
   included in the areas of [f1] ... [fn] and neither [g]'s position
   nor the areas of [f1] ... [fn] intersect with the reserved areas of
   [space]. If some [fi] already has an assigned area, this area can
   be extended to meet the aforementionned constraints.

   This function proceeds as follows:

   1. It tries to extend already defined areas to make sure that they
   have a common intersection I (while still being valid with respect
   to [space]).

   2. It computes new areas if needed as extensions of I.

   3. It assigns a position to [g] that is in I.

*)
let allocate space fs g : (formula list * formula) option =
  let fail = None in
  let valid_area a =
    not (List.exists (intersect a) space.reserved_areas)
  in
  let rec traverse (defined_formulas, unset_formulas, i) = function
    | [] ->
       Some (defined_formulas, unset_formulas, i)
    | f :: fs ->
       match f.area, (i : area option) with
       | None, _ ->
          traverse (defined_formulas, f :: unset_formulas, i) fs
       | Some area, None ->
          traverse (f :: defined_formulas, unset_formulas, Some area) fs
       | Some area, Some i ->
          let area = extend area i in
          let f = { f with area = Some area } in
          if valid_area area then
            traverse (f :: defined_formulas, unset_formulas, Some i) fs
          else
            fail
  in
  match traverse ([], [], None) fs with
  | None -> fail
  | Some (defined_formulas, unset_formulas, i) ->
     let i =
       let rec aux () =
         match i with
         | None ->
            let area = random_area () in
            if valid_area area then area else aux ()
         | Some i ->
            i
       in
       aux ()
     in
     let fresh_area f = { f with area = Some (random_expansion i) } in
     let newly_set_formulas = List.map fresh_area unset_formulas in
     let position = random_position i in
     let g = { g with position = Some position } in
     Some (defined_formulas @ newly_set_formulas, g)

let formulas_from_dependencies deps =
  let formulas = Hashtbl.create 13 in
  let set id formula = Hashtbl.replace formulas id formula in
  let unset id = not (Hashtbl.mem formulas id) in
  let get id = Hashtbl.find formulas id in
  let reverse_deps = Hashtbl.create 13 in
  let get_rdeps id = try Hashtbl.find reverse_deps id with Not_found -> [] in
  let set_rdep id d = Hashtbl.replace reverse_deps id (d :: get_rdeps id) in

  let queue = Queue.create () in
  let introduce f =
      if unset f then (
        set f { identifier = f; position = None; area = None };
        Queue.add f queue
      );
  in

  List.iter (fun (f, g) ->
      introduce f;
      introduce g;
      set_rdep g f
  ) deps;

  let rec process okfs =
    if Queue.is_empty queue then
      ()
    else let g = Queue.pop queue in
         let fs = get_rdeps g in
         let space =
           { reserved_areas =
             List.(filter (fun f -> not (List.mem f fs)) okfs
                   |> map (fun f -> match (get f).area with
                                      | None -> assert false
                                      | Some a -> a))
           }
         in
         match allocate space (List.map get fs) (get g) with
           | None ->
              Queue.push g queue;
              process okfs
           | Some (fs, g) ->
              List.iter (fun f -> set f.identifier f) (g :: fs);
              process (List.map (fun f -> f.identifier) fs @ okfs)
  in
  process [];

  let positions =
    ref (Hashtbl.fold (fun _ f ps ->
             match f.position with
             | None -> ps
             | Some p -> p :: ps
           ) formulas [])
  in
  let areas =
    ref (Hashtbl.fold (fun _ f ps ->
             match f.area with
             | None -> ps
             | Some a -> a :: ps
           ) formulas [])
  in
  let final = ref [] in
  Hashtbl.iter (fun _ f ->
      let position =
        let rec random () =
          let p = random_global_position () in
          if List.exists (fun a -> position_in_area p a) !areas then
            random ()
          else (
            positions := p :: !positions;
            p
          )
        in
        match f.position with
        | None -> random ()
        | Some p -> p

      and area =
        let rec random () =
          let a = random_area () in
          if List.exists (fun p -> position_in_area p a) !positions then
            random ()
          else (
            areas := a :: !areas;
            a
          )
        in
        match f.area with
        | None -> random ()
        | Some a -> a
      in
      let f = { f with position = Some position; area = Some area } in
      set f.identifier f;
      final := f :: !final
    ) formulas;

  let check_dependency (f, g) =
    match (get f).area, (get g).position with
    | Some a, Some p ->
       if not (position_in_area p a) then (
         Printf.printf "Wrong: %s depends on %s\n"
           (string_of_formula (get f)) (string_of_formula (get g))
       )
    | _ ->
       assert false
  in
  List.iter check_dependency deps;

  !final

let is_base_formula _ =
  Random.int !user_formulas_inverse_ratio = 0

let input_of_formulas formulas =
  let used_area =
    List.fold_left (fun a f ->
        extend (extend a (area f)) (area_of_position (position f))
      ) (all_space ()) formulas
  in
  let user_formulas, base_formulas =
    List.partition is_base_formula formulas
  in
  let output_formula f =
    Printf.sprintf "=#(%d,%d,%d,%d,%d)"
      (area f).row_min (area f).col_min
      (area f).row_max (area f).col_max
      (Random.int 256)
  in
  let create_data_csv () =
    let cout = open_out "data.csv" in
    let _data =
      for row = 0 to used_area.row_max do
        for col = 0 to used_area.col_max do
          begin try
              let f =
                List.find
                  (fun f -> (position f).row = row && (position f).col = col)
                  base_formulas
              in
              Printf.fprintf cout "%s" (output_formula f)
            with Not_found -> Printf.fprintf cout "%d" (Random.int 256)
          end;
          Printf.fprintf cout "%c"
            (if col = used_area.col_max then '\n' else ';')
        done
      done
    in
    close_out cout
  in
  let create_user_txt () =
    let cout = open_out "user.txt" in
    let formulas = ref user_formulas in
    let edit_formula () =
      let f = List.hd !formulas in
      formulas := List.tl !formulas;
      Printf.fprintf cout "%d %d %s\n"
        (position f).row (position f).col
        (output_formula f)
    in
    let edit_data () =
      Printf.fprintf cout "%d %d %d\n"
        (random_positive used_area.row_max)
        (random_positive used_area.col_max)
        (Random.int 256)
    in
    let rec aux k =
      if k <= 0 then () else (
        if !formulas <> [] && Random.int !user_formulas_inverse_ratio = 0
        then
          edit_formula ()
        else
          edit_data ();
        aux (k - 1)
      )
    in
    aux (random_positive !nb_user_actions);
    close_out cout
  in
  create_data_csv ();
  create_user_txt ()

let fresh_index =
  let r = ref 0 in
  fun () -> incr r; !r

let generate_dependencies () =
  let ordered_covering k w l =
    let n = List.length l in
    let rec group accu n l k =
      if k = 0 then
        l :: accu
      else
        let m = random_positive (min w n) in
        let g, _ = take m l in
        let m = random_positive m in
        let _, l = take m l in
        let n = n - m in
        let accu = g :: accu in
        if n = 0 then
          accu
        else
          group accu n l (k - 1)
    in
    group [] n (List.rev l) k
  in
  let random_level_depth () =
    random_positive !level_depth
  in
  let generate_last_level () =
    make_list (random_level_depth ()) (fun _ -> (fresh_index (), []))
  in
  let rec generate_levels next_level_indices levels k =
    if k = 0 then
      levels
    else
      let depth = random_level_depth () in
      let succs = ordered_covering depth !branching_factor next_level_indices in
      let level = List.map (fun ss -> (fresh_index (), ss)) succs in
      let level_indices = List.map fst level in
      generate_levels level_indices (level :: levels) (k - 1)
  in
  let last = generate_last_level () in let lastidx = List.map fst last in
  let levels = generate_levels lastidx [last] (random_positive !depth) in
  let deps_of_level level =
    List.(flatten (map (fun (n, nodes) -> map (fun k -> (n, k)) nodes) level))
  in
  let dependencies = List.(flatten (map deps_of_level levels)) in
  let string_of_level level =
    String.concat " "
      (List.map (fun (n, ss) ->
           Printf.sprintf "[%d -> %s]"
             n (String.concat " " (List.map string_of_int ss)))
         level)
  in
  Printf.printf "Levels:\n%s\n"
    (String.concat "\n" (List.map string_of_level levels));
  dependencies

let main =
  generate_dependencies () |> formulas_from_dependencies |> input_of_formulas
