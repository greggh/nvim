-- https://github.com/folke/noice.nvim/wiki/A-Guide-to-Messages#showmode
return {
  "folke/noice.nvim",
  event = { "VeryLazy" },
  keys = {
    {
      "<leader>nm",
      "<CMD>messages<CR>",
      desc = "Show messages",
    },
  },
  config = function()
    require("noice").setup({
      bottom_search = true,
      preset = {
        command_palette = true,
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
        view = "notify",
        -- Set animation style
        opts = {
          replace = true,
          timeout = 3000,
          render = "default",
          stages = "fade",
          with_icon = true,
        },
      },
      messages = {
        -- Enable Noice UI for messages
        enabled = true,
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
      views = {
        hover = {
          border = { style = "rounded" },
          position = { row = 2, col = 2 },
          size = { max_width = 80, max_height = 20 }, -- Limit size
        },
        notify = {
          backend = "notify",
          relative = "editor",
          timeout = 3000,
          replace = false,
          level = 0,
          size = { min_height = 4, max_height = 20, width = "auto" },
          position = { row = 1, col = "100%" },
          border = { style = "rounded" },
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
      presets = {
        long_message_to_split = true, -- Improve handling of long messages
      },
    })
  end,
}
