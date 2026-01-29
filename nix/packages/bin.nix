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

  build-wasm-grammars = writeShellApplication {
    name = "build-wasm-grammars";

    runtimeInputs = [
      emscripten
      git
      jq
      nickel
      tree-sitter
    ];

    text = readFile ../../bin/build-wasm-grammars.sh;
  };

in
{
  inherit
    update-wasm-app
    build-wasm-grammars
    ;
}
