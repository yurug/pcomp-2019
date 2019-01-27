open Graph

module Make (D : Data.DATA) = struct
  type data = D.t

  let read_value cell =
    let value = Scanf.sscanf cell "%d" (fun d -> d) in
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

  let parse_action line =
    let ic = Scanf.Scanning.from_string line in
    let r, c, cell = Scanf.bscanf ic "%d %d %s" (fun r c cell -> r, c, cell) in
    let content =
      try
        let value = read_value cell in
        Ast.Val value
      with Scanf.Scan_failure _ ->
        (try read_formula cell with Scanf.Scan_failure _ -> fail r c)
    in
    Ast.Set ({r; c}, content)

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

  let output data view0 =
    let file = open_out view0 in
    D.iter'
      (fun c ->
        let s = Ast.string_of_value (Ast.value c) in
        Printf.fprintf file "%s;" s )
      (fun () -> Printf.fprintf file "\n")
      data;
    close_out file

  let eval_occ data p p' v =
    D.fold_rect
      (fun acc cell -> if Ast.value cell = v then acc + 1 else acc)
      0
      (p, p')
      data

  let eval data = function
    | Ast.Val v -> v
    | Ast.Occ ((pos, pos'), v) -> Ast.Int (eval_occ data pos pos' v)

  let rec loop_eval data graph dependency changes content pos  =
     let v = eval data content in
     let data = D.set pos Ast.{value=v} data in
     let changes = (pos, v)::changes in
     let computable, dependency = Dependency.get_new_computable_nodes pos dependency in
     let dependency = Dependency.remove_computed_node pos dependency
     in
     List.fold_left
       (fun (dat, depend, changes) (content, pos) -> loop_eval dat graph depend changes content pos)
       (data, dependency, changes)
       computable

  let update data graph = function
    | Ast.Set (pos, content) ->
      let graph = change_node pos (build_node content) graph in
      let dependency = Dependency.build_dependency_from graph pos in
      let data, dependency, changes =
        if Dependency.is_computable pos dependency then
          loop_eval data graph dependency [] content pos
        else data, dependency, [] in
      let data = List.fold_left
        (fun data pos -> D.set pos Ast.{value=Undefined} data)
        data
        (Dependency.get_non_computable_nodes dependency)
      in
      data, graph, changes

end
