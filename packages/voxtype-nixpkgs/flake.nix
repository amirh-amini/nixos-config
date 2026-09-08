# Wrapper around the nixpkgs revision voxtype is pinned to. The pin (see
# flake.nix at the repo root) keeps voxtype's expensive CUDA build artifacts
# reusable, but that revision predates nixpkgs' switch of the crates.io
# registry to static.crates.io, and crates.io now intermittently 403s the API
# endpoint the old revision fetches from — which is exactly how voxtype's
# vendoring failed. This flake re-exports the same interface voxtype's flake
# consumes (lib, legacyPackages, and plain `import` via ./default.nix) with
# ./overlay.nix applied on top.
{
  inputs.pinned.url = "github:NixOS/nixpkgs/46db2e09e1d3f113a13c0d7b81e2f221c63b8ce9";

  outputs =
    { pinned, ... }:
    {
      lib = pinned.lib;

      legacyPackages = builtins.mapAttrs (
        system: _: import ./. { inherit system; }
      ) pinned.legacyPackages;
    };
}
