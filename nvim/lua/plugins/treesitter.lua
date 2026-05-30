-- Treesitter (nixpkgs ships the `main` branch). Parsers are provided by Nix
-- (bundled in the plugin's parser/ dir, auto-discovered by Neovim core), so we
-- never install at runtime here — we just turn highlighting on per buffer.
return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
    config = function()
      pcall(function()
        require("nvim-treesitter").setup({})
      end)

      -- Enable highlighting (and treesitter folds via ufo) for any filetype that
      -- has a parser available on the runtimepath.
      local function start(buf)
        local ft = vim.bo[buf].filetype
        local lang = vim.treesitter.language.get_lang(ft)
        if not lang then
          return
        end
        if pcall(vim.treesitter.language.add, lang) then
          pcall(vim.treesitter.start, buf, lang)
        end
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("ts_highlight", { clear = true }),
        callback = function(args)
          start(args.buf)
        end,
      })
      -- catch buffers already open at startup
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) then
          start(buf)
        end
      end

      -- Treesitter-based text-object movement (select is handled by mini.ai).
      local ok, move = pcall(require, "nvim-treesitter-textobjects.move")
      if ok then
        local function m(key, fn, obj, desc)
          vim.keymap.set({ "n", "x", "o" }, key, function()
            fn(obj, "textobjects")
          end, { desc = desc })
        end
        m("]f", move.goto_next_start, "@function.outer", "Next function")
        m("[f", move.goto_previous_start, "@function.outer", "Prev function")
        m("]c", move.goto_next_start, "@class.outer", "Next class")
        m("[c", move.goto_previous_start, "@class.outer", "Prev class")
      end
    end,
  },

  -- Sticky context header showing the current function/class
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "BufReadPost",
    opts = { max_lines = 3 },
  },

  -- Treesitter queries for Home-Manager Nix files
  {
    "calops/hmts.nvim",
    ft = "nix",
  },
}
