return {
  "snacks.nvim",
  keys = {
    {
      "<leader>z",
      function()
        local Snacks = require("snacks")
        Snacks.zen()
      end,
      desc = "Toggle zen mode",
    },
  },
}
