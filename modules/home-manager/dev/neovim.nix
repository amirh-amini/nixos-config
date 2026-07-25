{ inputs, pkgs, ... }:

# Neovim = LazyVim, provisioned via lazyvim-nix (Emacs stays academic/org only).
#
# Why this shape (snapshot of the old hand-rolled config is at git tag
# `pre-nvchad-migration`):
#   * lazyvim-nix (pfassina/lazyvim-nix) is a home-manager module that installs
#     real upstream LazyVim, but sources every plugin from `pkgs.vimPlugins`
#     (hermetic — nothing is cloned from GitHub at runtime, unlike a stock
#     LazyVim). It also disables mason, since mason's prebuilt binaries don't run
#     on NixOS. This matches the repo's supply-chain stance.
#   * PER-PROJECT LSP BINARIES come from devenv, not from here. `languages.*.enable`
#     in a project's devenv puts pyright/ruff/tsserver/… on the shell PATH, and
#     nvim (launched from inside the direnv/devenv shell) attaches to whatever it
#     finds. So the language `extras` below are enabled for their EDITOR features
#     (LazyVim plugins + treesitter), while the actual tool binaries are left to
#     devenv where possible.
#   * `extraPackages` is only the editor baseline for editing OUTSIDE a project —
#     e.g. Lua LS + stylua for hacking on the LazyVim config itself.

{
  imports = [ inputs.lazyvim.homeManagerModules.default ];

  programs.lazyvim = {
    enable = true;

    # git, ripgrep, fd — the tools LazyVim's core (telescope, etc.) shells out to.
    installCoreDependencies = true;

    extras = {
      # Nix: enabled with its tooling since this repo is often edited outside any
      # devenv shell (bootstrapping the config itself).
      lang.nix.enable = true;
    };

    # Editor baseline: for hacking on the LazyVim Lua config outside a project.
    extraPackages = with pkgs; [
      lua-language-server
      stylua
    ];
  };

  # Local model endpoint for AI features (private, no cloud — matches the repo's
  # supply-chain stance).
  services.ollama.enable = true;
}
