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

-- Load plugin modules first and then configure them
-- This can significantly improve startup time
local plugins_load_start = os.clock()

-- Record plugin loading time for analysis
local lazy_stats = {
  load_time = nil,
  total_plugins = 0,
  loaded_plugins = 0
}

-- For debug/profile mode, add event tracking to Lazy
if os.getenv("NVIM_PROFILE") then
  local lazy_orig_load = require("lazy.core.loader").load
  local lazy_core_loader = require("lazy.core.loader")
  lazy_core_loader.load = function(plugin, ...)
    local start_time = os.clock()
    local result = lazy_orig_load(plugin, ...)
    local load_time = os.clock() - start_time
    
    -- Track plugin loading stats
    if not lazy_stats.plugin_times then lazy_stats.plugin_times = {} end
    lazy_stats.plugin_times[plugin] = load_time
    
    return result
  end
end

require("lazy").setup("plugins", {
  change_detection = {
    notify = false,
    -- Check less frequently to reduce CPU usage
    throttle = 1000, -- ms
  },
  checker = {
    enabled = true,
    notify = false,
    -- Check less frequently to improve startup
    frequency = 86400, -- once a day
    concurrency = 1,   -- lower concurrency to reduce CPU
  },
  install = {
    colorscheme = { "catppuccin" },
  },
  ui = {
    -- Defer UI rendering to improve startup time
    wrap = false,
    border = "rounded",
    throttle = 100, -- redraw throttle in ms
  },
  performance = {
    cache = {
      enabled = true,
      path = vim.fn.stdpath("cache") .. "/lazy/cache",
      -- Increase cache TTL for better performance
      ttl = 3600 * 24 * 7, -- 7 days
    },
    reset_packpath = true, -- More aggressive optimization
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
  },
  rocks = { enabled = false }, -- disable luarocks
  
  -- Improve profiling data
  profiling = {
    -- Set to true to generate loading profile with :Lazy profile
    loader = true,
    require = false,
  },
})

-- Record plugin manager stats
lazy_stats.load_time = os.clock() - plugins_load_start
lazy_stats.total_plugins = #require("lazy.core.config").plugins

-- Function to write stats - can be called from multiple places
local function write_lazy_stats()
  local log_path = vim.fn.stdpath("cache") .. "/lazy_plugins.log"
  local log_file = io.open(log_path, "w")
  
  if log_file then
    log_file:write(string.format("Lazy.nvim load time: %.2f ms\n", lazy_stats.load_time * 1000))
    log_file:write(string.format("Total plugins: %d\n", lazy_stats.total_plugins))
    if lazy_stats.loaded_plugins then
      log_file:write(string.format("Loaded plugins: %d\n", lazy_stats.loaded_plugins))
    end
    
    -- If we have plugin times, sort and output them
    if lazy_stats.plugin_times then
      log_file:write("\nPlugin loading times:\n")
      
      local plugins_by_time = {}
      for plugin, time in pairs(lazy_stats.plugin_times) do
        table.insert(plugins_by_time, { name = plugin, time = time })
      end
      
      table.sort(plugins_by_time, function(a, b)
        return a.time > b.time
      end)
      
      for _, data in ipairs(plugins_by_time) do
        log_file:write(string.format("- %s: %.2f ms\n", data.name, data.time * 1000))
      end
    end
    
    log_file:close()
  end
end

-- Immediate write for headless mode
if os.getenv("NVIM_PROFILE") and not vim.g.gui_running then
  vim.defer_fn(write_lazy_stats, 1000)
end

-- For profiling in debug mode, output plugin stats
if os.getenv("NVIM_PROFILE") then
  vim.api.nvim_create_autocmd("User", {
    pattern = "LazyDone",
    callback = function()
      lazy_stats.loaded_plugins = #require("lazy.core.config").plugins
      write_lazy_stats() -- Use the common function
    end,
  })
end
