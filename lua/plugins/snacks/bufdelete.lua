return {
  "snacks.nvim",
  keys = {
    {
      "<c-x>",
      function()
        local Snacks = require("snacks")
        Snacks.bufdelete()
      end,
      desc = "Delete buffer",
    },
  },
}
