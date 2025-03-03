return {
  "stevearc/quicker.nvim",
  event = "FileType qf",
  opts = {
    mappings = {
      {
        "n",
        "<C-q>",
        function()
          vim.cmd("cclose")
        end,
        { silent = true, buffer = true, desc = "Close quickfix" },
      },
      {
        "n",
        "<Tab>",
        function()
          require("quicker").select_item()
        end,
        { silent = true, buffer = true, desc = "Select item" },
      },
    },
    create = {
      mappings = {
        {
          "n",
          "dd",
          function()
            require("quicker").delete_line()
          end,
          { desc = "Delete line" },
        },
        {
          "v",
          "d",
          function()
            require("quicker").delete_selection()
          end,
          { desc = "Delete selection" },
        },
      },
    },
    qf = {
      track_location = true,
      auto_follow = false,
      auto_resize = true,
      max_height = 15,
      min_height = 1,
      width = 0.5,
      track_movement = true,
    },
  },
  config = function(_, opts)
    require("quicker").setup(opts)
  end,
}
