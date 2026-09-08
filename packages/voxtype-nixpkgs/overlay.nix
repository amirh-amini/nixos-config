# crates.io rate-limits its `/api/v1` download endpoint and intermittently
# answers Nix's fetches with HTTP 403 (rust-lang/crates.io#13482). Upstream
# nixpkgs switched the crates.io registry to the static CDN, which serves the
# identical checksum-verified tarballs at the same URL layout. The pinned
# nixpkgs revision this repo's voxtype uses predates that fix, so this overlay
# applies it (see packages/voxtype-nixpkgs/flake.nix).
#
# `importCargoLock` is not a top-level attribute in this revision: it is an
# attribute of the rustPlatform scope (pkgs/development/compilers/rust/
# make-rust-platform.nix), which is where rustPlatform.buildRustPackage
# resolves it from. So the fix is a scope override, not a package override.
#
# The override swaps in ./import-cargo-lock.nix — a copy of the pinned
# revision's file with the default registry map changed to static.crates.io.
# It cannot be done through `extraRegistries`: import-cargo-lock.nix always
# emits a `[source.crates-io]` block into the vendored .cargo/config.toml,
# and an extraRegistries entry for the same index URL would add a second
# definition of that source, which cargo rejects outright ("Sources are not
# allowed to be defined multiple times").
final: prev: {
  rustPlatform = prev.rustPlatform.overrideScope (
    self: super: {
      importCargoLock = self.callPackage ./import-cargo-lock.nix { };
    }
  );
}
