{ pkgs, ... }:
{
  # Project environments own their Python runtimes and libraries.
  home.packages = [ pkgs.uv ];
}
