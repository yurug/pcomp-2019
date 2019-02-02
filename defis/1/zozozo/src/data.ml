open Ast

module type DATA = sig
  type t

  val init : string -> t * (pos * content) list
  val get : pos -> t -> cell
  val set : pos -> cell -> t -> t
  val set_rect : pos * pos -> cell -> t -> t
  val map_rect : (cell -> cell) -> pos * pos -> t -> t
  val map_recti : (pos -> cell -> cell) -> pos * pos -> t -> t
  val fold_rect : ('a -> cell -> 'a) -> 'a -> pos * pos -> t -> 'a
  val fold_recti : ('a -> pos -> cell -> 'a) -> 'a -> pos * pos -> t -> 'a
  val output_init : t -> string -> unit
end

module DataArray : DATA = struct
  type t =
    { data : cell array array
    ; rows : int
    ; cols : int
    ; change : cell Mpos.t }

  let create rows cols =
    { data = Array.make_matrix rows cols {value = Undefined}
    ; rows
    ; cols
    ; change = Mpos.empty }

  let resize rows cols t =
    let obj = create rows cols in
    for r = 0 to min rows t.rows - 1 do
      for c = 0 to min cols t.cols - 1 do
        obj.data.(r).(c) <- t.data.(r).(c)
      done
    done;
    obj

  let get pos t =
    match Mpos.find_opt pos t.change with
    | None -> (try t.data.(pos.r).(pos.c) with _ -> create_cell Undefined)
    | Some v -> v

  let set_init pos v t =
    let t =
      let more_rows, more_cols = pos.r > t.rows - 1, pos.c > t.cols - 1 in
      if more_rows || more_cols
      then
        let more b t p = if b then if p > 2 * t then p else 2 * t else t in
        let rows = more more_rows t.rows pos.r in
        let cols = more more_cols t.cols pos.c in
        resize rows cols t
      else t
    in
    t.data.(pos.r).(pos.c) <- v;
    t

  let set pos v t = {t with change = Mpos.add pos v t.change}

  let traverse f (tl, br) t =
    let rec aux pos t =
      if pos.r > br.r
      then if pos.c > br.c then t else aux (Ast.pos tl.r (pos.c + 1)) t
      else
        let t = f pos t in
        aux {pos with r = pos.r + 1} t
    in
    aux tl t

  let set_rect (tl, br) v t =
    traverse
      (fun pos t -> {t with change = Mpos.add pos v t.change})
      (tl, br)
      t

  let apply f pos t =
    let c = get pos t in
    f c

  let map_rect f (tl, br) t =
    let f pos t c = {t with change = Mpos.add pos (f c) t.change} in
    traverse (fun pos t -> apply (f pos t) pos t) (tl, br) t

  let map_recti f (tl, br) t =
    let f pos t c = {t with change = Mpos.add pos (f pos c) t.change} in
    traverse (fun pos t -> apply (f pos t) pos t) (tl, br) t

  let fold_rect f a (tl, br) t =
    traverse (fun pos a -> apply (f a) pos t) (tl, br) a

  let fold_recti f a (tl, br) t =
    traverse (fun pos a -> apply (f a pos) pos t) (tl, br) a

  let read_value cell =
    let value = Scanf.sscanf (String.trim cell) "%d" (fun d -> d) in
    Ast.Int value

  let read_formula cell =
    Scanf.sscanf cell "=#(%d, %d, %d, %d, %d)" (fun r1 c1 r2 c2 v ->
        Ast.Occ (({r = r1; c = c1}, {r = r2; c = c2}), Int v) )

  let fail r c =
    failwith ("Could not read cell " ^ string_of_int r ^ ":" ^ string_of_int c)

  let parse_data data_filename =
    let ic = open_in data_filename in
    let rec aux data formulas r =
      try
        let line = input_line ic in
        let cells = String.split_on_char ';' line in
        let read_cell (data, formulas, r, c) cell =
          try
            let value = read_value cell in
            set_init {r; c} {value} data, formulas, r, c + 1
          with Scanf.Scan_failure _ ->
            (try
               let formula = read_formula cell in
               data, (Ast.{r; c}, formula) :: formulas, r, c + 1
             with Scanf.Scan_failure _ -> fail r c)
        in
        let data, formulas, _, _ =
          List.fold_left read_cell (data, formulas, r, 0) cells
        in
        aux data formulas (r + 1)
      with End_of_file -> data, formulas
    in
    let return = aux (create 16 16) [] 0 in
    close_in ic;
    return

  let init data_filename = parse_data data_filename

  (* A optimiser *)
  let output_init data view0 =
    let binding = Mpos.bindings data.change in
    let rec column l rows cols =
      match l with
      | [] -> rows, cols
      | (pos,v) :: t ->
         begin
           match Ast.value v with
           | Undefined -> column t rows cols
           | _ ->
              let cols = if pos.c > cols then pos.c else cols in
              let rows = if pos.r > rows then pos.r else rows in
              column t rows cols
         end
    in
    let rows, cols = column binding 0 0 in
    let file = open_out view0 in
    for i = 0 to rows do
      for j = 0 to cols do
        let c = get (Ast.pos i j) data in
        let s = Ast.string_of_value (Ast.value c) in
        Printf.fprintf file "%s;" s
      done;
      Printf.fprintf file "\n"
    done;
    close_out file
end
