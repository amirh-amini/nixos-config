-- AI layer.
--   * Agents (CodeCompanion over ACP): Claude Code / Codex / OpenCode / Pi. The
--     CLIs are already on PATH via modules/home-manager/dev/ai-tools.nix
--     (llm-agents overlay). ACP is the open standard these agents speak, giving
--     the same in-editor experience as the official VS Code extension.
--   * Inline ghost-text (minuet): a LOCAL model via Ollama — private, no cloud,
--     matching the repo's supply-chain stance. One-time: `ollama pull qwen2.5-coder:3b`.
return {
  {
    "olimorris/codecompanion.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
    cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions", "CodeCompanionCmd" },
    opts = {
      -- Default to Claude Code (you live in the Claude ecosystem). Switch agents
      -- inside the chat buffer with the adapter picker (`ga`). ACP adapters for
      -- codex / opencode / gemini are built in and reuse each CLI's own auth.
      strategies = {
        chat = { adapter = "claude_code" },
        inline = { adapter = "claude_code" },
      },
      display = {
        diff = { provider = "default" },
      },
    },
    keys = {
      { "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", mode = { "n", "v" }, desc = "AI chat (toggle)" },
      { "<leader>aa", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "AI actions" },
      { "<leader>ai", ":CodeCompanion ", mode = { "n", "v" }, desc = "AI inline prompt" },
      { "ga", "<cmd>CodeCompanionChat Add<cr>", mode = "v", desc = "Add selection to AI chat" },
    },
  },

  {
    "milanglacier/minuet-ai.nvim",
    event = "InsertEnter",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("minuet").setup({
        provider = "openai_fim_compatible",
        n_completions = 1,
        context_window = 1024,
        provider_options = {
          openai_fim_compatible = {
            -- Ollama needs no key; point api_key at any existing env var.
            api_key = "TERM",
            name = "Ollama",
            end_point = "http://localhost:11434/v1/completions",
            model = "qwen2.5-coder:3b",
            optional = { max_tokens = 256, top_p = 0.9 },
          },
        },
        virtualtext = {
          -- As-you-type ghost text for the languages you use now.
          auto_trigger_ft = { "python", "lua", "nix", "sh", "bash", "javascript", "typescript" },
          keymap = {
            accept = "<A-A>",
            accept_line = "<A-a>",
            prev = "<A-[>",
            next = "<A-]>",
            dismiss = "<A-e>",
          },
        },
      })
    end,
  },
}
