return {
  "ljsalvatierra/squire.nvim",
  opts = {
    provider = "ollama", -- (required) Replace with your preferred provider
    model = "qwq:32b", -- (required) Replace with your preferred model
    --api_key = "ollama", -- (optional) Replace with your API key or set an Env variable
    base_url = "http://192.168.1.197:11434", -- (optional) URL for the LLM provider
    keymaps = { -- (optional) Modify default keymaps
      check_grammar = { modes = { "v" }, key = "<leader>qg", desc = "Check Grammar" },
      rewrite = { modes = { "v" }, key = "<leader>qr", desc = "Rewrite Text" },
      shorten = { modes = { "v" }, key = "<leader>qs", desc = "Shorten Text" },
    },
  },
}
