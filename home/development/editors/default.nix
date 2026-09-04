{ pkgs, ... }:

{
  imports = [
    ./zed.nix
    ./neovim.nix
    ./vscode.nix
  ];

  home.packages = [ pkgs.gedit ];
  # TODO: Decide whether Gedit is still useful as a lightweight GUI editor.
  # Nano is provided by NixOS and Vim is in the host recovery toolkit.
}
