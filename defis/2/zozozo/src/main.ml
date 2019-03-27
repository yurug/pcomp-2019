let print_execution_time t0 tprep teval tuser =
  Format.eprintf "Global execution time (real): @.";
  Format.eprintf "  Preprocessing : %f s @." (tprep -. t0);
  Format.eprintf "  Fist  Eval    : %f s @." (teval -. tprep);
  Format.eprintf "  User changes  : %f s @." (tuser -. teval);
  Format.eprintf "Total         : %f s @." (tuser -. t0)

let parse_input argv =
  if Array.length argv = 5
  then argv.(1), argv.(2), argv.(3), argv.(4), false
  else if Array.length argv = 6
  then argv.(1), argv.(2), argv.(3), argv.(4), argv.(5) = "--verbose"
  else (
    prerr_endline "Usage: ws <data.csv> <user.txt> <view0.csv> <changes.txt>";
    exit 1 )

let debug_write_view_final view0_filename regions =
 let view_final =
    String.split_on_char '/' view0_filename
    |> List.rev
    |> (function
        | x :: xs ->
          let name = String.split_on_char '.' x
                     |> (function
                         | _ :: ext -> "viewfinal."^(String.concat "" ext)
                         | [] -> failwith "prout"
                       )
          in
          name :: xs
        | [] -> failwith "prout")
    |> List.rev
    |> String.concat "/"
  in
  Partitioner.recombine_regions view_final regions

let test_functory () =
  Functory.Cores.(
    let map x = x+1 in
    Format.printf "Creation@.";
    let a = Array.init 1000 (fun i -> i) in
    let l = Array.to_list a in
    let fold = (+) in
    let () = Format.printf "Calcul@." in
    let r = map_local_fold ~f:map ~fold 0 l in
    Format.printf "Result : %d@." r)

let main () =
  let data_filename, user_filename, view0_filename, change_filename, verbose  =
    parse_input Sys.argv in
  let max_nb_regions = 1000 in (* limitation du nombre de descripteur de fichier sous linux *)
  let min_region_size = 20 in (* A paramétrer avec benchmark *)
  let () = Functory.Cores.set_number_of_cores 4 in (* à paramétrer *)
  let t0 = Unix.gettimeofday () in
  let f, regions, g =
    Spreadsheet.preprocessing data_filename user_filename min_region_size max_nb_regions in
  let t1 = Unix.gettimeofday () in
  let _ = Spreadsheet.first_evaluation regions f g in
  let _ =  Partitioner.recombine_regions view0_filename regions in
  let t2 = Unix.gettimeofday () in
  let _ = Spreadsheet.eval_changes regions user_filename change_filename g in
    let t3 = Unix.gettimeofday () in
    let _ = Partitioner.free_all regions in
  if verbose then
    print_execution_time t0 t1 t2 t3
  else ()


let () = main ()
