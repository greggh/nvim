return {
  "folke/trouble.nvim",
  dependencies = {
    "echasnovski/mini.icons",
    "folke/todo-comments.nvim",
  },
  opts = {
    auto_close = false,
    auto_preview = false,
    multiline = false,
    focus = true,
    warn_no_results = false,
    open_no_results = true,

    vim.api.nvim_create_autocmd("BufRead", {
      callback = function(ev)
        if vim.bo[ev.buf].buftype == "quickfix" then
          vim.schedule(function()
            vim.cmd([[cclose]])
            vim.cmd([[Trouble quickfix toggle]])
          end)
        end
      end,
    }),
  },
  cmd = { "Trouble", "TroubleToggle" },
}
