return {
  "lambdalisue/suda.vim",
  event = { "VeryLazy" },
  name = "suda",
  init = function()
    -- Automatically use sudo for files that require administrator privilege
    vim.g.suda_smart_edit = 1
  end,
  cmd = { "SudaRead", "SudaWrite" },
}
