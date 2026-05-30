-- Python types/hover/completion. Linting + import-organising is delegated to
-- ruff (see ruff.lua), so basedpyright sticks to type analysis.
return {
  settings = {
    basedpyright = {
      analysis = {
        typeCheckingMode = "standard",
        autoImportCompletions = true,
        autoSearchPaths = true,
        diagnosticMode = "openFilesOnly",
        inlayHints = {
          variableTypes = true,
          functionReturnTypes = true,
          callArgumentNames = true,
        },
      },
    },
  },
}
