return {
  "rcarriga/nvim-notify",
  event = "VeryLazy",
  keys = {
    {
      "<leader>nd",
      function() require("notify").dismiss() end,
      desc = "Dismiss notifications",
    },
  },
  opts = {
    -- Animation style
    stages = "fade",
    -- Default timeout
    timeout = 3000,
    -- For floating windows
    render = "default",
    -- Show message history on hover
    on_open = function(win)
      vim.api.nvim_win_set_config(win, { zindex = 200 })
    end,
    -- Customize icons and colors based on severity
    icons = {
      ERROR = " ",
      WARN = " ",
      INFO = " ",
      DEBUG = " ",
      TRACE = "✎ ",
    },
    -- Modify how notifications are laid out
    max_width = 80,
    max_height = 20,
    -- Position settings
    top_down = true,
    position = "top-right",
    -- Notification appearance
    background_colour = "#000000",
    -- Set minimum width
    minimum_width = 50,
    -- Customize border
    border = "rounded",
    -- Ensure proper coloring
    level = 2,
  },
  config = function(_, opts)
    local notify = require("notify")
    notify.setup(opts)
    -- Set as default notification system
    vim.notify = notify
  end,
}