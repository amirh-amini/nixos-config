-- Editing, motion, navigation, sessions.
return {
  -- mini.nvim: one plugin, several small modules (icons + editing essentials).
  -- Loaded eagerly (cheap) so icons are ready before other UI initialises.
  {
    "nvim-mini/mini.nvim",
    lazy = false,
    priority = 1100,
    config = function()
      require("mini.icons").setup()
      MiniIcons.mock_nvim_web_devicons()
      -- richer a/i text objects, incl. treesitter function/class objects (af/if, ac/ic)
      local ai = require("mini.ai")
      ai.setup({
        n_lines = 500,
        custom_textobjects = {
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
        },
      })
      require("mini.surround").setup() -- gsa/gsd/gsr to add/delete/replace surrounds
      require("mini.pairs").setup() -- autopairs
    end,
  },

  -- File explorer as an editable buffer
  {
    "stevearc/oil.nvim",
    lazy = false, -- so it can hijack netrw on directory args
    opts = {
      default_file_explorer = true,
      view_options = { show_hidden = true },
      keymaps = { ["q"] = "actions.close" },
    },
    keys = {
      { "-", "<cmd>Oil<cr>", desc = "Open parent directory (oil)" },
      { "<leader>e", "<cmd>Oil<cr>", desc = "File explorer (oil)" },
    },
  },

  -- Jump anywhere with labels
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
    },
  },

  -- Pin + jump to a handful of key files
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup()
      vim.keymap.set("n", "<leader>ha", function() harpoon:list():add() end, { desc = "Harpoon add" })
      vim.keymap.set("n", "<leader>hh", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon menu" })
      for i = 1, 4 do
        vim.keymap.set("n", "<leader>" .. i, function() harpoon:list():select(i) end, { desc = "Harpoon " .. i })
      end
    end,
  },

  -- Project-wide search & replace
  {
    "MagicDuck/grug-far.nvim",
    opts = {},
    keys = {
      { "<leader>sr", function() require("grug-far").open() end, desc = "Search & replace (project)" },
    },
  },

  -- Code symbol outline
  {
    "stevearc/aerial.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = { layout = { default_direction = "prefer_right" } },
    keys = {
      { "<leader>co", "<cmd>AerialToggle<cr>", desc = "Outline (aerial)" },
    },
  },

  -- Seamless split + tmux/zellij/kitty navigation
  {
    "mrjones2014/smart-splits.nvim",
    lazy = false,
    config = function()
      local ss = require("smart-splits")
      ss.setup()
      vim.keymap.set("n", "<C-h>", ss.move_cursor_left, { desc = "Window left" })
      vim.keymap.set("n", "<C-j>", ss.move_cursor_down, { desc = "Window down" })
      vim.keymap.set("n", "<C-k>", ss.move_cursor_up, { desc = "Window up" })
      vim.keymap.set("n", "<C-l>", ss.move_cursor_right, { desc = "Window right" })
      vim.keymap.set("n", "<A-h>", ss.resize_left)
      vim.keymap.set("n", "<A-j>", ss.resize_down)
      vim.keymap.set("n", "<A-k>", ss.resize_up)
      vim.keymap.set("n", "<A-l>", ss.resize_right)
    end,
  },

  -- Session persistence
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {},
    keys = {
      { "<leader>qs", function() require("persistence").load() end, desc = "Restore session" },
      { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore last session" },
      { "<leader>qd", function() require("persistence").stop() end, desc = "Don't save session" },
    },
  },

  -- Smart increment/decrement (numbers, dates, booleans, ...)
  {
    "monaqa/dial.nvim",
    keys = {
      { "<C-a>", function() require("dial.map").manipulate("increment", "normal") end, desc = "Increment" },
      { "<C-x>", function() require("dial.map").manipulate("decrement", "normal") end, desc = "Decrement" },
      { "<C-a>", function() require("dial.map").manipulate("increment", "visual") end, mode = "v" },
      { "<C-x>", function() require("dial.map").manipulate("decrement", "visual") end, mode = "v" },
    },
  },

  -- Split/join blocks of code (arrays, tables, args, ...)
  {
    "Wansmer/treesj",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = { use_default_keymaps = false },
    keys = {
      { "<leader>cj", function() require("treesj").toggle() end, desc = "Split/join block" },
    },
  },

  -- 30+ extra text objects
  {
    "chrisgrieser/nvim-various-textobjs",
    event = "VeryLazy",
    opts = { keymaps = { useDefaults = true } },
  },

  -- jk to leave insert/visual without delay
  {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    opts = {},
  },

  -- Highlight other occurrences of the word under the cursor
  {
    "RRethy/vim-illuminate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("illuminate").configure({ providers = { "lsp", "treesitter", "regex" } })
    end,
  },

  -- Better folds (LSP/treesitter based)
  {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    event = "BufReadPost",
    opts = {
      provider_selector = function()
        return { "treesitter", "indent" }
      end,
    },
    init = function()
      vim.o.foldcolumn = "1"
    end,
    config = function(_, opts)
      require("ufo").setup(opts)
      vim.keymap.set("n", "zR", require("ufo").openAllFolds, { desc = "Open all folds" })
      vim.keymap.set("n", "zM", require("ufo").closeAllFolds, { desc = "Close all folds" })
    end,
  },
}
