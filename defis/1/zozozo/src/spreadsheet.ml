open Graph

module Make (D : Data.DATA) = struct
  type data = D.t

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
            D.set {r; c} {value} data, formulas, r, c + 1
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
    let return = aux (D.create 16 16) [] 0 in
    close_in ic;
    return

  let try_int_of_string err s =
    try int_of_string s with Failure _ -> failwith err

  let parse_pos err r c =
    try Ast.{r = int_of_string r; c = int_of_string c} with Failure _ ->
      failwith err

  let parse_value err vstr =
    match vstr with
    | "P" -> Ast.Undefined
    | v -> Ast.Int (try_int_of_string err v)

  let parse_formula err h c1 r2 c2 v =
    let rmin =
      if String.sub h 0 3 = "=#("
      then try_int_of_string err (String.sub h 3 (String.length h - 3))
      else failwith err
    in
    let cmin, rmax, cmax =
      ( try_int_of_string err c1
      , try_int_of_string err r2
      , try_int_of_string err c2 )
    in
    let v =
      try String.sub v 0 (String.length v - 1) with Invalid_argument _ ->
        failwith err
    in
    let v = parse_value err v in
    Ast.Occ (({r = rmin; c = cmin}, {r = rmax; c = cmax}), v)

  let parse_action line =
    let bad_format_err = "Bad format in user.txt file" in
    let split = String.split_on_char ' ' line in
    let pos, str_content =
      match split with
      | r :: c :: cell -> parse_pos bad_format_err r c, cell
      | _ -> failwith bad_format_err
    in
    let str_content =
      String.concat "" str_content
      |> String.split_on_char ','
      |> List.map String.trim
    in
    let content =
      match str_content with
      | [v] -> Ast.Val (parse_value bad_format_err v)
      | [h; c1; r2; c2; v] when String.length h >= 4 ->
        (* TODO : add tolerance here on formula format (no spaces
             accepted right now between =# and ( and ( and first int) *)
        parse_formula bad_format_err h c1 r2 c2 v
      | _ -> failwith bad_format_err
    in
    Ast.Set (pos, content)

  let output data view0 =
    let file = open_out view0 in
    D.iter'
      (fun c ->
        let s = Ast.string_of_value (Ast.value c) in
        Printf.fprintf file "%s;" s )
      (fun () -> Printf.fprintf file "\n")
      data;
    close_out file

  let output_changes all_changes filename =
    let file = open_out filename in
    List.iter
      (fun (cmd, changes) ->
        Printf.fprintf file "after \"%s\":\n" cmd;
        List.iter
          (fun (Ast.({r; c}), v) ->
            let v = Ast.string_of_value v in
            Printf.fprintf file "%d %d %s\n" r c v )
          changes )
      all_changes;
    close_out file

  let build_graph formulas =
    let rec build_acc g formulas =
      match formulas with
      | [] -> g
      | (_, Ast.Val _) :: _ ->
        failwith "Spreadsheet.build_graph: Val in formula."
      | Ast.(pos, (Occ _ as content)) :: r ->
        build_acc (add_node pos (build_node content) g) r
    in
    build_acc empty formulas

  let eval_occ data p p' v =
    D.fold_rect
      (fun acc cell -> if Ast.value cell = v then acc + 1 else acc)
      0
      (p, p')
      data

  let eval data = function
    | Ast.Val v -> v
    | Ast.Occ ((pos, pos'), v) -> Ast.Int (eval_occ data pos pos' v)

  let rec loop_eval data graph order changes content pos =
    let v = eval data content in
    let data = D.set pos Ast.{value = v} data in
    let changes = (pos, v) :: changes in
    let computable, order =
      FormulaOrder.get_new_computable_formulas pos order
    in
    let order = FormulaOrder.remove_computed_formula pos order in
    List.fold_left
      (fun (dat, depend, changes) (content, pos) ->
        loop_eval dat graph depend changes content pos )
      (data, order, changes)
      computable

  let update data graph = function
    | Ast.Set (pos, content) ->
      let graph = change_node pos (build_node content) graph in
      let order = FormulaOrder.build_order_from graph pos in
      let data, order, changes =
        if FormulaOrder.is_computable pos order
        then loop_eval data graph order [] content pos
        else data, order, []
      in
      (* Put non-computable node to Undefined in data*)
      let data, changes =
        List.fold_left
          (fun (data, changes) pos ->
            ( D.set pos Ast.{value = Undefined} data
            , (pos, Ast.Undefined) :: changes ) )
          (data, changes)
          (FormulaOrder.get_non_computable_formulas order)
      in
      data, graph, changes

  let eval_init data graph formulas =
    let order = FormulaOrder.build_order_from_all graph formulas in
    let computable = FormulaOrder.get_computable_formulas order in
    let data, order, changes =
      List.fold_left
        (fun (dat, depend, ch) (content, pos) ->
          loop_eval dat graph depend ch content pos )
        (data, order, [])
        computable
    in
    (* Put non-computable node to Undefined in data*)
    let data, _ =
      List.fold_left
        (fun (data, changes) pos ->
          ( D.set pos Ast.{value = Undefined} data
          , (pos, Ast.Undefined) :: changes ) )
        (data, changes)
        (FormulaOrder.get_non_computable_formulas order)
    in
    data
end
