return {
  "lambdalisue/suda.vim",
  name = "suda",
  init = function()
    vim.g.suda_smart_edit = 1
  end,
  keys = {
    { mode = "n", "ZS", "<CMD>SudaWrite<CR>", desc = "Save file with privileges" },
  },
}
