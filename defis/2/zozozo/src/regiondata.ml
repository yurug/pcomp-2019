open Ast
open Bigarray

type t =
  { array : (int, int16_unsigned_elt, c_layout) Array2.t;
    fd : Unix.file_descr;
    name : string }

let undefined = 0xffff

let init id rows cols =
  let tm = Unix.localtime (Unix.time ()) in
  let name = id ^ Printf.sprintf "_%d%d%d_%d%d" tm.tm_year tm.tm_mon tm.tm_mday tm.tm_hour tm.tm_min in
  let fd = Unix.openfile name [Unix.O_RDWR; O_CREAT] 0o655 in
  let array = Unix.map_file fd int16_unsigned c_layout true [|rows; cols|]
  |> array2_of_genarray in
  Array2.fill array 0;
  {array; fd; name}

let free {fd; name; _} =
  Unix.close fd;
  Unix.unlink name

let get {array; _} pos =
  let r, c = Ast.pos pos in
  let v = Array2.get array r c in
  create_cell (if v = undefined then Undefined else Int v)

let set {array; _} pos {value} =
  let r, c = Ast.pos pos in
  match value with
  | Empty -> array.{r, c} <- 0
  | Undefined -> array.{r, c} <- undefined
  | Int i -> array.{r, c} <- i

let fold_rect f a (tl, br) region =
  let acc = ref a in
  let (r1, c1), (r2, c2) = pos tl, pos br in
  for i = r1 to c1 do
    for j = r2 to c2 do
      acc := f !acc (get region (build_pos i j))
    done
  done;
  !acc

let output_row ({array; _} as region) row oc =
  for j = 0 to Array2.dim2 array - 1 do
    match get region (build_pos row j) |> value with
    | Int i -> Printf.fprintf oc "%d;" i
    | Empty -> output_string oc "E;"
    | Undefined -> output_string oc "P;"
  done

let output ({array; _} as region) oc =
  for i = 0 to Array2.dim1 array - 1 do
    output_row region i oc;
    output_char oc '\n'
  done
