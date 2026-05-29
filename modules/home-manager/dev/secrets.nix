{ pkgs, lib, ... }:
{
  # Secret management with `pass` (ZX2C4 password-store): GPG-encrypted, one file
  # per secret, inspectable, git-syncable, no daemon black-box. This replaces
  # putting tokens in env vars / ~/.zshrc (which any process — including a
  # malicious post-install — can read via `printenv`).
  #
  # One-time setup:
  #   gpg --quick-generate-key "Your Name <you@example.com>"
  #   pass init <that-key-id>
  # Store a secret:   pass insert openai
  # Use in a project: add to the project's .envrc (git-ignored):
  #   export OPENAI_API_KEY=$(pass show openai)
  # The value then exists only inside that directory — never global.
  #
  # For git, prefer SSH (key in ~/.ssh) so there is no token to store at all.
  #
  # NOTE: polkit auth is handled by soteria (see modules/core/security.nix);
  # nothing here touches polkit. pinentry below is only GPG's passphrase prompt.
  home.packages = with pkgs; [
    pass
    gnupg
  ];

  programs.gpg.enable = true;

  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-curses; # terminal prompt; no GUI/GNOME/Qt deps
    defaultCacheTtl = 3600;
    maxCacheTtl = 86400;
  };

  # pinentry-curses draws the passphrase prompt on the current TTY, so gpg-agent
  # needs to know which one. $TTY is set by zsh.
  programs.zsh.initContent = lib.mkAfter ''
    export GPG_TTY=$TTY
    gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1 || true
  '';
}