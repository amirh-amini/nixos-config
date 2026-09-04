{
  # TODO: Define the desired prompt, history behavior, completion style, and
  # aliases before expanding this configuration.
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    initContent = ''
      eval "$(devenv hook zsh)"
    '';

    shellAliases = {
      ll = "ls -l";
      update = "sudo nixos-rebuild switch --flake ~/nixos-config#nixos-btw";
    };
  };
}
