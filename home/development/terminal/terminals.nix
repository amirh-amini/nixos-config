{
  programs = {
    # TODO: Decide whether Alacritty and Kitty are useful fallbacks or whether
    # Ghostty should be the only terminal.
    alacritty.enable = true;

    # TODO: Configure Ghostty once the desired behavior and appearance are clear.
    ghostty.enable = true;

    # Fuzzel and Qutebrowser currently use Kitty for terminal actions.
    kitty = {
      enable = true;
      settings = {
        confirm_os_window_close = 0;
        background_opacity = "0.85";
        window_padding_width = 10;
      };
    };
  };
}
