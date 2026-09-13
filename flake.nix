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

    # devenv CLI from upstream, rolling with their `latest` release tag.
    # Deliberately does NOT follow our nixpkgs: upstream prebuilds the CLI
    # against their own pinned nixpkgs and publishes it to their binary
    # cache, so following ours would force expensive local builds.
    devenv.url = "github:cachix/devenv/latest";

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
    # expensive CUDA build artifacts. The input goes through the wrapper flake
    # in packages/voxtype-nixpkgs, which wraps that exact revision with
    # upstream's static.crates.io crate fetch fix — the revision predates it,
    # and crates.io now intermittently 403s the endpoint it used.
    # Voxtype itself is pinned by rev: `nix flake update` never moves it. To
    # bump, edit the rev in both URLs below and rebuild — expect a long build
    # (crates re-vendor, whisper.cpp, CUDA), though onnxruntime and the CUDA
    # stack come from the pinned nixpkgs and stay cached.
    voxtype.url = "github:peteonrails/voxtype/e32510690636d1e082f2f02a5094efda4aa95fa0";
    voxtype.inputs.nixpkgs.url = "./packages/voxtype-nixpkgs";

    # The small OSD frontend follows the system nixpkgs to avoid rebuilding an
    # older GTK dependency graph. Pinned to the same rev as voxtype so the two
    # never skew.
    voxtype-osd.url = "github:peteonrails/voxtype/e32510690636d1e082f2f02a5094efda4aa95fa0";
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
            opencode2-desktop
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
