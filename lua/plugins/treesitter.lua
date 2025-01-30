return {
  "nvim-treesitter/nvim-treesitter",
  dependencies = {
    "windwp/nvim-ts-autotag",
    "nvim-treesitter/nvim-treesitter-context",
  },
  event = { "BufReadPre", "BufNewFile" },
  build = ":TSUpdate",
  config = function()
    local treesitter = require("nvim-treesitter.configs")
    local autotag = require("nvim-ts-autotag")
    local context = require("treesitter-context")

    ---@diagnostic disable-next-line: missing-fields
    treesitter.setup({
      auto_install = true,
      ensure_installed = {
        "regex",
        "python",
        "toml",
        "json",
        "rst",
        "ninja",
        "markdown",
        "markdown_inline",
      },
      highlight = { enable = true },
      indent = { enable = true },
    })

    ---@diagnostic disable-next-line: missing-fields
    autotag.setup({
      opts = {
        enable_close = true, -- Auto close tags
        enable_rename = true, -- Auto rename pairs of tags
        enable_close_on_slash = false, -- Auto close on trailing </
      },
    })

    context.setup({
      enable = true,
      mode = "cursor", -- 'cursor' 'topline'
      max_lines = 3,
    })
  end,
}
