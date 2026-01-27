{
  lib,
  stdenv,
  writeShellApplication,

  emscripten,
  git,
  nickel,
  tree-sitter,
  jq,
}:

let
  inherit (builtins)
    readFile
    ;

  update-wasm-app = writeShellApplication {
    name = "update-wasm-app";

    text = readFile ../../bin/update-wasm-app.sh;
  };

  update-wasm-grammars = writeShellApplication {
    name = "update-wasm-grammars";

    runtimeInputs = [
      emscripten
      git
      jq
      nickel
      tree-sitter
    ];

    text = readFile ../../bin/update-wasm-grammars.sh;
  };

in
{
  inherit
    update-wasm-app
    update-wasm-grammars
    ;
}
