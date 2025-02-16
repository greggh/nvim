return {
  "echasnovski/mini.surround",
  event = { "BufReadPre", "BufNewFile" },
  version = false,
  config = function()
    require("mini.surround").setup({
      mappings = {
        add = "", -- Add surrounding in Normal and Visual modes
        delete = "", -- Delete surrounding
        replace = "", -- Replace surrounding

        find = "", -- Find surrounding (to the right)
        find_left = "", -- Find surrounding (to the left)
        highlight = "", -- Highlight surrounding
        update_n_lines = "", -- Update `n_lines`
        suffix_last = "", -- Suffix to search with "prev" method
        suffix_next = "", -- Suffix to search with "next" method
      },
    })
  end,
}
