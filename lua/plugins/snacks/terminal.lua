return {
  "snacks.nvim",
  keys = {
    {
      mode = { "n", "t" },
      "<C-T>",
      function()
        local Snacks = require("snacks")
        Snacks.terminal.toggle()
      end,
      silent = true,
      desc = "Toggle terminal",
    },
    {
      "<c-_>",
      function()
        local Snacks = require("snacks")
        Snacks.terminal()
      end,
      desc = "which_key_ignore",
    },
  },
  opts = {
    terminal = {
      enabled = true,
      win = {
        keys = {
          term_normal = {
            "<esc><esc>",
            function()
              return "<C-\\><C-n>"
            end,
            mode = "t",
            expr = true,
            desc = "Double escape to normal mode",
          },
          q = "hide",
          ["<esc>"] = "hide",
        },
      },
    },
  },
}
