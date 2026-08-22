{
  inputs,
  pkgs,
  ...
}:

{
  # Zen Browser — Firefox-based, on trial against Helium/Chrome.
  home.packages = [
    inputs.zen-browser.packages.${pkgs.system}.default
  ];
}
