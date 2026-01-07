{ pkgs, ... }:

{
  programs.waybar = {
    enable = true;
    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font";
        font-size: 14px;
      }
      window#waybar {
        background-color: rgba(36, 40, 59, 0.9);
        color: #c0caf5;
      }
    '';
  };
}

