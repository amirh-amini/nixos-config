{ pkgs, config, ... }:

let
  # Set this to the absolute path of your flake repo on disk.
  # mkOutOfStoreSymlink needs a real filesystem path, not a Nix store path,
  # so your config files remain writable for org-auto-tangle.
  flakePath = "/home/amirh/nixos-config";
  emacsDir = "${flakePath}/modules/home-manager/programs/emacs";
in
{
  programs.emacs = {
    enable = true;
    package = pkgs.emacs-pgtk;
    extraPackages = epkgs: with epkgs; [

      # ══════════════════════════════════════════════════════════
      # Total: 125 packages (119 external + 6 built-in)
      # Built-in packages are commented out but indexed for tracking.
      # ══════════════════════════════════════════════════════════


      # ── Phase 1 — Core Foundation (9) ─────────────────────────
      no-littering                   # 1
      gcmh                           # 2
      evil                           # 3
      evil-collection                # 4
      undo-fu                        # 5
      general                        # 6
      which-key                      # 7
      doom-themes                    # 8
      doom-modeline                  # 9
      evil-tutor


      # ── Phase 2 — Search, Help & Built-in QOL (8 | 5 ext) ────
      vertico                        # 10
      orderless                      # 11
      marginalia                     # 12
      consult                        # 13
      # savehist                     # 14 [BUILT-IN]
      # recentf                      # 15 [BUILT-IN]
      helpful                        # 16
      # saveplace                    # 17 [BUILT-IN]


      # ── Phase 3 — Writing & Version Control (8 | 6 ext) ──────
      org-auto-tangle                # 18
      org-modern                     # 19
      org-appear                     # 20
      evil-org                       # 21
      magit                          # 22
      jinx                           # 23
      # autorevert                   # 24 [BUILT-IN]
      # pixel-scroll-precision-mode  # 25 [BUILT-IN]
      toc-org 


      # ── Phase 4 — Editing Power & Contextual Actions (8) ─────
      embark                         # 26
      embark-consult                 # 27
      evil-surround                  # 28
      evil-snipe                     # 29
      evil-commentary                # 30
      evil-goggles                   # 31
      diff-hl                        # 32
      diminish                       # 33


      # ── Phase 5 — Typing Flow & Org Polish (8) ───────────────
      corfu                          # 34
      cape                           # 35
      org-fragtog                    # 36
      org-cliplink                   # 37
      visual-fill-column             # 38
      valign                         # 39
      beacon                         # 40
      hl-todo                        # 41


      # ── Phase 6 — Planning & Navigation (7) ──────────────────
      org-super-agenda               # 42
      org-pomodoro                   # 43
      alert                          # 44
      org-download                   # 45
      dashboard                      # 46
      evil-matchit                   # 47
      avy                            # 48


      # ── Phase 7 — Knowledge Network & Reading (7) ────────────
      org-roam                       # 49
      org-roam-ui                    # 50
      org-ql                         # 51
      pdf-tools                      # 52
      org-noter                      # 53
      ace-window                     # 54
      ace-link                       # 55


      # ── Phase 8 — Snippets & Project Awareness (8) ───────────
      yasnippet                      # 56
      yasnippet-snippets             # 57
      consult-yasnippet              # 58
      projectile                     # 59
      consult-projectile             # 60
      consult-dir                    # 61
      ws-butler                      # 62
      rainbow-delimiters             # 63


      # ── Phase 9 — Academic Publishing (7) ─────────────────────
      auctex                         # 64
      evil-tex                       # 65
      math-preview                   # 66
      citar                          # 67
      citar-embark                   # 68
      ox-pandoc                      # 69
      dslide                         # 70


      # ── Phase 10 — Grammar, Markup & File Browsing (8 | 7 ext)
      lsp-mode                       # 71
      lsp-ltex                       # 72
      markdown-mode                  # 73
      markdown-toc                   # 74
      # dired                        # 75 [BUILT-IN]
      diredfl                        # 76
      # dired-hacks                  # 77 — expanded into sub-packages below:
      dired-hacks-utils              #      └─ base dependency
      dired-subtree                  #      └─ toggle subdirectory as indented tree
      dired-filter                   #      └─ filter files by predicates
      dired-narrow                   #      └─ narrow dired to matching files
      dired-collapse                 #      └─ collapse single-child directories
      dired-ranger                   #      └─ multi-directory copy/move staging
      ligature                       # 78
      peep-dired  
      dired-open   


      # ── Phase 11 — File Trees & Git Mastery (8) ──────────────
      treemacs                       # 79
      treemacs-evil                  # 80
      treemacs-projectile            # 81
      treemacs-magit                 # 82
      forge                          # 83
      git-timemachine                # 84
      expand-region                  # 85
      puni                           # 86


      # ── Phase 12 — Code Intelligence (8) ─────────────────────
      lsp-ui                         # 87
      lsp-pyright                    # 88
      flycheck                       # 89
      consult-flycheck               # 90
      apheleia                       # 91
      treesit-auto                   # 92
      editorconfig                   # 93
      indent-bars                    # 94


      # ── Phase 13 — Development Ecosystem (8) ─────────────────
      lsp-treemacs                   # 95
      consult-lsp                    # 96
      dap-mode                       # 97
      jupyter                        # 98  NOTE: listed as emacs-jupyter, Nix attr is "jupyter"
      envrc                          # 99
      nix-mode                       # 100
      yaml-mode                      # 101
      dumb-jump                      # 102


      # ── Phase 14 — Evil Mastery & Text Surgery (10) ──────────
      evil-numbers                   # 103
      evil-exchange                  # 104
      evil-args                      # 105
      evil-visualstar                # 106
      evil-textobj-anyblock          # 107
      evil-lion                      # 108
      evil-mc                        # 109
      string-inflection              # 110
      drag-stuff                     # 111
      vundo                          # 112


      # ── Phase 15 — Workspaces & Terminal (7) ─────────────────
      persp-mode                     # 113
      popper                         # 114
      vterm                          # 115
      hydra                          # 116
      casual-suite                   # 117  NOTE: listed as casual, Nix attr is "casual-suite"
      prodigy                        # 118
      wgrep                          # 119
      vterm-toggle 


      # ── Phase 16 — Utilities & AI (6) ────────────────────────
      rainbow-mode                   # 120
      tldr                           # 121
      sudo-edit                      # 122
      restclient                     # 123
      el-patch                       # 124
      gptel                          # 125


      # ── Tree-sitter grammars (not counted — Nix-specific) ───
      treesit-grammars.with-all-grammars
    ];
  };

  # Symlink config files to ~/.config/emacs/ as writable files.
  xdg.configFile = {
    "emacs/early-init.el".source =
      config.lib.file.mkOutOfStoreSymlink "${emacsDir}/early-init.el";
    "emacs/init.el".source =
      config.lib.file.mkOutOfStoreSymlink "${emacsDir}/init.el";
    "emacs/config.org".source =
      config.lib.file.mkOutOfStoreSymlink "${emacsDir}/config.org";
  };

  # ── System tools that Emacs packages shell out to ────────────
  home.packages = with pkgs; [
    # Search & navigation (consult, projectile, wgrep)
    ripgrep
    fd

    # Git (magit, forge, diff-hl, git-timemachine)
    git

    # Document export (ox-pandoc)
    pandoc

    # LaTeX (auctex, org-fragtog, math-preview, org LaTeX export)
    texliveFull

    # Org-roam database backend
    sqlite

    # Spell checking (jinx)
    enchant2
    hunspellDicts.en_US

    # Python LSP (lsp-pyright)
    pyright

    # Grammar checking (lsp-ltex)
    ltex-ls

    # Python debugging (dap-mode)
    (python3.withPackages (ps: with ps; [
      debugpy
      jupyter
    ]))

    # Code formatting (apheleia)
    black
    ruff
    nixfmt-rfc-style

    # Nix language server
    nil
  ];
}
