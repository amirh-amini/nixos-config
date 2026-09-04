{
  inputs,
  pkgs,
  ...
}:

{
  # Zen Browser — Firefox-based, on trial against Helium/Chrome.
  home.packages = [
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  # Zen as the system default browser (chrome/firefox stay installed).
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
