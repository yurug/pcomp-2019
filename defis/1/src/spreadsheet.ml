open Graph

module Make (D : Data.DATA) = struct
  type data = D.t

  let parse_data data_filename =
    let ic = open_in data_filename in
    let rec aux data formulas c =
      try
        let line = input_line ic in
        let cells = String.split_on_char ';' line in
        let read_cell (data, formulas, r) cell =
          try
            let value = Scanf.sscanf cell "%d" (fun d -> d) in
            let value = Ast.Int value in
            D.set {r; c} {value} data, formulas, r + 1
          with Scanf.Scan_failure _ ->
            (try
               let formula =
                 Scanf.sscanf
                   cell
                   "=#(%d, %d, %d, %d, %d)"
                   (fun r1 c1 r2 c2 v ->
                     Ast.Occ (({r = r1; c = c1}, {r = r2; c = c2}), Int v) )
               in
               data, (Ast.{r; c}, formula) :: formulas, r + 1
             with Scanf.Scan_failure _ ->
               failwith
                 ( "Could not read cell "
                 ^ string_of_int r
                 ^ ":"
                 ^ string_of_int c ))
        in
        let data, formulas, _ =
          List.fold_left read_cell (data, formulas, 0) cells
        in
        aux data formulas (c + 1)
      with End_of_file -> data, formulas
    in
    aux (D.create 16 16) [] 0

  let output data view0 =
    let file = open_out view0 in
    D.iter'
      (fun c ->
        let s = Ast.string_of_value (Ast.value c) in
        Printf.fprintf file "%s;" s )
      print_newline
      data

  let eval_occ graph data p p' v =
    D.fold_rect
      (fun acc cell -> if Ast.value cell = v then acc + 1 else acc)
      0
      (p, p')
      data

  let eval data graph = function
    | Ast.Val v -> v
    | Ast.Occ ((pos, pos'), v) -> Ast.Int (eval_occ graph data pos pos' v)

  let update data graph = function
    | Ast.Set (pos, content) ->
      let node = build_node content in
      let graph = add_node pos node graph in
      let result = eval data graph content in
      let result = {Ast.value = result} in
      D.set pos result data
end
