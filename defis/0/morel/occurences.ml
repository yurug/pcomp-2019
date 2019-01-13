module type COMPARABLE = sig
  type t
  val compare : t -> t -> int
end

module type S = sig
  type t

  module M : Map.S with type key = t

  val empty : 'a M.t

  val incr : int M.t -> t -> int M.t

  val decr : int M.t -> t -> int M.t

  val convert : t list -> int M.t

end

module Make (C:COMPARABLE) : S with type t =  C.t = struct

  type t = C.t

  module M = Map.Make(C)

  let empty = M.empty

  let incr map c =
    if M.mem c map then
      let occ = M.find c map in
      M.add c (occ+1) map
    else
      M.add c 1 map

  let decr map c =
    if M.mem c map then
      let occ = M.find c map in
      begin
        if occ > 1 then
          M.add c (occ-1) map
        else
          M.remove c map
      end
    else
      raise Not_found

  let convert l =
    List.fold_left incr M.empty l

end
