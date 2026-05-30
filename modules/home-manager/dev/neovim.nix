{ config, pkgs, lib, ... }:

# Neovim — the primary code editor (Emacs is now academic/org only).
#
# Design (see ~/.claude/plans/lively-inventing-oasis.md for the full rationale):
#   * The actual config is plain Lua living in the repo at `nvim/` and is
#     symlinked live into ~/.config/nvim. It is a STANDARD Neovim config: copy it
#     to any machine (even without Nix) and it works — lazy.nvim bootstraps and
#     downloads the plugins itself.
#   * On NixOS we use "as much Nix as possible": plugins come from `pkgs.vimPlugins`
#     (pinned, no network), language servers/formatters/linters are provided on
#     Neovim's PATH, and treesitter parsers are pre-built by Nix. None of mason's
#     dynamically-linked binaries (which don't run on NixOS) are involved.
#   * The Lua <-> Nix bridge is a single env var (NVIM_NIX_PLUGINS) pointing at a
#     generated table of `"owner/repo" -> /nix/store/path`. On a non-Nix machine
#     that env var is absent, so the same init.lua falls back to download mode.
#     (This is the lazy-nix-helper.nvim pattern, vendored so we depend on nobody.)

let
  # --- Language servers, formatters, linters, debug adapters -----------------
  # Scoped to Neovim's PATH via the wrapper below — deliberately NOT added to the
  # global profile (mirrors python-tools.nix's "no global Python" stance). Add a
  # tool here, reference it from the matching plugin in nvim/lua/.
  tools = with pkgs; [
    # Nix
    nixd
    nixfmt-rfc-style
    statix
    deadnix
    # Python  (basedpyright = better-inference pyright fork; ruff = lint + format)
    basedpyright
    ruff
    (python3.withPackages (ps: [ ps.debugpy ])) # nvim-dap-python adapter
    # Lua — for hacking on THIS config
    lua-language-server
    stylua
    # generic helpers a few plugins shell out to
    ripgrep
    fd
  ];

  # --- Treesitter: parsers + queries provided by Nix -------------------------
  # nixpkgs ships nvim-treesitter's `main` branch, where `.withPlugins` no longer
  # lands parsers in parser/ and queries live under runtime/queries/. So we
  # assemble the runtime ourselves: the base plugin (lua + queries) plus the
  # compiled grammar .so's from passthru.grammarPlugins, laid out where Neovim
  # actually scans them (top-level parser/ and queries/). Parsers are never
  # compiled at runtime here. Add a language => add one name to tsGrammars.
  tsGrammars = with pkgs.vimPlugins.nvim-treesitter.passthru.grammarPlugins; [
    python nix lua bash json yaml toml markdown markdown_inline
    vim vimdoc query regex gitcommit gitignore git_rebase diff dockerfile c comment
  ];
  treesitter = pkgs.runCommand "nvim-treesitter-bundle" { } ''
    cp -rs ${pkgs.vimPlugins.nvim-treesitter}/. $out
    chmod -R u+w $out
    mkdir -p $out/parser $out/queries
    for q in ${pkgs.vimPlugins.nvim-treesitter}/runtime/queries/*; do
      ln -sfn "$q" "$out/queries/$(basename "$q")"
    done
    ${lib.concatMapStringsSep "\n" (g: ''
      for so in ${g}/parser/*.so; do ln -sfn "$so" "$out/parser/$(basename "$so")"; done
    '') tsGrammars}
  '';

  # --- A few plugins not (yet) in nixpkgs, fetched from source ---------------
  buildPlug = { pname, owner, repo ? pname, rev, sha256 }:
    pkgs.vimUtils.buildVimPlugin {
      inherit pname;
      version = rev;
      src = pkgs.fetchFromGitHub { inherit owner repo rev sha256; };
      doCheck = false;
    };

  swenv-nvim = buildPlug {
    pname = "swenv.nvim";
    owner = "AckslD";
    repo = "swenv.nvim";
    rev = "4157de2619ec2e5c61c103fb6517845a0e04e558";
    sha256 = "0xb5pim08q18rrf2b3rvhnkcs436p7j8dhl0wirk7ylypvchansw";
  };
  nvim-lspimport = buildPlug {
    pname = "nvim-lspimport";
    owner = "stevanmilic";
    repo = "nvim-lspimport";
    rev = "9c1c61a5020faeb1863bb66eb4b2a9107e641876";
    sha256 = "1hfryga5cqrf8w71gmz82112m22ab32vxjl9j52jk0kdd6yax1qq";
  };
  camouflage-nvim = buildPlug {
    pname = "camouflage.nvim";
    owner = "zeybek";
    repo = "camouflage.nvim";
    rev = "1e0903ca9f484ac31b36151fa12eadd81c0ad12e";
    sha256 = "0kslnmasd1a0dar2d3qb41aknnqn2idpgycgysbmfgjbg9bnd4d5";
  };

  # --- The single source of truth for WHAT is installed ----------------------
  # Keyed by the EXACT "owner/repo" string used in the lazy.nvim specs, so the
  # Lua side can look each one up by the same key (no fragile name-guessing).
  vp = pkgs.vimPlugins;
  plugins = {
    # loader + QoL spine
    "folke/lazy.nvim" = vp.lazy-nvim;
    "folke/snacks.nvim" = vp.snacks-nvim;
    "nvim-mini/mini.nvim" = vp.mini-nvim;
    # shared deps
    "nvim-lua/plenary.nvim" = vp.plenary-nvim;
    "nvim-neotest/nvim-nio" = vp.nvim-nio;
    "kevinhwang91/promise-async" = vp.promise-async;
    "nvim-tree/nvim-web-devicons" = vp.nvim-web-devicons;
    # LSP & code intelligence
    "neovim/nvim-lspconfig" = vp.nvim-lspconfig;
    "folke/trouble.nvim" = vp.trouble-nvim;
    "j-hui/fidget.nvim" = vp.fidget-nvim;
    "folke/lazydev.nvim" = vp.lazydev-nvim;
    "b0o/SchemaStore.nvim" = vp.SchemaStore-nvim;
    "rmagatti/goto-preview" = vp.goto-preview;
    "smjonas/inc-rename.nvim" = vp.inc-rename-nvim;
    "rachartier/tiny-inline-diagnostic.nvim" = vp.tiny-inline-diagnostic-nvim;
    # completion + snippets + AI
    "saghen/blink.cmp" = vp.blink-cmp;
    "L3MON4D3/LuaSnip" = vp.luasnip;
    "rafamadriz/friendly-snippets" = vp.friendly-snippets;
    "olimorris/codecompanion.nvim" = vp.codecompanion-nvim;
    "milanglacier/minuet-ai.nvim" = vp.minuet-ai-nvim;
    # syntax
    "nvim-treesitter/nvim-treesitter" = treesitter;
    "nvim-treesitter/nvim-treesitter-textobjects" = vp.nvim-treesitter-textobjects;
    "nvim-treesitter/nvim-treesitter-context" = vp.nvim-treesitter-context;
    "calops/hmts.nvim" = vp.hmts-nvim;
    # navigation / files
    "stevearc/oil.nvim" = vp.oil-nvim;
    "folke/flash.nvim" = vp.flash-nvim;
    "ThePrimeagen/harpoon" = vp.harpoon2;
    "MagicDuck/grug-far.nvim" = vp.grug-far-nvim;
    "stevearc/aerial.nvim" = vp.aerial-nvim;
    "Bekaboo/dropbar.nvim" = vp.dropbar-nvim;
    "mrjones2014/smart-splits.nvim" = vp.smart-splits-nvim;
    # git
    "lewis6991/gitsigns.nvim" = vp.gitsigns-nvim;
    "NeogitOrg/neogit" = vp.neogit;
    "sindrets/diffview.nvim" = vp.diffview-nvim;
    # format / lint / debug / test
    "stevearc/conform.nvim" = vp.conform-nvim;
    "mfussenegger/nvim-lint" = vp.nvim-lint;
    "mfussenegger/nvim-dap" = vp.nvim-dap;
    "rcarriga/nvim-dap-ui" = vp.nvim-dap-ui;
    "theHamsta/nvim-dap-virtual-text" = vp.nvim-dap-virtual-text;
    "mfussenegger/nvim-dap-python" = vp.nvim-dap-python;
    "nvim-neotest/neotest" = vp.neotest;
    "nvim-neotest/neotest-python" = vp.neotest-python;
    # editing
    "folke/todo-comments.nvim" = vp.todo-comments-nvim;
    "monaqa/dial.nvim" = vp.dial-nvim;
    "chrisgrieser/nvim-various-textobjs" = vp.nvim-various-textobjs;
    "max397574/better-escape.nvim" = vp.better-escape-nvim;
    "Wansmer/treesj" = vp.treesj;
    "kevinhwang91/nvim-ufo" = vp.nvim-ufo;
    "RRethy/vim-illuminate" = vp.vim-illuminate;
    # keys / UI
    "folke/which-key.nvim" = vp.which-key-nvim;
    "nvim-lualine/lualine.nvim" = vp.lualine-nvim;
    "catppuccin/nvim" = vp.catppuccin-nvim;
    # python / nix / security / sessions
    "AckslD/swenv.nvim" = swenv-nvim;
    "stevanmilic/nvim-lspimport" = nvim-lspimport;
    "danymat/neogen" = vp.neogen;
    "figsoda/nix-develop.nvim" = vp.nix-develop-nvim;
    "zeybek/camouflage.nvim" = camouflage-nvim;
    "folke/persistence.nvim" = vp.persistence-nvim;
  };

  # --- Generate the Lua bridge table -----------------------------------------
  nixPluginsBridge = pkgs.writeText "nix_plugins.lua" ''
    -- AUTO-GENERATED by modules/home-manager/dev/neovim.nix. Do not edit.
    return {
      is_nix = true,
      plugins = {
    ${lib.concatStringsSep "\n" (lib.mapAttrsToList
        (name: drv: ''      ["${name}"] = "${drv}",'')
        plugins)}
      },
    }
  '';

  # --- Wrapped Neovim: tools on PATH + bridge env var ------------------------
  neovim = pkgs.symlinkJoin {
    name = "neovim-nix";
    paths = [ pkgs.neovim ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      rm -f "$out/bin/nvim"
      makeWrapper ${pkgs.neovim}/bin/nvim "$out/bin/nvim" \
        --set NVIM_NIX_PLUGINS ${nixPluginsBridge} \
        --prefix PATH : ${lib.makeBinPath tools}
      ln -sf "$out/bin/nvim" "$out/bin/vi"
      ln -sf "$out/bin/nvim" "$out/bin/vim"
      makeWrapper ${pkgs.neovim}/bin/nvim "$out/bin/vimdiff" \
        --set NVIM_NIX_PLUGINS ${nixPluginsBridge} \
        --prefix PATH : ${lib.makeBinPath tools} \
        --add-flags "-d"
    '';
  };
in
{
  home.packages = [ neovim ];

  # Live, editable config: a symlink to the working tree, so edits take effect
  # immediately with no rebuild. The dir is portable, standard Neovim Lua.
  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/nixos-config/nvim";

  # Local model endpoint for minuet-ai inline completion (private, no cloud —
  # matches the repo's supply-chain stance). CPU is fine for a small coder model.
  # One-time: `ollama pull qwen2.5-coder:3b`.
  services.ollama.enable = true;
}
