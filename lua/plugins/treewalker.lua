return {
  "aaronik/treewalker.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    highlight = true,
    highlight_group = "Visual",
    disable_on_filetypes = vim.g.ignore_filetypes,
  },
}
