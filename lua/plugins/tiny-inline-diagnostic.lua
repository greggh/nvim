return {
  "rachartier/tiny-inline-diagnostic.nvim",
  event = "VeryLazy", -- Or `LspAttach`
  priority = 1000, -- needs to be loaded in first
  config = function()
    require("tiny-inline-diagnostic").setup()
    -- Disable native diagnostics as we're using inline ones
    vim.diagnostic.config({ virtual_text = false })
  end,
}
