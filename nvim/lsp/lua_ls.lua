-- Override merged on top of nvim-lspconfig's lsp/lua_ls.lua. lazydev.nvim
-- supplies the Neovim runtime/plugin library, so we don't set workspace.library.
return {
  settings = {
    Lua = {
      workspace = { checkThirdParty = false },
      codeLens = { enable = true },
      completion = { callSnippet = "Replace" },
      hint = { enable = true },
      diagnostics = { globals = { "vim", "Snacks", "MiniIcons" } },
      doc = { privateName = { "^_" } },
    },
  },
}
