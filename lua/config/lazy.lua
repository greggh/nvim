------------------------------------
-- LAZY
------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
---@diagnostic disable-next-line: undefined-field
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
------------------------------------
-- PLUGINS
------------------------------------

require("lazy").setup("plugins", {
  change_detection = {
    notify = false,
  },
  checker = {
    enabled = true,
    notify = false,
  },
  install = {
    colorscheme = { "catppuccin" },
  },
  performance = {
    rtp = {
      -- Disable built-in plugins to improve startup time
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
        "netrwPlugin", -- Using other file explorers
        "matchit",     -- Using better alternatives
        "matchparen",  -- Can be heavy in large files
        "rplugin",     -- If not using remote plugins
        "man",         -- Disable if not using man pages within Neovim
        "shada",       -- Only disable if you don't need session history
      },
    },
    reset_packpath = true, -- More aggressive optimization
    cache = {
      enabled = true,
      path = vim.fn.stdpath("cache") .. "/lazy/cache",
      -- Increase cache TTL for better performance
      ttl = 3600 * 24 * 5, -- 5 days
    },
  },
  rocks = { enabled = false }, -- disable luarocks
})
