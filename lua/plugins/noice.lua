-- https://github.com/folke/noice.nvim/wiki/A-Guide-to-Messages#showmode
return {
  "folke/noice.nvim",
  event = { "VeryLazy" },
  dependencies = {
    -- Required dependency for notifications
    "rcarriga/nvim-notify",
  },
  keys = {
    {
      "<leader>nm",
      "<CMD>messages<CR>",
      desc = "Show messages",
    },
  },
  config = function()
    require("noice").setup({
      -- Use a specific preset that includes nice notifications
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = false,
        lsp_doc_border = true,
      },
      cmdline = {
        view = "cmdline",
        format = {
          search_down = { view = "cmdline" },
          search_up = { view = "cmdline" },
        },
      },
      notify = {
        -- Enable Noice for vim.notify
        enabled = true,
        -- Explicitly force the notify view
        view = "notify",
      },
      messages = {
        -- Enable Noice UI for messages
        enabled = true,
        -- Explicitly set notify view for messages too
        view = "notify",
        view_search = false,
      },
      lsp = {
        hover = {
          enabled = true,
          view = "hover",
          border = { style = "rounded" },
        },
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
        },
        signature = { enabled = false }, -- provided by blink.cmp
      },
      -- Override the default view - force popup with nice styling
      views = {
        mini = { 
          -- Completely disable the mini view
          win_options = { winblend = 100 },
        },
        cmdline_popup = {
          position = {
            row = 5,
            col = "50%",
          },
          size = {
            width = 60,
            height = "auto",
          },
        },
        popupmenu = {
          relative = "editor",
          position = {
            row = 8,
            col = "50%",
          },
          size = {
            width = 60,
            height = 10,
          },
          border = {
            style = "rounded",
            padding = { 0, 1 },
          },
          win_options = {
            winhighlight = { Normal = "Normal", FloatBorder = "DiagnosticInfo" },
          },
        },
        notify = {
          -- This is the important part - make notifications appear properly
          replace = false,
          merge = false,
          render = "minimal",  -- Use minimal render for cleaner look
          timeout = 5000,
          top_down = false,
          backend = "popup",
          relative = "editor",
          position = { row = 3, col = "99%" },
          size = { width = 40, height = "auto", max_height = 20 },
          border = { 
            style = "rounded", 
            padding = { 0, 1 },
            -- Remove the "Notification" text
          },
          format = {  -- Format to include title, icon, level 
            "{icon} {title} {message}"
          },
          win_options = {
            winblend = 0, -- No transparency
            winhighlight = {
              -- Match border color to the level by default
              -- This will color the entire border based on message level
              FloatBorder = "FloatBorder",
              
              -- Level-specific highlighting for icons, borders, and titles
              ["NoiceNotifyERRORBorder"] = "DiagnosticError",
              ["NoiceNotifyWARNBorder"] = "DiagnosticWarn", 
              ["NoiceNotifyINFOBorder"] = "DiagnosticInfo",
              ["NoiceNotifyDEBUGBorder"] = "DiagnosticHint",
              ["NoiceNotifyTRACEBorder"] = "DiagnosticOk",
              
              ["NoiceNotifyERRORIcon"] = "DiagnosticError",
              ["NoiceNotifyWARNIcon"] = "DiagnosticWarn",
              ["NoiceNotifyINFOIcon"] = "DiagnosticInfo",
              ["NoiceNotifyDEBUGIcon"] = "DiagnosticHint",
              ["NoiceNotifyTRACEIcon"] = "DiagnosticOk",
              
              ["NoiceNotifyERRORTitle"] = "DiagnosticError",
              ["NoiceNotifyWARNTitle"] = "DiagnosticWarn",
              ["NoiceNotifyINFOTitle"] = "DiagnosticInfo",
              ["NoiceNotifyDEBUGTitle"] = "DiagnosticHint",
              ["NoiceNotifyTRACETitle"] = "DiagnosticOk",
            },
          },
        },
      },
      routes = {
        -- Reduce noice noise by filtering messages
        {
          filter = {
            event = "msg_show",
            kind = "",
            find = "written",
          },
          opts = { skip = true },
        },
        {
          filter = {
            event = "msg_show",
            kind = "",
            find = "lines yanked",
          },
          opts = { skip = true },
        },
      },
      -- Removed separate presets section as it's now in the main config
    })
  end,
}
