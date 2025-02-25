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
    -- More minimal configuration that should definitely work
    require("noice").setup({
      cmdline = {
        enabled = true,
        view = "cmdline", -- use simple cmdline view
      },
      messages = {
        enabled = true,
      },
      notify = {
        enabled = true,
      },
      lsp = {
        hover = {
          enabled = true,
          border = { style = "rounded" },
        },
        signature = { enabled = false }, -- provided by blink.cmp
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
        },
      },
      -- Use the default presets
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        lsp_doc_border = true, 
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
    })
  end,
}
