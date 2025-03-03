return {
  "kosayoda/nvim-lightbulb",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    ---@diagnostic disable-next-line: missing-fields
    require("nvim-lightbulb").setup({
      autocmd = { enabled = true },
      sign = {
        enabled = true,
        priority = 10,
      },
      float = {
        enabled = false,
        text = "💡",
        win_opts = {},
      },
      virtual_text = {
        enabled = false,
        text = "💡",
        hl_mode = "replace",
      },
      status_text = {
        enabled = false,
        text = "💡",
        text_unavailable = "",
      },
      priority = 100,
      ignore = {
        clients = {},
        ft = {
          "markdown",
          "text",
          "gitcommit",
        },
      },
    })
  end,
}
