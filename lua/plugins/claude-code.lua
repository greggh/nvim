-- Use the proper claude-code.nvim plugin from GitHub
return {
  "greggh/claude-code.nvim",
  lazy = false,
  config = function()
    require("claude-code").setup({
      -- Terminal window settings
      window = {
        height_ratio = 0.3,     -- Percentage of screen height for the terminal window
        position = "botright",  -- Position of the window: "botright", "topleft", etc.
        enter_insert = true,    -- Whether to enter insert mode when opening Claude Code
        hide_numbers = true,    -- Hide line numbers in the terminal window
        hide_signcolumn = true, -- Hide the sign column in the terminal window
      },
      -- File refresh settings
      refresh = {
        enable = true,           -- Enable file change detection
        updatetime = 100,        -- updatetime when Claude Code is active (milliseconds)
        timer_interval = 1000,   -- How often to check for file changes (milliseconds)
        show_notifications = true, -- Show notification when files are reloaded
      },
      -- Keymaps
      keymaps = {
        toggle = {
          normal = "<leader>ac",  -- Normal mode keymap for toggling Claude Code
          terminal = "<C-o>",     -- Terminal mode keymap for toggling Claude Code
        }
      }
    })
  end,
}

