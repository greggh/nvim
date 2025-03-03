return {
  "OXY2DEV/helpview.nvim",
  ft = { "help" },
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  cmd = { "HelpView" },
  -- Ensure the plugin is loaded properly
  config = function()
    require("helpview").setup({})
  end,
  -- Keymaps are defined in lua/config/keymaps.lua
}
