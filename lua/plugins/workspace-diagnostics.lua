---@module "workspace-diagnostics"

return {
  "artemave/workspace-diagnostics.nvim",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "neovim/nvim-lspconfig",
    "folke/trouble.nvim",
  },
  config = function()
    require("workspace-diagnostics").setup({
      workspace_files = function() -- Customize this function to return project files.
        local files = vim.fn.systemlist("git ls-files")
        -- Filter out binary files, large files, etc.
        return vim.tbl_filter(function(file)
          local size = vim.fn.getfsize(file)
          return size > 0 and size < 500000 and not file:match("%.min%.js$")
            and not file:match("%.jpg$") and not file:match("%.png$")
            and not file:match("%.gif$") and not file:match("%.woff2?$")
            and not file:match("%.ttf$") and not file:match("%.otf$")
        end, files)
      end,
    })
  end,
}
