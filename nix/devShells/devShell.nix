{
  pkgs,
  checks ? { },
  craneLib,
  binPkgs,
}:

craneLib.devShell {
  inherit checks;

  packages =
    with pkgs;
    with binPkgs;
    [
      cargo-flamegraph
      rust-analyzer

      emscripten
      jq
      tree-sitter

      # WASM-specific scripts
      update-wasm-app
      build-wasm-grammars
      build-languages-export
    ];
}
