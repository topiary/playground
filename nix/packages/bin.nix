{
  lib,
  stdenv,
  writeShellApplication,

  emscripten,
  findutils,
  git,
  gnused,
  jq,
  nickel,
  tree-sitter,
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

  build-languages-export = writeShellApplication {
    name = "build-languages-export";

    runtimeInputs = [
      gnused
      findutils
    ];

    text = readFile ../../bin/build-languages-export.sh;
  };

in
{
  inherit
    update-wasm-app
    build-wasm-grammars
    build-languages-export
    ;
}
