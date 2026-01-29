{
  pkgs,
  advisory-db,
  craneLib,
}:

let
  inherit (pkgs.lib)
    fileset
    optional
    optionals
    makeOverridable
    ;

  wasmRustVersion = "1.77.2";
  wasmTarget = "wasm32-unknown-unknown";

  rustWithWasmTarget = pkgs.rust-bin.stable.${wasmRustVersion}.default.override {
    targets = [ wasmTarget ];
  };

  commonArgs = {
    pname = "topiary";

    src = fileset.toSource {
      root = ../..;
      fileset = fileset.unions [
        ../../Cargo.lock
        ../../Cargo.toml
        ../../src
        ../.
      ];
    };

    nativeBuildInputs =
      with pkgs;
      [
        binaryen
        wasm-bindgen-cli
        pkg-config
      ]
      ++ optionals stdenv.isDarwin [
        libiconv
      ];
  };

  cargoArtifacts = craneLib.buildDepsOnly commonArgs;

  # NB: we don't need to overlay our custom toolchain for the *entire*
  # pkgs (which would require rebuilding anything else which uses rust).
  # Instead, we just want to update the scope that crane will use by appending
  # our specific toolchain there.
  craneLibWasm = craneLib.overrideToolchain rustWithWasmTarget;

  clippy-wasm = craneLibWasm.cargoClippy (
    commonArgs
    // {
      inherit cargoArtifacts;
      cargoClippyExtraArgs = "--target ${wasmTarget} -- --deny warnings";
      passthru = { inherit craneLibWasm; };
    }
  );

  fmt = craneLib.cargoFmt commonArgs;

  topiary-playground = craneLibWasm.buildPackage (
    commonArgs
    // {
      inherit cargoArtifacts;
      pname = "topiary-playground";
      cargoExtraArgs = "--no-default-features --target ${wasmTarget}";

      # Tests currently need to be run via `cargo wasi` which
      # isn't packaged in nixpkgs yet...
      doCheck = false;

      postInstall = ''
        echo 'Removing unneeded dir'
        rm -rf $out/lib
        echo 'Running wasm-bindgen'
        wasm-bindgen --version
        wasm-bindgen --target web --out-dir $out target/wasm32-unknown-unknown/release/topiary_playground.wasm;
        echo 'Running wasm-opt'
        wasm-opt --version
        wasm-opt -Oz -o $out/output.wasm $out/topiary_playground_bg.wasm
        echo 'Overwriting topiary_playground_bg.wasm with the optimized file'
        mv $out/output.wasm $out/topiary_playground_bg.wasm

        # TODO: This should be done in CI
        # echo 'Extracting custom build outputs'
        # export LANGUAGES_EXPORT="$(ls -t target/wasm32-unknown-unknown/release/build/topiary-playground-*/out/languages_export.ts | head -1)"
        # cp $LANGUAGES_EXPORT $out/
      '';

      passthru = { inherit craneLibWasm; };
    }
  );

in
{
  inherit
    # passthru
    clippy-wasm
    fmt
    topiary-playground
    ;

  default = topiary-playground;
}
