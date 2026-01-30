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

      # Playground-specific scripts
      build-wasm-grammars
      build-languages-export
    ];
}
