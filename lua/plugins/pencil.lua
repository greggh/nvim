return {
  "preservim/vim-pencil",
  config = function()
    vim.g["pencil#autoformat"] = 1
    vim.g["pencil#textwidth"] = 80
    vim.g["pencil#wrapModeDefault"] = "soft"
    vim.fn["pencil#init"]({ wrap = "soft", autoformat = 1 })
    vim.api.nvim_create_augroup("Pencil", {})
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "markdown",
      callback = function()
        vim.cmd("PencilToggle") -- Initialize Pencil
        vim.g.pencil_wrap_mode_default = "soft" -- Set soft wrap mode
      end,
      group = "Pencil",
    })
  end,
  ft = {
    "mkd",
    "md",
    "markdown",
    "tex",
    "latex",
    "text",
    "txt",
  },
}
