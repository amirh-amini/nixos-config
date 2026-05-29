{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # VS Code Marketplace + Open VSX extensions as Nix packages (daily-updated).
    # Pinned via flake.lock — bump deliberately with `nix flake update`.
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, emacs-overlay, llm-agents, ... }@inputs:
    let
      system = "x86_64-linux";
      # GuardDog (malicious-package scanner) packaged in Nix against nixpkgs
      # Semgrep — hermetic, no runtime PyPI pull. See ./pkgs/guarddog.nix.
      guarddogOverlay = final: prev: {
        guarddog = final.callPackage ./pkgs/guarddog.nix { };
      };
    in
    {
      # Per-project dev-shell starters:  nix flake init -t ~/nixos-config#py
      templates.py = {
        path = ./templates/py;
        description = "Python (uv) dev shell with direnv auto-activation";
      };

      # Build/test the scanner directly:  nix build .#guarddog
      packages.${system}.guarddog =
        (import nixpkgs {
          inherit system;
          overlays = [ guarddogOverlay ];
        }).guarddog;

      nixosConfigurations = {
        nixos-btw = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/main/configuration.nix
            inputs.home-manager.nixosModules.default
            {
              nixpkgs.overlays = [
                emacs-overlay.overlays.default
                llm-agents.overlays.default
                guarddogOverlay
                # Applied to *our* nixpkgs so unfree extensions (e.g. Pylance)
                # evaluate under our allowUnfree=true. Provides pkgs.vscode-marketplace.
                inputs.nix-vscode-extensions.overlays.default
              ];
            }
          ];
        };
      };
    };
}

