-- lazy.nvim bootstrap + setup.
--
-- The `dev` block is what makes one config dual-mode: on NixOS every plugin is
-- treated as a local ("dev") plugin resolved to its /nix/store path, so nothing
-- is ever downloaded. Off Nix, `patterns` is empty, so lazy fetches from GitHub
-- normally. Plugin specs in lua/plugins/ stay completely vanilla.

local nix = require("config.nix")
local uv = vim.uv or vim.loop

-- Bootstrap lazy.nvim itself (Nix store path if present, else clone once).
local lazypath = nix.path("folke/lazy.nvim")
if not lazypath then
  lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  if not uv.fs_stat(lazypath) then
    local out = vim.fn.system({
      "git", "clone", "--filter=blob:none", "--branch=stable",
      "https://github.com/folke/lazy.nvim.git", lazypath,
    })
    if vim.v.shell_error ~= 0 then
      vim.api.nvim_echo({ { "Failed to clone lazy.nvim:\n", "ErrorMsg" }, { out } }, true, {})
      os.exit(1)
    end
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = { { import = "plugins" } },
  dev = {
    -- Resolve each plugin to its Nix store path. lazy strips plugin[1] by the
    -- time this runs, so derive "owner/repo" from plugin.url. Unknown plugins
    -- get a bogus path => fallback to a normal git fetch.
    path = function(plugin)
      local repo = plugin[1]
      if (not repo or not nix.path(repo)) and plugin.url then
        repo = plugin.url:gsub("%.git$", ""):match("([^/]+/[^/]+)$")
      end
      return nix.path(repo) or ("/nonexistent/" .. (plugin.name or "x"))
    end,
    -- On Nix, "" matches every plugin => all are local. Off Nix, none are.
    patterns = nix.is_nix and { "" } or {},
    fallback = true,
  },
  -- Nix manages plugin versions; off Nix, update manually with :Lazy update.
  checker = { enabled = false },
  change_detection = { notify = false },
  rocks = { enabled = false },
  ui = { border = "rounded" },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip", "tarPlugin", "tutor", "zipPlugin", "netrwPlugin", "rplugin",
      },
    },
  },
})

vim.keymap.set("n", "<leader>L", "<cmd>Lazy<cr>", { desc = "Lazy plugin manager" })
