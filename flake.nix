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

    # VS Code Marketplace + Open VSX extensions as Nix packages (daily-updated).
    # Pinned via flake.lock — bump deliberately with `nix flake update`.
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # LazyVim as a home-manager module, with plugins sourced from nixpkgs
    # (hermetic — no runtime cloning) and mason/treesitter/LSP handled via
    # declarative language extras. Per-project LSP *binaries* still come from
    # devenv's shell PATH. Pin a LazyVim release by tagging the URL, e.g.
    # `github:pfassina/lazyvim-nix/v15.13.0`.
    lazyvim = {
      url = "github:pfassina/lazyvim-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Browsers on trial (see home/browse/). Winners stay, losers get deleted.
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    helium = {
      url = "github:oxcl/nix-flake-helium-browser";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      llm-agents,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
    in
    {
      # Per-project dev-shell starters:  nix flake init -t ~/nixos-config#py
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
