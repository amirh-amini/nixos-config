-- UI: colorscheme, statusline, breadcrumbs, which-key, snacks QoL suite,
-- inline diagnostics, TODO comments.
return {
  -- Colorscheme (placeholder default — swap freely)
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    opts = {
      flavour = "mocha",
      integrations = {
        blink_cmp = true,
        gitsigns = true,
        neogit = true,
        snacks = true,
        treesitter = true,
        which_key = true,
        dap = true,
        dap_ui = true,
        neotest = true,
        aerial = true,
        mini = { enabled = true },
        native_lsp = { enabled = true },
      },
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  -- which-key: discover keybindings (SPC menus, like Doom/Spacemacs)
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "helix",
      spec = {
        { "<leader>b", group = "buffer" },
        { "<leader>c", group = "code" },
        { "<leader>f", group = "find" },
        { "<leader>g", group = "git" },
        { "<leader>s", group = "search" },
        { "<leader>t", group = "test/term" },
        { "<leader>x", group = "diagnostics/quickfix" },
        { "<leader>a", group = "ai" },
        { "<leader>n", group = "nix" },
        { "<leader>d", group = "debug" },
        { "<leader>h", group = "harpoon" },
      },
    },
    keys = {
      { "<leader>?", function() require("which-key").show({ global = false }) end, desc = "Buffer keymaps" },
    },
  },

  -- snacks: one dependency that replaces ~8 plugins (picker, notifier, dashboard,
  -- indent guides, terminal, scratch, zen, big-file handling, image preview, ...).
  {
    "folke/snacks.nvim",
    priority = 900,
    lazy = false,
    opts = {
      bigfile = { enabled = true },
      quickfile = { enabled = true },
      indent = { enabled = true },
      input = { enabled = true },
      notifier = { enabled = true },
      scope = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = true },
      image = { enabled = true }, -- inline images via kitty graphics
      dashboard = {
        enabled = true,
        preset = {
          keys = {
            { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.picker.files()" },
            { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
            { icon = " ", key = "g", desc = "Grep", action = ":lua Snacks.picker.grep()" },
            { icon = " ", key = "r", desc = "Recent", action = ":lua Snacks.picker.recent()" },
            { icon = " ", key = "s", desc = "Restore Session", action = function() require("persistence").load() end },
            { icon = " ", key = "L", desc = "Lazy", action = ":Lazy" },
            { icon = " ", key = "q", desc = "Quit", action = ":qa" },
          },
        },
      },
      picker = { enabled = true },
      terminal = {},
    },
    keys = {
      -- find / search (picker)
      { "<leader><space>", function() Snacks.picker.smart() end, desc = "Smart find files" },
      { "<leader>ff", function() Snacks.picker.files() end, desc = "Files" },
      { "<leader>fg", function() Snacks.picker.grep() end, desc = "Grep" },
      { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
      { "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent" },
      { "<leader>fh", function() Snacks.picker.help() end, desc = "Help" },
      { "<leader>fk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
      { "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Config files" },
      { "<leader>:", function() Snacks.picker.command_history() end, desc = "Command history" },
      { "<leader>sd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
      { "<leader>ss", function() Snacks.picker.lsp_symbols() end, desc = "Document symbols" },
      { "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "Workspace symbols" },
      { "<leader>sw", function() Snacks.picker.grep_word() end, desc = "Word under cursor", mode = { "n", "x" } },
      { 'gd', function() Snacks.picker.lsp_definitions() end, desc = "Goto definition" },
      { 'grr', function() Snacks.picker.lsp_references() end, nowait = true, desc = "References" },
      -- terminal / notifications / misc
      { "<leader>tt", function() Snacks.terminal() end, desc = "Terminal", mode = { "n" } },
      { "<c-/>", function() Snacks.terminal() end, desc = "Terminal", mode = { "n", "t" } },
      { "<leader>n", function() Snacks.notifier.show_history() end, desc = "Notification history" },
      { "<leader>.", function() Snacks.scratch() end, desc = "Scratch buffer" },
      { "<leader>z", function() Snacks.zen() end, desc = "Zen mode" },
      { "]]", function() Snacks.words.jump(vim.v.count1) end, desc = "Next reference", mode = { "n", "t" } },
      { "[[", function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev reference", mode = { "n", "t" } },
    },
  },

  -- statusline
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        theme = "catppuccin",
        globalstatus = true,
        section_separators = "",
        component_separators = "",
      },
      sections = {
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "diagnostics", "diff", "encoding", "filetype" },
      },
    },
  },

  -- IDE-like breadcrumbs in the winbar
  {
    "Bekaboo/dropbar.nvim",
    event = "BufReadPost",
    opts = {},
    keys = {
      { "<leader>;", function() require("dropbar.api").pick() end, desc = "Pick breadcrumb" },
    },
  },

  -- prettier inline diagnostics at the cursor
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "LspAttach",
    priority = 1000,
    opts = { preset = "modern", options = { show_source = { enabled = true } } },
  },

  -- TODO/FIXME/NOTE highlighting + search
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
    keys = {
      { "<leader>st", function() Snacks.picker.todo_comments() end, desc = "TODOs" },
      { "]t", function() require("todo-comments").jump_next() end, desc = "Next TODO" },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "Prev TODO" },
    },
  },
}
