{
  callPackage,
  checks,
  binPkgs,
  topiaryPkgs,
}:

{
  default = callPackage ./devShell.nix {
    inherit binPkgs checks;
    craneLib = topiaryPkgs.clippy-wasm.passthru.craneLibWasm;
  };
}
