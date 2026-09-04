{ pkgs, ... }:

{
  home.packages = with pkgs; [
    grim
    slurp
    satty
  ];

  # Satty does not create its save directory.
  home.file."Pictures/Screenshots/.keep".text = "";

  xdg.configFile."satty/config.toml".text = ''
    [general]
    actions-on-enter = ["save-to-clipboard"]
    actions-on-escape = ["exit"]
    early-exit = true
    copy-command = "wl-copy"
    initial-tool = "brush"
    primary-highlighter = "block"
    corner-roundness = 8
    output-filename = "${"\${HOME}"}/Pictures/Screenshots/satty-%Y%m%d-%H%M%S.png"
    disable-notifications = false

    [font]
    family = "JetBrainsMono Nerd Font"
    style = "Regular"

    [color-palette]
    palette = [
      "#7aa2f7",
      "#f7768e",
      "#9ece6a",
      "#e0af68",
      "#bb9af7",
      "#c0caf5",
    ]
  '';
}
