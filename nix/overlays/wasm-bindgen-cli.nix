final: _:

let
  inherit (builtins)
    elemAt
    filter
    fromTOML
    length
    map
    readFile
    ;

  cargoLock = fromTOML (readFile ../../Cargo.lock);
  wasmBindgenCargoVersions = map ({ version, ... }: version) (
    filter ({ name, ... }: name == "wasm-bindgen") cargoLock.package
  );
  wasmBindgenVersion =
    assert length wasmBindgenCargoVersions == 1;
    elemAt wasmBindgenCargoVersions 0;

in
{
  wasm-bindgen-cli = final.buildWasmBindgenCli rec {
    src = final.fetchCrate {
      pname = "wasm-bindgen-cli";
      version = wasmBindgenVersion;
      hash = "sha256-f/RK6s12ItqKJWJlA2WtOXtwX4Y0qa8bq/JHlLTAS3c=";
    };

    cargoDeps = final.rustPlatform.fetchCargoVendor {
      inherit src;
      pname = "${src.pname}-${src.version}";
      hash = "sha256-F97UDB2WV1AgaDWpptgumYo2VeiYgXuBZzw+wmCHUcE=";
    };
  };
}
