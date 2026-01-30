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
    build-wasm-grammars
    build-languages-export
    ;
}
