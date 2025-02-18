local trouble_filter = function(position)
  return function(_, win)
    return vim.w[win].trouble
      and vim.w[win].trouble.position == position
      and vim.w[win].trouble.type == "split"
      and vim.w[win].trouble.relative == "editor"
      and not vim.w[win].trouble_preview
  end
end

return {
  "folke/edgy.nvim",
  event = { "VeryLazy" },
  init = function()
    vim.o.laststatus = 3
    vim.o.splitkeep = "screen"
  end,
  opts = {
    top = {},
    right = {
      -- { ft = "Avante", title = "Avante", size = { width = 0.5 } },
      { ft = "grug-far", title = "Search & Replace", size = { width = 0.5 } },
      { ft = "neotest-summary", title = "neotest", size = { width = 0.3 } },
      { ft = "Outline", title = "Outline", size = { width = 0.2 } },
      {
        ft = "trouble",
        title = "Trouble Symbols",
        pinned = true,
        collapsed = false,
        size = { height = 0.6, width = 0.15 },
        open = "Trouble symbols toggle win.position=right",
        filter = trouble_filter("right"),
      },
      {
        ft = "trouble",
        title = "Trouble LSP",
        pinned = true,
        collapsed = true,
        size = { height = 0.4, width = 0.15 },
        open = "Trouble lsp toggle win.position=right",
        filter = trouble_filter("right"),
      },
    },
    bottom = {
      {
        ft = "help",
        size = { height = 0.7 },
        filter = function(buf)
          return vim.bo[buf].buftype == "help"
        end,
      },
      { ft = "neotest-output-panel", title = "neotest", size = { height = 0.5 } },
      { ft = "qf", title = "QuickFix" },
      {
        ft = "snacks_terminal",
        size = { height = 0.2 },
        title = "Terminal %{b:snacks_terminal.id}",
        filter = function(_, win)
          return vim.w[win].snacks_win
            and vim.w[win].snacks_win.position == "bottom"
            and vim.w[win].snacks_win.relative == "editor"
            and not vim.w[win].trouble_preview
        end,
      },
      {
        ft = "trouble",
        title = "Trouble Diagnostics",
        size = { height = 0.2 },
        open = "Trouble diagnostics toggle win.position=bottom",
        filter = trouble_filter("bottom"),
      },
    },
    left = {
      {
        ft = "snacks_explorer",
        pinned = true,
        collapsed = false,
        open = "lua require('snacks').explorer.open()",
        size = {
          height = 0.5,
          width = 20,
        },
      },
    },
    animate = { enabled = false },
    options = {
      top = { size = 10 },
    },
    wo = { winhighlight = "" },
  },
}
