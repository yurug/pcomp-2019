open Graph

module Make (D : Data.DATA) = struct
  type data = D.t

  type parsing_state =
    | Undef
    | Val
    | Formula

  let parse_data data_filename =
    let ic = open_in data_filename in
    let rec aux (data, formulas) r c =
      try
        let line = input_line ic in
        let cells = String.split_on_char ';' line in
        List.fold_left
          (fun (data, formulas) cell ->
            try
              let value = Scanf.sscanf cell "%d" (fun d -> d) in
              let value = Ast.Int value in
              D.set {r; c} {value} data, formulas
            with Scanf.Scan_failure _ ->
              (try
                 let formula =
                   Scanf.sscanf
                     cell
                     "=#(%d, %d, %d, %d %d)"
                     (fun r1 c1 r2 c2 v ->
                       Ast.Occ (({r = r1; c = c1}, {r = r2; c = c2}), Int v) )
                 in
                 data, formula :: formulas
               with Scanf.Scan_failure str -> failwith str) )
          (data, formulas)
          cells
      with End_of_file -> data, formulas
    in
    aux (D.create 16 16, []) 0 0

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
      let graph = add_node graph pos node in
      let result = eval data graph content in
      let result = {Ast.value = result} in
      D.set pos result data
end
