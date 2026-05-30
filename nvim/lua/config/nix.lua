-- Nix <-> Lua bridge (dual-mode).
--
-- On NixOS the `nvim` wrapper sets $NVIM_NIX_PLUGINS to a generated Lua file
-- mapping "owner/repo" -> /nix/store path (see modules/home-manager/dev/neovim.nix).
-- Off Nix, the env var is absent and everything below is inert, so lazy.nvim
-- downloads plugins from GitHub as usual. This is the lazy-nix-helper pattern,
-- vendored here so the config depends on no external bridge plugin.

local M = {
  is_nix = false,
  plugins = {},
}

local uv = vim.uv or vim.loop
local bridge = os.getenv("NVIM_NIX_PLUGINS")
if bridge and uv.fs_stat(bridge) then
  local ok, data = pcall(dofile, bridge)
  if ok and type(data) == "table" then
    M.is_nix = data.is_nix == true
    M.plugins = data.plugins or {}
  end
end

--- Return the /nix/store directory for a plugin spec, or nil to let lazy fetch it.
--- @param repo string|nil  the "owner/repo" short URL used in the lazy spec
--- @return string|nil
function M.path(repo)
  if not repo then
    return nil
  end
  return M.plugins[repo]
end

_G.NIX = M
return M
