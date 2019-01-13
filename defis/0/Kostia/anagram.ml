let dic = Sys.argv.(1)
let dic = open_in dic

let build_dic () =
  let rec aux () = try
      let line = input_line dic in
      line :: aux ()
    with _ -> []
  in
  let l = aux () in
  close_in dic; l

let dic = build_dic ()

(* https://gist.github.com/MassD/fa79de3a5ee88c9c5a8e *)
let ins_all_positions x l =
  let rec aux prev acc = function
    | [] -> (prev @ [x]) :: acc |> List.rev
    | hd::tl as l -> aux (prev @ [hd]) ((prev @ [x] @ l) :: acc) tl
  in
  aux [] [] l

let rec permutations = function
  | [] -> []
  | x::[] -> [[x]] (* we must specify this edge case *)
  | x::xs -> List.fold_left (fun acc p -> acc @ ins_all_positions x p ) [] (permutations xs)

(* https://stackoverflow.com/questions/10068713/string-to-list-of-char *)
let string_to_list s =
    let rec exp i l =
    if i < 0 then l else exp (i - 1) (s.[i] :: l) in
  exp (String.length s - 1) []

(* https://stackoverflow.com/questions/29957418/how-to-convert-char-list-to-string-in-ocaml *)
let rec list_to_string l =
  let buf = Buffer.create 16 in
  List.iter (Buffer.add_char buf) l;
  Buffer.contents buf

let rec memf a f = function
  | [] -> ()
  | h :: t ->
     if a = h
     then f h; memf a f t

let print x = print_string x; print_newline ()

let check =
  List.iter (fun word -> memf word print dic)

let () =
  for i = 2 to Array.length Sys.argv - 1 do
    let word = Sys.argv.(i) in
    let words = permutations (string_to_list word) in
    print_string (word ^ " :\n");
    check (List.map list_to_string words);
  done
