{ inputs, ... }:

{
  imports = [
    inputs.codex-desktop-linux.homeManagerModules.default
    ./codex-desktop.nix
    ./clients.nix
    ./operations.nix
    ./local-models.nix
  ];
}
