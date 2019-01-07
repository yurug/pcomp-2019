let rec string_to_list s = match s with
    | "" -> []
    | s -> (String.get s 0 ) :: (String.sub s 1 (String.length s - 1)
                                 |> string_to_list)

let are_anagrams s1 s2 =

  let rec are_same_lists l1 l2 = match l1,l2 with
    | [], [] -> true
    | h1::t1, h2::t2 when h1 = h2 -> are_same_lists t1 t2
    | _ -> false in

  let l1 = string_to_list s1 |> List.sort (Char.compare) in
  let l2 = string_to_list s2 |> List.sort (Char.compare) in
  are_same_lists l1 l2

let check_word log lines w =
  
  let rec check_word' = function
    | [] -> ()
    | h :: t when are_anagrams h w -> log h ; check_word' t
    | _ :: t -> check_word' t in
  
  log (w ^ ":") ; check_word' lines
  
let read_file p =

  let ic = open_in p in
          
  let rec build_list l =
    match input_line ic with
    | line -> build_list (line :: l)
    | exception End_of_file -> close_in ic ; List.rev l in
  
  build_list []

let usage = "usage: " ^ (Sys.argv.(0)) ^ " file w1 ... wn"
  
let main() = match read_file (Sys.argv.(1)) with
  | lines -> let params = Array.sub Sys.argv 2 (Array.length Sys.argv - 2) in
             Array.iter (check_word print_endline lines) params
  | exception Invalid_argument(_) -> prerr_endline usage
  | exception Sys_error(m) -> prerr_endline m ;;

main() ;;
