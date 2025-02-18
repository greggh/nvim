local filetypes = {
  "markdown",
}

if vim.g.ai then
  table.insert(filetypes, "Avante")
end

return {
  "OXY2DEV/markview.nvim",
  ft = filetypes,
  opts = {
    preview = {
      filetypes = filetypes,
      ignore_buftypes = {},
    },
  },
}
