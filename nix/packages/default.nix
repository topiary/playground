{
  callPackageNoOverrides,
  advisory-db,
  craneLib,
}:

let
  binPkgs = callPackageNoOverrides ./bin.nix { };

  topiaryPkgs = callPackageNoOverrides ./topiary.nix {
    inherit advisory-db craneLib;
  };
in

{
  inherit topiaryPkgs binPkgs;
}
