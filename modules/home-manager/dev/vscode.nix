{ pkgs, lib, ... }:
let
  # VS Code Marketplace extensions, provided by the nix-vscode-extensions overlay
  # (applied to our nixpkgs in flake.nix, so unfree ones like Pylance are allowed).
  # Pinned via flake.lock (no surprise auto-updates); bump with `nix flake update`.
  marketplace = pkgs.vscode-marketplace;

  nixfmt = lib.getExe pkgs.nixfmt-rfc-style;
in
{
  # CLI tools the Nix IDE extension shells out to (also handy on the command line).
  home.packages = [
    pkgs.nixd
    pkgs.nixfmt-rfc-style
  ];

  programs.vscode = {
    enable = true;
    package = pkgs.vscode; # Microsoft build (Pylance is licensed only for this)

    # Fully declarative: the extensions dir is Nix-managed and read-only, so the
    # set below is exactly what's installed — reproducible and tamper-evident.
    mutableExtensionsDir = false;

    profiles.default = {
      # Nix owns versions; never auto-update (the supply-chain control).
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = false;

      # Every extension below was GuardDog-scanned (see plan). All clean or
      # source-verified false positives.
      extensions = with marketplace; [
        # Python
        ms-python.python
        ms-python.vscode-pylance
        charliermarsh.ruff
        # Web / JS / TS / JSON / Markdown formatting
        esbenp.prettier-vscode
        # Nix
        jnoortheen.nix-ide
        # Editor quality-of-life
        editorconfig.editorconfig
        usernamehw.errorlens
        gruntfuggly.todo-tree
        streetsidesoftware.code-spell-checker
        humao.rest-client
        # Git
        mhutchie.git-graph
        # Look & feel
        pkief.material-icon-theme
        sainnhe.sonokai
        # Per-project env (reads .envrc, like our direnv setup)
        mkhl.direnv
      ];

      userSettings = {
        # ── Font (mirrors Emacs: JetBrainsMono Nerd Font + ligatures) ──
        "editor.fontFamily" = "'JetBrainsMono Nerd Font', 'Symbols Nerd Font', monospace";
        "editor.fontLigatures" = true;
        "editor.fontSize" = 14;

        # ── Indentation (mirrors Emacs: 4 spaces) ──
        "editor.tabSize" = 4;
        "editor.insertSpaces" = true;
        "files.trimTrailingWhitespace" = true;
        "files.insertFinalNewline" = true;

        # ── Format on save (mirrors apheleia) ──
        "editor.formatOnSave" = true;
        "[python]" = {
          "editor.defaultFormatter" = "charliermarsh.ruff";
          "editor.codeActionsOnSave" = {
            "source.organizeImports" = "explicit";
            "source.fixAll" = "explicit";
          };
        };
        "[javascript]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
        "[javascriptreact]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
        "[typescript]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
        "[typescriptreact]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
        "[json]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
        "[jsonc]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
        "[html]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
        "[css]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
        "[markdown]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
        "[nix]"."editor.defaultFormatter" = "jnoortheen.nix-ide";

        # ── Nix IDE → nixd language server + nixfmt formatter ──
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = lib.getExe pkgs.nixd;
        "nix.formatterPath" = nixfmt;
        "nix.serverSettings"."nixd"."formatting"."command" = [ nixfmt ];

        # ── Look & feel (Sonokai + material icons) ──
        "workbench.colorTheme" = "Sonokai";
        "workbench.iconTheme" = "material-icon-theme";

        # ── Privacy / no auto-update (Nix owns versions) ──
        "telemetry.telemetryLevel" = "off";
        "update.mode" = "none";
        "extensions.autoUpdate" = false;
        "extensions.autoCheckUpdates" = false;

        # ── Quality-of-life (mirrors rainbow-delimiters, hl-todo, etc.) ──
        "editor.bracketPairColorization.enabled" = true;
        "editor.guides.bracketPairs" = "active";
        "editor.stickyScroll.enabled" = true;
        "editor.renderWhitespace" = "boundary";
        "files.autoSave" = "onFocusChange";
        "todo-tree.general.tags" = [ "TODO" "FIXME" "HACK" "NOTE" "BUG" "XXX" ];
      };
    };
  };
}
