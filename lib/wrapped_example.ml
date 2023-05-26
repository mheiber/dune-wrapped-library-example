let add_1 = ( + ) Hidden.the_value (* Hidden is visible here but not from main.ml *)

module Re_exposed = Re_exposed (* We can re-expose modules: main.ml sees this *)
