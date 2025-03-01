return {
  "snacks.nvim",
  keys = {
    {
      "<leader>nn",
      function()
        local Snacks = require("snacks")
        Snacks.notifier.show_history()
      end,
      desc = "Notification history",
    },
    {
      "<leader>nd",
      function()
        local Snacks = require("snacks")
        Snacks.notifier.hide()
      end,
      desc = "Dismiss all notifications",
    },
  },
  opts = {
    notifier = {
      enabled = true,
      top_down = false,
      style = "minimal", -- "compact" | "fancy" | "minimal"
    },
    notify = { enabled = true },
  },
}
