{ inputs, ... }:

{
  imports = [
    inputs.codex-desktop-linux.homeManagerModules.default
    ./codex-desktop.nix
    ./ollama.nix
    ./packages.nix
  ];
}
