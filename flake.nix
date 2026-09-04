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

    # ChatGPT/Codex desktop for Linux — community repackaging of OpenAI's
    # official signed .deb, with the computer-use feature we want.
    codex-desktop-linux.url = "github:ilysenko/codex-desktop-linux";

    # Voxtype dictation — upstream flake; the `onnx-cuda` package carries the
    # Cohere engine on NVIDIA GPUs via ONNX Runtime's CUDA provider.
    # Pin voxtype's nixpkgs to the exact revision its CUDA chain was built
    # against (from upstream's own flake.lock): keeps the multi-hour
    # nvcc/Rust-LTO store outputs reusable byte-for-byte. Bumping this =
    # signing up for a full local rebuild.
    voxtype.url = "github:peteonrails/voxtype";
    voxtype.inputs.nixpkgs.url = "github:NixOS/nixpkgs/46db2e09e1d3f113a13c0d7b81e2f221c63b8ce9";

    # Twin input for the OSD frontend only — follows our nixpkgs so its
    # GTK4 world matches what's already in the store (the pinned input
    # above would rebuild ~1300 GUI deps for one small waveform app).
    voxtype-osd.url = "github:peteonrails/voxtype";
    voxtype-osd.inputs.nixpkgs.follows = "nixpkgs";
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
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt;

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
                (import ./overlays/t3code.nix)
                (import ./overlays/opencode2)
                # Applied to *our* nixpkgs so unfree extensions (e.g. Pylance)
                # evaluate under our allowUnfree=true. Provides pkgs.vscode-marketplace.
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

      checks.${system} = self.packages.${system} // {
        nixos = self.nixosConfigurations.nixos-btw.config.system.build.toplevel;
      };
    };
}
