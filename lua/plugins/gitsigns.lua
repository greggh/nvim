local icons = {
  add = { text = "+" },
  change = { text = "~" },
  delete = { text = "_" },
  topdelete = { text = "‾" },
  changedelete = { text = "~" },
}

return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    preview_config = { border = "rounded" },
    current_line_blame = false,
    sign_priority = 0,
    signs = icons,
    signs_staged = icons,
  },
  config = function(_, opts)
    require("gitsigns").setup(opts)
  end,
}
