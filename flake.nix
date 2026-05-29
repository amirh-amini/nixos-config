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
  };

  outputs = { self, nixpkgs, home-manager, emacs-overlay, llm-agents, ... }@inputs: {
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
          { nixpkgs.overlays = [ emacs-overlay.overlays.default llm-agents.overlays.default ]; }
        ];
      };
    };
  };
}

