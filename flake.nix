{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # VS Code Marketplace and Open VSX extensions as Nix packages.
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # LazyVim with plugins sourced through Nix.
    lazyvim = {
      url = "github:pfassina/lazyvim-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Additional browsers not provided directly by nixpkgs.
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    helium = {
      url = "github:oxcl/nix-flake-helium-browser";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Community Linux packaging for the Codex desktop application.
    codex-desktop-linux.url = "github:ilysenko/codex-desktop-linux";

    # Keep Voxtype's CUDA package on its upstream nixpkgs revision to reuse its
    # expensive CUDA build artifacts.
    voxtype.url = "github:peteonrails/voxtype";
    voxtype.inputs.nixpkgs.url = "github:NixOS/nixpkgs/46db2e09e1d3f113a13c0d7b81e2f221c63b8ce9";

    # The small OSD frontend follows the system nixpkgs to avoid rebuilding an
    # older GTK dependency graph.
    voxtype-osd.url = "github:peteonrails/voxtype";
    voxtype-osd.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      llm-agents,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
    in
    {
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-tree;

      # Project starter: nix flake init -t ~/nixos-config#py
      templates.py = {
        path = ./templates/py;
        description = "Python (uv) dev shell with direnv auto-activation";
      };

      nixosConfigurations = {
        nixos-btw = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/main/configuration.nix
            inputs.home-manager.nixosModules.default
            {
              nixpkgs.overlays = [
                llm-agents.overlays.shared-nixpkgs
                inputs.helium.overlays.default
                (import ./packages)
                inputs.nix-vscode-extensions.overlays.default
              ];
            }
          ];
        };
      };

      packages.${system} =
        let
          pkgs = self.nixosConfigurations.nixos-btw.pkgs;
        in
        {
          inherit (pkgs)
            opencode2
            t3code-cli-nightly
            t3code-cli-stable
            t3code-desktop-nightly
            t3code-desktop-stable
            ;
        };

      checks.${system} =
        let
          pkgs = self.nixosConfigurations.nixos-btw.pkgs;
        in
        self.packages.${system}
        // {
          nixos = self.nixosConfigurations.nixos-btw.config.system.build.toplevel;

          formatting = pkgs.runCommand "nixfmt-check" { nativeBuildInputs = [ pkgs.nixfmt-tree ]; } ''
            cp -r ${self} source
            chmod -R u+w source
            cd source
            treefmt --ci --tree-root . --walk filesystem
            touch $out
          '';

          deadnix = pkgs.runCommand "deadnix-check" { nativeBuildInputs = [ pkgs.deadnix ]; } ''
            deadnix --fail ${self}
            touch $out
          '';

          statix = pkgs.runCommand "statix-check" { nativeBuildInputs = [ pkgs.statix ]; } ''
            cd ${self}
            statix check -i hosts/main/hardware-configuration.nix .
            touch $out
          '';
        };
    };
}
