{ pkgs, inputs, ... }:
{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # devenv from its own flake (rolling `latest`), not nixpkgs — see the
  # devenv input in flake.nix for why it doesn't follow our nixpkgs.
  home.packages = [ inputs.devenv.packages.${pkgs.stdenv.hostPlatform.system}.devenv ];
}
