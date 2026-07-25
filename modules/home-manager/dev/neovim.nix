{ inputs, pkgs, ... }:

# Neovim = NvChad, provisioned via nix4nvchad (Emacs stays academic/org only).
#
# Why this shape (see the migration on branch nix4nvchad; snapshot of the old
# hand-rolled config is at git tag `pre-nvchad-migration`):
#   * nix4nvchad wraps `nvim` and copies an NvChad config into ~/.config/nvim on
#     `home-manager switch` (hm-activation = true). Declarative + reproducible.
#   * No mason. mason ships prebuilt, dynamically-linked binaries that don't run
#     on NixOS — the reason the old config needed a whole Nix<->Lua bridge.
#   * PER-PROJECT LSPs come from devenv, not from here. `languages.*.enable` in a
#     project's devenv puts pyright/ruff/tsserver/… on the shell PATH, and nvim
#     (launched from inside the direnv/devenv shell) attaches to whatever it finds.
#   * So `extraPackages` below is only the EDITOR BASELINE: tools you want when
#     editing outside any project — Lua/Nix LSP for hacking configs, formatters,
#     and the fuzzy-finder's search tools. Add per-language servers to the
#     relevant project's devenv instead of here.

{
  imports = [ inputs.nix4nvchad.homeManagerModules.default ];

  programs.nvchad = {
    enable = true;

    # Editor-baseline tooling only (see header). Injected onto nvim's PATH by the
    # wrapper — deliberately not on the global profile.
    extraPackages = with pkgs; [
      ripgrep
      fd
      # Lua — for hacking on the NvChad config itself
      lua-language-server
      stylua
      # Nix — for editing this repo
      nixd
      nixfmt-rfc-style
    ];
  };

  # Local model endpoint for AI features / inline completion (private, no cloud —
  # matches the repo's supply-chain stance).
  services.ollama.enable = true;
}
