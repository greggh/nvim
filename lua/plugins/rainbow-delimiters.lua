return {
  "HiPhish/rainbow-delimiters.nvim",
  event = "VeryLazy",
  config = function()
    -- Load rainbow delimiters with a better strategy than the default
    local rainbow_delimiters = require("rainbow-delimiters")

    vim.g.rainbow_delimiters = {
      strategy = {
        [""] = rainbow_delimiters.strategy["global"],
        vim = rainbow_delimiters.strategy["local"],
      },
      query = {
        [""] = "rainbow-delimiters",
        lua = "rainbow-blocks",
        javascript = "rainbow-delimiters-react",
        tsx = "rainbow-parens",
      },
      highlight = {
        "RainbowDelimiterRed",
        "RainbowDelimiterYellow",
        "RainbowDelimiterBlue",
        "RainbowDelimiterOrange",
        "RainbowDelimiterGreen",
        "RainbowDelimiterViolet",
        "RainbowDelimiterCyan",
      },
      blacklist = { "html" }, -- Disable for HTML (often looks busy)
    }

    -- patch https://github.com/nvim-treesitter/nvim-treesitter/issues/1124
    if vim.fn.expand("%:p") ~= "" then
      vim.cmd.edit({ bang = true })
    end
  end,
}
