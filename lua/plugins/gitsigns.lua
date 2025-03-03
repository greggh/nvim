local icons = {
  add = { text = "+" },
  change = { text = "~" },
  delete = { text = "_" },
  topdelete = { text = "‾" },
  changedelete = { text = "~" },
}

return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    preview_config = { border = "rounded" },
    current_line_blame = false,
    current_line_blame_opts = {
      virt_text = true,
      virt_text_pos = "eol",
      delay = 500,
    },
    current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
    sign_priority = 0,
    signs = icons,
    signs_staged = icons,
    on_attach = function(bufnr)
      local gs = package.loaded.gitsigns

      -- Don't override the built-in and fugitive keymaps
      local function map(mode, l, r, opts)
        opts = opts or {}
        opts.buffer = bufnr
        vim.keymap.set(mode, l, r, opts)
      end

      -- Navigation
      map("n", "]g", function()
        if vim.wo.diff then
          return "]g"
        end
        vim.schedule(function()
          gs.next_hunk()
        end)
        return "<Ignore>"
      end, { expr = true, desc = "Next hunk" })

      map("n", "[g", function()
        if vim.wo.diff then
          return "[g"
        end
        vim.schedule(function()
          gs.prev_hunk()
        end)
        return "<Ignore>"
      end, { expr = true, desc = "Previous hunk" })
    end,
  },
  config = function(_, opts)
    require("gitsigns").setup(opts)
  end,
}
