final: prev:

{
  tree-sitter = prev.tree-sitter.overrideAttrs (oldAttrs: rec {
    version = "0.22.6";

    src = final.fetchFromGitHub {
      owner = "tree-sitter";
      repo = "tree-sitter";
      rev = "v${version}";
      hash = "sha256-jBCKgDlvXwA7Z4GDBJ+aZc52zC+om30DtsZJuHado1s=";
    };

    # Fetch cargo dependencies for the correct version
    cargoDeps = final.rustPlatform.fetchCargoVendor {
      inherit src;
      name = "tree-sitter-${version}";
      hash = "sha256-EUMEYDXr5hdrBjaWr97WJnQZNjSUtV0FdAuyFGSfqPI=";
    };

    # Remove patches that don't apply to this older version
    patches = [ ];

    # Disable shell completion installation - not supported in v0.22.6
    postInstall = "";
  });
}
