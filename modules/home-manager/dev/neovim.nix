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

    # Treesitter parsers for the filetypes actually read/written here. Highlighting
    # only — LSP is deliberately NOT used (code is read, not hand-written). Nix/Lua
    # parsers come from lang.nix + LazyVim's base set.
    treesitterParsers = with pkgs.vimPlugins.nvim-treesitter-parsers; [
      markdown
      markdown_inline
      json
      yaml
      toml
      xml
      javascript
      typescript
      tsx
      html
      css
      c
      cpp
      csv
      bash
      python
    ];

    # Editor baseline: formatters for editing OUTSIDE a devenv project (loose files
    # in ~, this repo itself). Inside a project, each tool still picks up that
    # project's own config (e.g. rumdl reads rumdl.toml) so editor == pre-commit.
    # No LSP servers, no linters — formatting only (linting lives in project
    # pre-commit hooks). lua-language-server is kept only for editing this config.
    extraPackages = with pkgs; [
      lua-language-server
      stylua       # lua
      rumdl        # markdown
      prettier     # json/jsonc, yaml, html, css, ts/js
      taplo        # toml
      clang-tools  # c/cpp (clang-format)
      shfmt        # sh/bash
      libxml2      # xml (xmllint)
      ruff         # python
    ];

    # One formatter per filetype (conform.nvim). LazyVim autoformats on save by
    # default; <leader>cf formats on demand. txt/.env/csv have no formatter.
    plugins.conform = ''
      return {
        "stevearc/conform.nvim",
        opts = {
          formatters_by_ft = {
            markdown = { "rumdl" },
            json = { "prettier" },
            jsonc = { "prettier" },
            yaml = { "prettier" },
            toml = { "taplo" },
            xml = { "xmllint" },
            javascript = { "prettier" },
            javascriptreact = { "prettier" },
            typescript = { "prettier" },
            typescriptreact = { "prettier" },
            html = { "prettier" },
            css = { "prettier" },
            c = { "clang_format" },
            cpp = { "clang_format" },
            sh = { "shfmt" },
            bash = { "shfmt" },
            python = { "ruff_format" },
          },
        },
      }
    '';
  };

  # Local model endpoint for AI features (private, no cloud — matches the repo's
  # supply-chain stance).
  services.ollama.enable = true;
}
