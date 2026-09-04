{ inputs, ... }:

{
  imports = [
    inputs.codex-desktop-linux.homeManagerModules.default
    ./codex-desktop.nix
    ./packages.nix
  ];
}
