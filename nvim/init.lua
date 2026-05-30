-- Portable Neovim configuration.
--
-- This directory is a STANDARD Neovim config: clone it to ~/.config/nvim on any
-- machine and it works (lazy.nvim bootstraps and downloads plugins). On NixOS,
-- the `nvim` wrapper sets $NVIM_NIX_PLUGINS so plugins/tools come from the Nix
-- store instead (see modules/home-manager/dev/neovim.nix). The only Nix-aware
-- code is lua/config/nix.lua + the `dev` block in lua/config/lazy.lua — every
-- plugin spec below stays vanilla and portable.

-- Leader keys must be set before lazy.nvim loads.
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("config.nix")
require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")
