{ inputs, pkgs, ... }:

{
  # TODO: Revisit a personally maintained Neovim configuration later; keep
  # LazyVim as the working baseline for now.
  imports = [ inputs.lazyvim.homeManagerModules.default ];

  programs.lazyvim = {
    enable = true;

    installCoreDependencies = true;

    extras.lang.nix.enable = true;

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

    # Project shells provide project-specific language servers. This baseline
    # keeps formatting available for standalone files and this repository.
    extraPackages = with pkgs; [
      lua-language-server
      stylua
      rumdl
      prettier
      taplo
      clang-tools
      shfmt
      libxml2
      ruff
    ];

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
}
