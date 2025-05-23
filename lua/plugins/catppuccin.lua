return {
  "catppuccin/nvim",
  name = "catppuccin",
  lazy = false,
  priority = 1000,
  opts = {
    flavour = "mocha",
    transparent_background = false,

    custom_highlights = function(colors)
      return {
        BlinkCmpMenuBorder = { fg = colors.blue },
        BlinkCmpDocBorder = { fg = colors.sapphire },
        BlinkCmpSignatureHelpBorder = { fg = colors.blue },
      }
    end,

    integrations = {
      blink_cmp = true,
      dap = true,
      dap_ui = true,
      diffview = true,
      gitsigns = true,
      grug_far = true,
      lsp_trouble = true,
      markdown = true,
      mason = true,
      native_lsp = {
        enabled = true,
        underlines = {
          errors = { "undercurl" },
          hints = { "undercurl" },
          warnings = { "undercurl" },
          information = { "undercurl" },
        },
      },
      neotest = true,
      noice = true,
      semantic_tokens = true,
      snacks = true,
      treesitter = true,
      treesitter_context = true,
      which_key = true,
    },
  },
  config = function(_, opts)
    require("catppuccin").setup(opts)
    vim.cmd.colorscheme("catppuccin")
  end,
}
