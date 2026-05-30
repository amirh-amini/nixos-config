-- Ruff LSP: linting, code actions, import organising. Hover is disabled so
-- basedpyright owns it (avoids duplicate/empty hovers).
return {
  on_attach = function(client, _)
    client.server_capabilities.hoverProvider = false
  end,
}
