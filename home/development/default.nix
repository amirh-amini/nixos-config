{ inputs, ... }:

{
  imports = [
    ./git.nix
    ./direnv.nix
    ./python.nix
    ./editors.nix
    ./neovim.nix
    ./vscode.nix
    inputs.codex-desktop-linux.homeManagerModules.default
    ./codex-desktop.nix
    ./ai-tools.nix
  ];
}
