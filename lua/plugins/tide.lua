return {
  "jackMort/tide.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    keys = {
      leader = "'", -- Change from default ";" to "'" (single quote)
      panel = "'", -- Open the panel (uses leader key as prefix)
      add_item = "a", -- Add a new item to the list
      delete = "d", -- Remove an item from the list
      clear_all = "x", -- Clear all items
      horizontal = "-", -- Split window horizontally
      vertical = "|", -- Split window vertically
    },
    animation_duration = 300,
    animation_fps = 30,
    hints = {
      dictionary = "qwertzuiopsfghjklycvbnm",
    },
  },
  dependencies = {
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons",
  },
}
