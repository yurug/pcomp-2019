open Graph

module Make (D : Data.DATA) = struct
  type data = D.t

  let parse_data data_filename = failwith "Student! This is your job!"

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
