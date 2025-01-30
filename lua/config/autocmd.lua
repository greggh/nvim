------------------------------------
-- UNDOFILE ON GIT REPOSITORY ONLY
------------------------------------
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  callback = function()
    vim.o.undofile = require("utils.git").is_git_repo()
  end,
})

------------------------------------
-- HIGHLIGHT ON YANK
------------------------------------
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

------------------------------------
-- DEPENDENCIES
------------------------------------
require("utils.dependencies").missing_dependencies_notification()

------------------------------------
-- SNIPPETS
------------------------------------
require("utils.snippets")

------------------------------------
-- PYTHON
------------------------------------
-- The filetype-autocmd runs a function when opening a file with the filetype
-- "python". This method allows you to make filetype-specific configurations. In
-- there, you have to use `opt_local` instead of `opt` to limit the changes to
-- just that buffer. (As an alternative to using an autocmd, you can also put those
-- configurations into a file `/after/ftplugin/{filetype}.lua` in your
-- nvim-directory.)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python", -- filetype for which to run the autocmd
  callback = function()
    -- use pep8 standards
    vim.opt_local.expandtab = true
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4

    -- folds based on indentation https://neovim.io/doc/user/fold.html#fold-indent
    -- if you are a heavy user of folds, consider using `nvim-ufo`
    vim.opt_local.foldmethod = "indent"

    local iabbrev = function(lhs, rhs)
      vim.keymap.set("ia", lhs, rhs, { buffer = true })
    end
    -- automatically capitalize boolean values. Useful if you come from a
    -- different language, and lowercase them out of habit.
    iabbrev("true", "True")
    iabbrev("false", "False")

    -- we can also fix other habits we might have from other languages
    iabbrev("--", "#")
    iabbrev("null", "None")
    iabbrev("none", "None")
    iabbrev("nil", "None")
    iabbrev("function", "def")
  end,
})
