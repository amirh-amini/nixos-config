# Importable stand-in for nixpkgs, for consumers that do
# `import nixpkgs { ... }` (voxtype's flake does exactly that for its
# allowUnfree CUDA instance). It resolves to the same pinned revision as
# flake.nix with the crates.io fetch fix from ./overlay.nix merged in as a
# trailing overlay, so it cannot be overridden away by a caller.
args@{ overlays ? [ ], ... }:
import (builtins.fetchTarball {
  url = "https://github.com/NixOS/nixpkgs/archive/46db2e09e1d3f113a13c0d7b81e2f221c63b8ce9.tar.gz";
  # NOTE: GitHub regenerates archive tarballs non-deterministically, so this
  # hash can occasionally drift. If the fetch ever fails with a hash mismatch,
  # update it to the `got:` value nix prints.
  sha256 = "1dx1giygw794fhmzaw14xda3ghv5393fx1icx911ffxfmbdia472";
}) (args // { overlays = overlays ++ [ (import ./overlay.nix) ]; })
