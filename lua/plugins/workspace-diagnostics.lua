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
        -- Cache the results to avoid repeated expensive operations
        if
          vim.b.workspace_files_cache
          and vim.b.workspace_files_timestamp
          and os.time() - vim.b.workspace_files_timestamp < 300
        then -- 5 minute cache
          return vim.b.workspace_files_cache
        end

        local out = vim.system({ "git", "ls-files" }, { text = true }):wait()

        if out.code ~= 0 then
          return {}
        end

        local files = {}
        -- Enhanced ignore patterns to skip more binary/generated files
        local ignore_patterns = {
          -- Binary and media files
          "%.min%.js$",
          "%.jpg$",
          "%.png$",
          "%.gif$",
          "%.ico$",
          "%.woff2?$",
          "%.ttf$",
          "%.otf$",
          "%.eot$",
          "%.mp[34]$",
          "%.webp$",
          "%.pdf$",
          "%.zip$",
          "%.gz$",
          "%.tar$",
          -- Generated files
          "%.lock$",
          "%.svg$",
          "%.map$",
          "%.bundle%.js$",
          -- Common directories to skip
          "node_modules/",
          "dist/",
          "build/",
          "vendor/",
          "tmp/",
          "%.git/",
          "%.cache/",
          "%.vscode/",
          "%.idea/",
        }

        -- Faster file filtering with pre-compiled patterns
        local compiled_patterns = {}
        for _, pattern in ipairs(ignore_patterns) do
          table.insert(compiled_patterns, vim.regex(pattern))
        end

        local max_files = 2000 -- Limit the number of files to prevent slowdowns
        local file_count = 0

        for file in out.stdout:gmatch("[^\r\n]+") do
          if file_count >= max_files then
            break
          end

          if vim.fn.filereadable(file) == 1 then
            local size = vim.fn.getfsize(file)
            local should_ignore = false

            -- Faster pattern matching
            for _, regex in ipairs(compiled_patterns) do
              if regex:match_str(file) then
                should_ignore = true
                break
              end
            end

            -- More restrictive size limit (200KB instead of 500KB)
            if not should_ignore and size > 0 and size < 200000 then
              table.insert(files, file)
              file_count = file_count + 1
            end
          end
        end

        -- Save cache
        vim.b.workspace_files_cache = files
        vim.b.workspace_files_timestamp = os.time()

        return files
      end,
      debounce = 500, -- Increased debounce to reduce processing frequency
      max_diagnostics = 500, -- Reduced diagnostic limit for better performance
    })
  end,
}
