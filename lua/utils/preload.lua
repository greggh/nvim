-- Utility module for smart preloading of Lua modules
-- This helps with startup performance by preloading modules in batches
-- with intelligent prioritization

local M = {}

-- Modules that are already loaded
local loaded_modules = {}

-- Default options
local default_opts = {
  batch_size = 5,     -- How many modules to load in each batch
  delay = 10,         -- Milliseconds to wait between batches
  verbose = false,    -- Whether to print debug information
}

-- Track timing for performance analysis
local function measure_load_time(module_name, verbose)
  local start_time = vim.loop.hrtime()
  local ok, result = pcall(require, module_name)
  local end_time = vim.loop.hrtime()
  local elapsed = (end_time - start_time) / 1e6 -- Convert to milliseconds
  
  if verbose then
    if ok then
      print(string.format("Preloaded %s in %.2f ms", module_name, elapsed))
    else
      print(string.format("Failed to preload %s: %s", module_name, result))
    end
  end
  
  return ok, result, elapsed
end

-- Preload a list of modules in batches
function M.preload_modules(modules_list, opts)
  opts = vim.tbl_deep_extend("force", default_opts, opts or {})
  
  -- Filter out already loaded modules
  local modules_to_load = {}
  for _, module in ipairs(modules_list) do
    if not loaded_modules[module] and not package.loaded[module] then
      table.insert(modules_to_load, module)
      loaded_modules[module] = true
    end
  end
  
  -- Process in batches
  local total_modules = #modules_to_load
  local total_batches = math.ceil(total_modules / opts.batch_size)
  local total_load_time = 0
  
  for batch = 1, total_batches do
    local start_idx = (batch - 1) * opts.batch_size + 1
    local end_idx = math.min(batch * opts.batch_size, total_modules)
    
    if batch == 1 then
      -- Load first batch immediately
      for i = start_idx, end_idx do
        local module = modules_to_load[i]
        local _, _, elapsed = measure_load_time(module, opts.verbose)
        total_load_time = total_load_time + elapsed
      end
    else
      -- Schedule the rest with delays
      vim.defer_fn(function()
        for i = start_idx, end_idx do
          local module = modules_to_load[i]
          local _, _, elapsed = measure_load_time(module, opts.verbose)
          total_load_time = total_load_time + elapsed
        end
      end, opts.delay * (batch - 1))
    end
  end
  
  return total_modules, total_load_time
end

-- Preload common modules used by the editor
function M.preload_common_modules()
  local common_modules = {
    -- Core modules
    "vim.lsp",
    "vim.treesitter",
    "vim.diagnostic",
    
    -- Common utilities
    "plenary",
    "utils.keymap-bind",
    "utils.ui",
    "utils.maintenance",
    
    -- Common plugins
    "trouble",
    "gitsigns",
    "which-key",
  }
  
  return M.preload_modules(common_modules, { verbose = false })
end

-- Smart preload based on filetype
function M.preload_filetype_modules(filetype)
  local filetype_modules = {
    lua = {
      "lua-language-server",
      "neodev"
    },
    python = {
      "pyright",
      "black"
    },
    javascript = {
      "tsserver",
      "eslint"
    },
    typescript = {
      "tsserver",
      "eslint"
    },
    go = {
      "gopls"
    },
    rust = {
      "rust_analyzer"
    },
  }
  
  if filetype_modules[filetype] then
    return M.preload_modules(filetype_modules[filetype], { verbose = false })
  end
  
  return 0, 0
end

return M