-- Set up the file reload detection directly from the plugin spec
-- without requiring an external repository

-- Create a VimEnter autocommand to initialize the file change detection system
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    require("utils.claude").setup()
  end,
  once = true,
})

-- Return an empty spec to avoid Lazy trying to load a repository
return {}

