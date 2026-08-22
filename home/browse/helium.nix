{
  pkgs,
  ...
}:

{
  # Helium Browser — Chromium-based, on trial against Zen/Chrome.
  # Exposed by the helium flake's overlay (flake.nix).
  home.packages = [
    pkgs.helium
  ];
}
