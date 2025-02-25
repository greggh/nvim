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
  opts = {
    preset = {
      bottom_search = true,
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
  },
  config = function(_, opts)
    require("noice").setup(opts)
  end,
}
