-- Nix LSP. Wired for completion of nixpkgs, NixOS, and Home-Manager options
-- against THIS flake (high-value since you live in this repo). The exprs are
-- best-effort: if evaluation fails, nixd degrades to basic LSP gracefully.
-- Formatting is delegated to conform (nixfmt-rfc-style); nixd's is a fallback.
local flake = "/home/amirh/nixos-config"
local host = "nixos-btw"
return {
  settings = {
    nixd = {
      nixpkgs = {
        expr = ("import (builtins.getFlake %q).inputs.nixpkgs { }"):format(flake),
      },
      formatting = { command = { "nixfmt" } },
      options = {
        nixos = {
          expr = ("(builtins.getFlake %q).nixosConfigurations.%s.options"):format(flake, host),
        },
        ["home-manager"] = {
          expr = ("(builtins.getFlake %q).nixosConfigurations.%s.options.home-manager.users.type.getSubOptions []"):format(flake, host),
        },
      },
    },
  },
}
