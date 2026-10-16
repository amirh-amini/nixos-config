{ pkgs, ... }:
{
  # Compatibility layer for prebuilt development tools and Python wheels.
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

  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };
}
