let () =
    Printf.printf ": %d\n" @@ Wrapped_example.add_1 1; (* OK *)
    Printf.printf "result: %d\n" @@ Wrapped_example.Re_exposed.the_value; (* OK *)
    let _ = Wrapped_example.the_value in (* Unbound module Hidden *)
    (* let _ = Hidden.the_value in (1* Unbound module Hidden *1) *)
    ()
