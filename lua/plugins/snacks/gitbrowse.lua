return {
  "snacks.nvim",
  keys = {
    {
      "<leader>gB",
      function()
        local Snacks = require("snacks")
        Snacks.gitbrowse()
      end,
      desc = "Git browse",
      mode = { "n", "v" },
    },
  },
}
