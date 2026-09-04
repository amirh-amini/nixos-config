{ pkgs, lib, ... }:

let
  marketplace = pkgs.vscode-marketplace;
  nixfmt = lib.getExe pkgs.nixfmt;
in
{
  home.packages = [
    pkgs.nixd
    pkgs.nixfmt
  ];

  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    mutableExtensionsDir = false;

    profiles.default = {
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = false;

      extensions = with marketplace; [
        ms-python.python
        ms-python.vscode-pylance
        charliermarsh.ruff
        esbenp.prettier-vscode
        jnoortheen.nix-ide
        barsikus007.nix-injection
        editorconfig.editorconfig
        aaron-bond.better-comments
        yzhang.markdown-all-in-one
        mhutchie.git-graph
        donjayamanne.githistory
        pkief.material-icon-theme
        azemoh.one-monokai
        monokai.theme-monokai-pro-vscode
        datakurre.devenv
        bowlerr.sqlite-intelliview-vscode
        anthropic.claude-code
        fedaykindev.openchamber
      ];

      userSettings = {
        "editor.fontFamily" = "'JetBrainsMono Nerd Font', 'Symbols Nerd Font', monospace";
        "editor.fontLigatures" = true;
        "editor.fontSize" = 12;

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
        "[nix]"."editor.defaultFormatter" = "jnoortheen.nix-ide";

        "nix.enableLanguageServer" = true;
        "nix.serverPath" = lib.getExe pkgs.nixd;
        "nix.formatterPath" = nixfmt;
        "nix.serverSettings"."nixd"."formatting"."command" = [ nixfmt ];

        "workbench.colorTheme" = "Monokai Pro (Filter Octagon)";
        "workbench.iconTheme" = "material-icon-theme";
        "editor.minimap.enabled" = false;
        "editor.rulers" = [ 80 ];

        "telemetry.telemetryLevel" = "off";
        "update.mode" = "none";
        "extensions.autoUpdate" = false;
        "extensions.autoCheckUpdates" = false;

        "editor.bracketPairColorization.enabled" = true;
        "editor.guides.bracketPairs" = "active";
        "editor.renderWhitespace" = "none";
        "files.autoSave" = "onFocusChange";
      };
    };
  };
}
