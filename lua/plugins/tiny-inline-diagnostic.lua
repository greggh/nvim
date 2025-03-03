return {
  "rachartier/tiny-inline-diagnostic.nvim",
  event = "LspAttach", -- More targeted than VeryLazy
  priority = 1000, -- needs to be loaded in first
  config = function()
    require("tiny-inline-diagnostic").setup({
      ignored_filetypes = vim.g.ignore_filetypes,
      style = {
        underline = {
          severity = {
            min = vim.diagnostic.severity.ERROR,
            max = vim.diagnostic.severity.HINT,
          },
        },
      },
      inline = {
        -- Show only the current line diagnostic
        only_current_line = true,
        -- Prefix used for inline diagnostic
        prefix = " ■ ",
        highlight = {
          style = {
            -- Background colors see through (alpha blend)
            blend = 5,
          },
          error = {
            -- Same as for diagnostic highlight groups
            fg = "#ea5252",
            bg = nil,
            italic = true,
          },
          warn = {
            fg = "#c78039",
            bg = nil,
            italic = true,
          },
          info = {
            fg = "#35a0e7",
            bg = nil,
            italic = true,
          },
          hint = {
            fg = "#5fab58",
            bg = nil,
            italic = true,
          },
        },
        priority = 200,
      },
      enable_diagnostic_callback = true,
    })

    -- Disable native diagnostics as we're using inline ones
    vim.diagnostic.config({ virtual_text = false })
  end,
}
