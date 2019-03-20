open Ast
open Printer

module type DATA = sig
  type t

  val init : string -> t
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
    { data = Array.make_matrix rows cols {value = Empty}
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
    let r, c = Ast.pos pos in
    match Mpos.find_opt pos t.change with
    | None -> (try t.data.(r).(c) with _ -> create_cell Empty)
    | Some v -> v

  let set_init pos v t =
    let r, c = Ast.pos pos in
    let t =
      let more_rows, more_cols = r > t.rows - 1, c > t.cols - 1 in
      if more_rows || more_cols
      then
        let more b t p = if b then if p > 2 * t then p else 2 * t else t in
        let rows = more more_rows t.rows r in
        let cols = more more_cols t.cols c in
        resize rows cols t
      else t
    in
    t.data.(r).(c) <- v;
    t

  let set pos v t = {t with change = Mpos.add pos v t.change}

  let traverse f (tl, br) t =
    let rec aux pos t =
      let r, c = Ast.pos pos in
      let tl_r, _ =  Ast.pos tl in
      let br_r, br_c =  Ast.pos br in
      if r > br_r
      then if c > br_c then t else aux (Ast.build_pos tl_r (c + 1)) t
      else
        let t = f pos t in
        aux (build_pos (r+1) c) t
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
    if cell = "P"
    then Ast.Undefined
    else (if cell = "E"
          then Ast.Empty
          else Ast.Int (int_of_string cell))

  let fail r c =
    failwith ("Could not read cell " ^ string_of_int r ^ ":" ^ string_of_int c)

  let parse_data data_filename =
    let ic = open_in data_filename in
    let rec aux data r =
      try
        let line = input_line ic in
        let cells =
          String.split_on_char ';' line
          |> List.map String.trim in
        let read_cell (data, r, c) cell =
          if cell = ""
          then set_init (build_pos r c) {value=Empty} data, r, c + 1
          else
            try
              let value = read_value cell in
              set_init (build_pos r c) {value} data, r, c + 1
            with Failure _ -> set_init (build_pos r c) {value=Undefined} data, r, c + 1
              (* CHANGER CA : si erreur ca doit faire un truc mieux  *)
        in
        let data, _, _ =
          List.fold_left read_cell (data, r, 0) cells
        in
        aux data (r + 1)
      with End_of_file -> data
    in
    let return = aux (create 16 16) 0 in
    close_in ic;
    return

  let init data_filename = parse_data data_filename

  (* A optimiser *)
  let output_init data view0 =
    let binding = Mpos.bindings data.change in
    let rec max_size l rows cols =
      match l with
      | [] -> rows, cols
      | (pos, v) :: t ->
        (match Ast.value v with
        | Empty -> max_size t rows cols
        | _ ->
          let r, c = Ast.pos pos in
          let cols = if c > cols then c else cols in
          let rows = if r > rows then r else rows in
          max_size t rows cols)
    in
    let rec max_size_bis i j rows cols =
      if j >= data.cols
      then rows, cols
      else if i >= data.rows
      then max_size_bis 0 (j + 1) rows cols
      else
          match Ast.value data.data.(i).(j) with
        | Empty -> max_size_bis (i + 1) j rows cols
        | _ ->
          let cols = if j > cols then j else cols in
          let rows = if i > rows then i else rows in
          max_size_bis (i + 1) j rows cols
    in
    let rows, cols = max_size binding 0 0 in
    let rows, cols =
      if rows < data.rows || cols < data.cols
      then max_size_bis 0 0 rows cols
      else rows, cols
    in
    let file = open_out view0 in
    for i = 0 to rows do
      for j = 0 to cols do
        let c = get (Ast.build_pos i j) data in
        let s = string_of_value (Ast.value c) in
        if j != cols
        then Printf.fprintf file "%s;" s
        else Printf.fprintf file "%s" s
      done;
      Printf.fprintf file "\n"
    done;
    flush file ; close_out file
end
