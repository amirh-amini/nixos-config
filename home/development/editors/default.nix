{ pkgs, ... }:

{
  imports = [
    ./zed.nix
    ./neovim.nix
    ./vscode.nix
  ];

  home.packages = [ pkgs.gedit ];
}
