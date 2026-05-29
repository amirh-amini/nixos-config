{ pkgs, ... }:
{
  # nix-ld provides the standard dynamic-linker shim (/lib64/ld-linux-*) so that
  # prebuilt binaries — Python wheels with native code, downloaded dev tools —
  # can run on NixOS without patching.
  #
  # Trade-off (deliberate): this re-opens the FHS "run any foreign binary" door
  # that NixOS normally closes. It is the price of using wheel-based tooling
  # (uv/pip). The install sandbox (../home-manager/dev/sandbox.nix) limits what
  # such binaries can actually touch.
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib # libstdc++ / libgcc_s — the single most common wheel need
      zlib
      zstd
      openssl
      curl
      glib
      util-linux
      libxml2
      libxslt
      bzip2
      xz
      ncurses
      readline
      libffi
      expat
      glibc
    ];
  };
}