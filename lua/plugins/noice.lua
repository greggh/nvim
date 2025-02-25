-- https://github.com/folke/noice.nvim/wiki/A-Guide-to-Messages#showmode
return {
  "folke/noice.nvim",
  event = { "VeryLazy" },
  dependencies = {
    -- Required dependency for notifications
    "rcarriga/nvim-notify",
    "MunifTanjim/nui.nvim",
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
      -- Disable Noice's notification handling to let nvim-notify handle it directly
      notify = {
        enabled = false,
      },
      views = {
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
      },
      lsp = {
        -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
        },
      },
      -- you can enable a preset for easier configuration
      presets = {
        bottom_search = true, -- use a classic bottom cmdline for search
        command_palette = true, -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = false, -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = false, -- add a border to hover docs and signature help
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
