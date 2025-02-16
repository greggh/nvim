return {
  "folke/flash.nvim",
  event = { "VeryLazy" },
  opts = {
    modes = {
      search = {
        enabled = false,
        mode = "fuzzy", -- "fuzzy" | "exact" | "search"
      },
    },
    jump = {
      autojump = false,
    },
  },
}
