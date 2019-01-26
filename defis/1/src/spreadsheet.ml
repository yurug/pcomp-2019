open Graph

module Make (D : Data.DATA) = struct
  type data = D.t

  type parsing_state =
    | Undef
    | Val
    | Formula

  let parse_data data_filename =
    let ic = open_in data_filename in
    let row, col = ref 0, ref 0 in
    let d = ref 0 in
    let state = ref Undef in
    let read_occurences () =
      let sic = Scanf.Scanning.from_channel ic in
      let f r1 c1 r2 c2 v =
        Ast.Occ (({r = r1; c = c1}, {r = r2; c = c2}), Int v)
      in
      Scanf.bscanf sic "(%d, %d, %d, %d, %d)" f
    in
    let read_formula graph =
      let fml =
        match input_char ic with
        | '#' -> read_occurences ()
        | _ -> failwith "Unsupported formula"
      in
      let node = Graph.build_node fml in
      Graph.add_node graph Ast.{r = !row; c = !col} node
    in
    let rec read (data, graph) =
      try
        (match input_char ic with
        | '0' .. '9' as c ->
          (match !state with
          | Undef ->
            d := (!d * 10) + int_of_char c;
            state := Val
          | Val -> d := (!d * 10) + int_of_char c
          | _ -> failwith "Incorrect syntax");
          data, graph
        | ';' ->
          let data =
            match !state with
            | Undef -> D.set {r = !row; c = !col} {value = Undefined} data
            | Val -> D.set {r = !row; c = !col} {value = Int !d} data
            | Formula -> data
          in
          incr col;
          state := Undef;
          data, graph
        | '\n' ->
          incr row;
          col := 0;
          state := Undef;
          D.set {r = !row; c = !col} {value = Undefined} data, graph
        | '=' -> data, read_formula graph
        | _ -> failwith "Incorrect syntax")
        |> read
      with End_of_file -> data, graph
    in
    read (D.create 16 16, Graph.empty)

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
