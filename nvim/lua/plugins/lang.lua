-- Language-specific extras + a couple of stack-fit utilities.
return {
  -- Python virtualenv picker. direnv usually activates the env already, but this
  -- lets you switch without leaving Neovim (lightweight; uses vim.ui.select).
  {
    "AckslD/swenv.nvim",
    ft = "python",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
    keys = {
      { "<leader>cv", function() require("swenv.api").pick_venv() end, desc = "Pick Python venv" },
    },
  },

  -- Auto-resolve a missing import for the symbol under the cursor (basedpyright).
  {
    "stevanmilic/nvim-lspimport",
    ft = "python",
    keys = {
      { "<leader>ci", function() require("lspimport").import() end, desc = "Import symbol" },
    },
  },

  -- Generate docstrings / annotations.
  {
    "danymat/neogen",
    cmd = "Neogen",
    opts = { snippet_engine = "luasnip" },
    keys = {
      { "<leader>cn", function() require("neogen").generate() end, desc = "Generate annotation" },
    },
  },

  -- Enter Nix devshells without restarting Neovim (fits the direnv/devenv flow).
  {
    "figsoda/nix-develop.nvim",
    cmd = { "NixDevelop", "NixShell", "RiseAndShine" },
    keys = {
      { "<leader>nd", "<cmd>NixDevelop<cr>", desc = "nix develop" },
    },
  },

  -- Mask secrets in .env / config files — handy while screen-recording.
  {
    "zeybek/camouflage.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = { enabled = true },
  },
}
