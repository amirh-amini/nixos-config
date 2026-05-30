-- LSP: Neovim 0.11 native client. Per-server configs live in nvim/lsp/*.lua
-- (merged with nvim-lspconfig's own lsp/ configs). Servers/tools are provided
-- by Nix on Neovim's PATH (see modules/home-manager/dev/neovim.nix); mason is
-- never used. Languages enabled now: Python, Nix, Lua. Add a server => add it to
-- `servers` below + a tools entry in neovim.nix + (optionally) an nvim/lsp/<n>.lua.
return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "saghen/blink.cmp",
      "b0o/SchemaStore.nvim", -- ready for json/yaml LSP when added
    },
    config = function()
      -- Completion capabilities from blink, applied to every server.
      local caps = vim.lsp.protocol.make_client_capabilities()
      local ok, blink = pcall(require, "blink.cmp")
      if ok then
        caps = blink.get_lsp_capabilities(caps)
      end
      vim.lsp.config("*", { capabilities = caps })

      -- Keymaps + per-buffer goodies on attach (augments 0.11 defaults:
      -- K hover, grn rename, gra code action, grr refs, gri impl, gO symbols).
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp_attach", { clear = true }),
        callback = function(ev)
          local buf = ev.buf
          local function map(lhs, rhs, desc, mode)
            vim.keymap.set(mode or "n", lhs, rhs, { buffer = buf, desc = desc })
          end
          map("gD", vim.lsp.buf.declaration, "Goto declaration")
          map("<leader>ca", vim.lsp.buf.code_action, "Code action", { "n", "v" })
          map("<leader>cl", vim.lsp.codelens.run, "Run codelens")
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client and client:supports_method("textDocument/inlayHint") then
            vim.lsp.inlay_hint.enable(true, { bufnr = buf })
            map("<leader>ch", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = buf }), { bufnr = buf })
            end, "Toggle inlay hints")
          end
        end,
      })

      vim.lsp.enable({ "lua_ls", "basedpyright", "ruff", "nixd" })
    end,
  },

  -- LSP progress spinner
  { "j-hui/fidget.nvim", event = "LspAttach", opts = {} },

  -- Diagnostics / references / quickfix in a tidy list
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = { focus = true },
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer diagnostics" },
      { "<leader>cs", "<cmd>Trouble symbols toggle<cr>", desc = "Symbols (Trouble)" },
      { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location list" },
      { "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix list" },
    },
  },

  -- Peek definition/references in a floating window (VS Code "peek")
  {
    "rmagatti/goto-preview",
    event = "LspAttach",
    opts = { default_mappings = false },
    keys = {
      { "gpd", function() require("goto-preview").goto_preview_definition() end, desc = "Peek definition" },
      { "gpr", function() require("goto-preview").goto_preview_references() end, desc = "Peek references" },
      { "gpi", function() require("goto-preview").goto_preview_implementation() end, desc = "Peek implementation" },
      { "gP", function() require("goto-preview").close_all_win() end, desc = "Close peek windows" },
    },
  },

  -- Rename with live preview
  {
    "smjonas/inc-rename.nvim",
    cmd = "IncRename",
    opts = {},
    keys = {
      { "<leader>cr", function() return ":IncRename " .. vim.fn.expand("<cword>") end, expr = true, desc = "Rename (preview)" },
    },
  },

  -- Configure lua_ls for editing this Neovim config (nvim runtime + plugin types)
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        { path = "snacks.nvim", words = { "Snacks" } },
      },
    },
  },
}
