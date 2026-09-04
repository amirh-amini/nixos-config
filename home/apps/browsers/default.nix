{
  inputs,
  pkgs,
  ...
}:

{
  imports = [ ./qutebrowser.nix ];

  # Zen is the primary browser; the others remain available as alternatives.
  home.packages = [
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    pkgs.helium
    pkgs.firefox
    pkgs.google-chrome
  ];

  # Zen handles web links by default.
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "zen-beta.desktop";
      "x-scheme-handler/http" = "zen-beta.desktop";
      "x-scheme-handler/https" = "zen-beta.desktop";
      "x-scheme-handler/about" = "zen-beta.desktop";
      "application/xhtml+xml" = "zen-beta.desktop";
    };
  };
}
