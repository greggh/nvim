<<<<<<< HEAD
=======
return {
  "folke/which-key.nvim",
  event = { "VeryLazy" },
  opts = {
    preset = "modern",
    delay = vim.o.timeoutlen,
    plugins = {
      marks = true,
      registers = true,
      spelling = {
        enabled = true,
        suggestions = 20,
      },
      presets = {
        motions = false,
        operators = false,
        text_objects = true,
        windows = true,
        nav = true,
        z = true,
        g = true,
      },
    },
    win = {
      border = "none",
      padding = { 1, 2 },
      wo = { winblend = 0 },
    },
>>>>>>> Snippet

