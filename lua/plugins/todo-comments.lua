return {
  "folke/todo-comments.nvim",
  version = "*",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    {
      mode = "n",
      "<leader>ft",
      function()
        ---@diagnostic disable-next-line: undefined-field
        Snacks.picker.todo_comments()
      end,
      silent = true,
      desc = "show TODO",
    },
  },
  opts = {},
}
