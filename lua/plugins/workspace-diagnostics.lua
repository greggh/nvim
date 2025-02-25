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
        local out = vim.system({"git", "ls-files"}, {text = true}):wait()
        
        if out.code ~= 0 then
          return {}
        end

        local files = {}
        local ignore_patterns = {
          "%.min%.js$", "%.jpg$", "%.png$", "%.gif$", 
          "%.woff2?$", "%.ttf$", "%.otf$",
          "%.lock$", "%.svg$", "node_modules/", "dist/", "build/"
        }
        
        for file in out.stdout:gmatch("[^\r\n]+") do
          if vim.fn.filereadable(file) == 1 then
            local size = vim.fn.getfsize(file)
            local should_ignore = false
            
            for _, pattern in ipairs(ignore_patterns) do
              if file:match(pattern) then
                should_ignore = true
                break
              end
            end
            
            if not should_ignore and size > 0 and size < 500000 then
              table.insert(files, file)
            end
          end
        end
        return files
      end,
      debounce = 300, -- Add debouncing to prevent performance issues
      max_diagnostics = 1000, -- Limit total diagnostics to prevent memory issues
    })
  end,
}
