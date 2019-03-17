let div x y =
  if y = 0 then Nothing
  else Just (x/y)

let divM x y =
  if y = 0 then _raise
  else return (x/y)

let divM_1 x y1 y2 y3 =
  match divM x y1 with
  | Nothing -> Nothing
  | Just r1 ->
     match divM r1 y2 with
     | Nothing -> Nothing
     | Just r2 -> divM r2 y3

let divM_2 x y1 y2 y3 =
  bind (divM x y1)
    (fun r2 ->
      bind (divM r2 y2)
        (fun r3 -> divM r3 y3))

let divM_3 x y1 y2 y3 =
  divM x y1
  >>= fun r2 -> divM r2 y2
  >>= fun r3 -> divM r3 y3

let divM_4 x y1 y2 y3 =
  return x
  >>= fun r1 -> divM r1 y1
  >>= fun r2 -> divM r2 y2
  >>= fun r3 -> divM r3 y3
