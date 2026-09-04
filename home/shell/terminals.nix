{ pkgs, ... }:

{
  home.packages = [ pkgs.alacritty ];

  # Ghostty is the main terminal.
  programs.ghostty = {
    enable = true;
    settings = {
      # Native Wayland by default; theme follows later, with use.
    };
  };

  # Kitty is also used by a few application integrations.
  programs.kitty = {
    enable = true;
    settings = {
      confirm_os_window_close = 0;
      background_opacity = "0.85";
      window_padding_width = 10;
    };
  };
}
