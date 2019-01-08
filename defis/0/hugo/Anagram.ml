let get_canon word =

  let rec string_to_list s = match s with
    | "" -> []
    | s -> (String.get s 0 ) :: (String.sub s 1 (String.length s - 1)
                               |> string_to_list) in

  string_to_list word |> List.sort (Char.compare)

let get_anagrams_table lines =

  let put_away hashtable word =
    let canon = get_canon word in
    match Hashtbl.find hashtable canon with
    | anagrams -> Hashtbl.replace hashtable canon (word :: anagrams)
    | exception Not_found -> Hashtbl.add hashtable canon [word] in
                                  
  let table = Hashtbl.create (List.length lines) in
  List.iter (put_away table) lines ;
  table
                                       
let log_anagrams log table word =
  let canon = get_canon word in
  log (word ^ ":") ;
  match Hashtbl.find table canon with
  | anagrams -> List.rev anagrams |> List.iter log
  | exception Not_found -> ()
                      
let read_file p =

  let ic = open_in p in
          
  let rec build_list l =
    match input_line ic with
    | line -> build_list (line :: l)
    | exception End_of_file -> close_in ic ; List.rev l in
  
  build_list []

let usage = "usage: " ^ (Sys.argv.(0)) ^ " file w1 ... wn"
  
let main() = match read_file (Sys.argv.(1)) with
  | lines ->
     let table = List.sort String.compare lines
                 |> get_anagrams_table in
     Array.sub Sys.argv 2 (Array.length Sys.argv - 2)
     |> Array.to_list
     |> List.iter (log_anagrams print_endline table)
  | exception Invalid_argument(_) -> prerr_endline usage
  | exception Sys_error(m) -> prerr_endline m ;;

main() ;;
