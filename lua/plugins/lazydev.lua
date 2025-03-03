return {
  "folke/lazydev.nvim",
  ft = { "lua" },
  opts = {
    library = {
      { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      { path = "snacks.nvim", words = { "Snacks" } },
      { path = "lazy.nvim", words = { "LazyVim" } },
      { path = "edgy.nvim", words = { "edgy" } },
      { path = "dropbar.nvim", words = { "dropbar" } },
      { path = "flash.nvim", words = { "flash" } },
    },
    plugins = {
      "lua_ls", -- Specify language servers to hook into
    },
  },
}
