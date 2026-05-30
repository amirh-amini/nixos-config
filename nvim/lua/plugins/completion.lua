-- Completion menu (blink.cmp) + snippets (LuaSnip). Inline AI ghost-text is
-- handled by minuet-ai in ai.lua (kept separate so the menu and the local-model
-- ghost-text don't fight each other).
return {
  {
    "L3MON4D3/LuaSnip",
    dependencies = { "rafamadriz/friendly-snippets" },
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },

  {
    "saghen/blink.cmp",
    event = "InsertEnter",
    dependencies = { "L3MON4D3/LuaSnip" },
    opts = {
      snippets = { preset = "luasnip" },
      keymap = { preset = "default" }, -- <C-space> open, <C-y> accept, <C-n/p> select
      appearance = { nerd_font_variant = "mono" },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
        ghost_text = { enabled = false }, -- minuet owns ghost-text
        menu = { draw = { treesitter = { "lsp" } } },
      },
      signature = { enabled = true },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
  },
}
