{ pkgs, lib, ... }:
{
  # TODO: Confirm whether pass/GPG should remain the personal secret store and
  # whether a terminal-only pinentry is the right prompt.
  home.packages = [ pkgs.pass ];

  programs.gpg.enable = true;

  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-curses;
    defaultCacheTtl = 3600;
    maxCacheTtl = 86400;
  };

  # Keep the agent's prompt attached to the current terminal.
  programs.zsh.initContent = lib.mkAfter ''
    export GPG_TTY=$TTY
    gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1 || true
  '';
}
