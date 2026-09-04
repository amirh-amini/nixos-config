{
  inputs,
  pkgs,
  ...
}:

{
  imports = [ ./qutebrowser.nix ];

  # TODO: Decide which browser policies, profiles, extensions, search engines,
  # and shortcuts should be declarative before enabling Zen's Home Manager module.
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
