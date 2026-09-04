{ pkgs, ... }:
{
  # Project environments own their Python runtimes and libraries.
  # TODO: Add project templates for other language stacks when they are needed;
  # do not install language runtimes globally by default.
  home.packages = [ pkgs.uv ];
}
