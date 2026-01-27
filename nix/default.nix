{
  pkgs ? import <nixpkgs> { },

  # The following dependencies are hard to provide without using flakes, making
  # our “you don't have to use flakes” claim deceptive. We keep it like this for
  # now, and if someone complains we can find another solution. Context in
  # https://github.com/topiary/topiary/pull/1026#discussion_r2131778007
  advisory-db,
  crane,
  rust-overlay,
}:

let
  overlays = import ./overlays;

  pkgs' = pkgs.appendOverlays [
    overlays.wasm-bindgen-cli
    rust-overlay.overlays.default
  ];

  # A simpler version of `callPackage` that only works on files and does not
  # rely on `makeOverridable`, to avoid polluting the output.
  callPackageNoOverrides =
    file: args:
    let
      fn = import file;
      auto-args = builtins.intersectAttrs (builtins.functionArgs fn) pkgs';
      final-args = auto-args // args;
    in
    fn final-args;

  craneLib = crane.mkLib pkgs';

  inherit
    (callPackageNoOverrides ./packages {
      inherit
        advisory-db
        craneLib
        callPackageNoOverrides
        ;
    })
    topiaryPkgs
    binPkgs
    ;

  checks = callPackageNoOverrides ./checks {
    inherit topiaryPkgs;
  };

  devShells = callPackageNoOverrides ./devShells {
    inherit
      checks
      binPkgs
      topiaryPkgs
      ;
  };

in
{
  packages = topiaryPkgs // binPkgs;
  inherit checks devShells;
}
