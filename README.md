# Dune Wrapped Library Example

From [the dune docs](https://dune.readthedocs.io/en/stable/dune-files.html#library), about defining wrapped libraries (the default):

> For instance, the modules of a library named `foo` will be available as `Foo.XXX`, outside of foo itself; however, it is allowed to write an explicit Foo module, which will be the library interface. You are free to expose only the modules you want.

The point of this example is to investigate what happens in the `however` case.

## Details of the Example

We use a dune wrapped library to define a library interface
- The library name is "wrapped_example", given in `./lib/dune`
- "lib/wrapped_example.ml" defines the library interface


`tree -I _build` produces:

```
.
├── README.md
├── bin
│   ├── dune
│   └── main.ml
├── dune-project
├── lib
│   ├── dune
│   ├── hidden.ml
│   ├── re_exposed.ml
│   └── wrapped_example.ml
└── wrapped_example.opam
```

## Observable behavior

Here is bin/main.ml, showing that, of the modules in `lib`, only
`Wrapped_example` is visible:

```
let () =
    Printf.printf ": %d\n" @@ Wrapped_example.add_1 1; (* OK *)
    Printf.printf "result: %d\n" @@ Wrapped_example.Re_exposed.the_value; (* OK *)
    let _ = Wrapped_example.the_value in (* Unbound module Hidden *)
    (* let _ = Hidden.the_value in (1* Unbound module Hidden *1) *)
```

You can compile and run the code with dune exec -- ./bin/main.exe

As can be shown with un-commenting things in ./bin/main.ml, only
`Wrapped_example` is visible from `bin`. Well, almost. There are mangled names
also visible:

If I run `dune utop` then type `Wrapped_example`, the completions are:

`Wrapped_example│Wrapped_example__│Wrapped_example__Hidden│Wrapped_example__Re_exposed`


## Peeking at the _build directory

`tree _build` produces:

```
_build
├── default
│   ├── bin
│   │   ├── main.exe
│   │   ├── main.ml
│   │   └── main.mli
│   └── lib
│       ├── hidden.ml
│       ├── re_exposed.ml
│       ├── wrapped_example.a
│       ├── wrapped_example.cma
│       ├── wrapped_example.cmxa
│       ├── wrapped_example.ml
│       └── wrapped_example__.ml-gen
└── log
```


In the `_build/default/lib` directory, `wrapped_example.ml`, has a corresopnding `.a` and `.cmxa` and `__.ml-gen` but
the other modules in the library do not.

I don't know how to inspect the `.cma` and `.cmxa` files, but the others (and `dune utop`) hint at what's going on.

`cat _build/default/lib/wrapped_example__.ml-gen`

produces:

```
(* generated by dune *)

(** @canonical Wrapped_example.Hidden *)
module Hidden = Wrapped_example__Hidden

(** @canonical Wrapped_example.Re_exposed *)
module Re_exposed = Wrapped_example__Re_exposed

module Wrapped_example__ = struct end
[@@deprecated "this module is shadowed"]
```


`otool -tV _build/default/lib/wrapped_example.a | grep __entry:`

produces:

```
_camlWrapped_example____entry:
_camlWrapped_example__Hidden__entry:
_camlWrapped_example__entry:
```

