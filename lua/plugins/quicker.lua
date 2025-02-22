return {
  "stevearc/quicker.nvim",
  event = "FileType qf",
  opts = {},
  config = function(_, opts)
    require("quicker").setup(opts)
  end,
}
