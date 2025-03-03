---@diagnostic disable: duplicate-set-field
-- Minimal configuration for testing
-- Based on the structure from laravel-helper plugin

-- Set up paths
vim.cmd([[set runtimepath=$VIMRUNTIME]])
vim.cmd([[set packpath=/tmp/nvim/site]])

-- Add the config directory to runtimepath
-- Use absolute path or relative path depending on where the test is run from
local nvim_config_path = vim.fn.fnamemodify(vim.fn.resolve("."), ":p")
-- Ensure we're in the right directory by checking for tests dir
if vim.fn.isdirectory(nvim_config_path .. "/tests") == 0 then
  -- Try using absolute path as fallback
  nvim_config_path = vim.fn.expand("~/.config/nvim")
end

print("Using config path: " .. nvim_config_path)
vim.opt.runtimepath:append(nvim_config_path)
vim.opt.packpath:append(nvim_config_path)

-- Disable certain features that might interfere with tests
vim.g.loaded_remote_plugins = 1
vim.g.loaded_python3_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0

-- Test flags to avoid loading all plugins during testing
vim.g._test_mode = true
vim.g._disable_which_key = true

-- Mock certain functions and modules that might be needed by config modules
local function setup_mocks()
  -- Mock vim.notify to avoid UI-related errors
  vim.notify = function(msg, level, _)
    if level == vim.log.levels.ERROR then
      print("[ERROR] " .. msg)
    elseif level == vim.log.levels.WARN then
      print("[WARN] " .. msg)
    elseif level == vim.log.levels.INFO and vim.g._test_verbose then
      print("[INFO] " .. msg)
    elseif level == vim.log.levels.DEBUG and vim.g._test_debug then
      print("[DEBUG] " .. msg)
    end
  end

  -- Mock vim.keymap.set to prevent errors when defining keymaps
  vim.keymap.set = function(_, _, _, _)
    -- Do nothing in test mode
    return true
  end

  -- Mock autocmd-related functions
  if not vim.api.nvim_create_autocmd then
    vim.api.nvim_create_autocmd = function(_, _)
      -- Do nothing in test mode
      return 0 -- Return a dummy autocmd ID
    end
  end

  if not vim.api.nvim_create_augroup then
    vim.api.nvim_create_augroup = function(_, _)
      -- Do nothing in test mode
      return 0 -- Return a dummy augroup ID
    end
  end

  -- Mock common plugin dependencies

  -- Mock Snacks dependency for keymaps
  package.loaded["snacks"] = {
    explorer = function(_)
      return true
    end,
    lazygit = {
      log = function(_)
        return true
      end,
    },
    picker = {
      todo_comments = function()
        return true
      end,
    },
    rename = {
      rename_file = function()
        return true
      end,
    },
  }

  -- Mock LuaSnip more completely
  local luasnip_mock = {
    add_snippets = function()
      return true
    end,
    expand_or_jumpable = function()
      return false
    end,
    expand = function()
      return true
    end,
    jumpable = function()
      return false
    end,
    jump = function()
      return true
    end,
    change_choice = function()
      return true
    end,
    lsp_expand = function()
      return true
    end,
    -- Core functions
    snippet = function(...)
      return { ... }
    end, -- s() function
    text_node = function(text)
      return text
    end, -- t() function
    insert_node = function(pos, text)
      return { pos = pos, text = text }
    end, -- i() function
    choice_node = function(...)
      return { ... }
    end, -- c() function
    function_node = function(...)
      return { ... }
    end, -- f() function
    dynamic_node = function(...)
      return { ... }
    end, -- d() function
    snippet_node = function(...)
      return { ... }
    end, -- sn() function
    restore_node = function(...)
      return { ... }
    end, -- r() function
    indent_snippet_node = function(...)
      return { ... }
    end, -- isn() function
    -- Aliased functions
    s = function(...)
      return { ... }
    end,
    t = function(text)
      return text
    end,
    i = function(pos, text)
      return { pos = pos, text = text }
    end,
    c = function(...)
      return { ... }
    end,
    f = function(...)
      return { ... }
    end,
    d = function(...)
      return { ... }
    end,
    sn = function(...)
      return { ... }
    end,
    r = function(...)
      return { ... }
    end,
    isn = function(...)
      return { ... }
    end,
    events = {},
    config = {
      setup = function()
        return true
      end,
    },
  }
  package.loaded["luasnip"] = luasnip_mock

  -- Mock nvim-treesitter
  package.loaded["nvim-treesitter"] = {
    setup = function()
      return true
    end,
  }

  -- Mock utils.snippets
  package.loaded["utils.snippets"] = {
    setup = function()
      return true
    end,
  }

  -- Mock other common plugins
  local common_plugins = {
    "telescope",
    "nvim-lspconfig",
    "mason",
    "cmp",
    "gitsigns",
    "which-key",
    "nvim-treesitter.configs",
    "lazy",
  }

  for _, plugin_name in ipairs(common_plugins) do
    if not package.loaded[plugin_name] then
      package.loaded[plugin_name] = {
        setup = function(_)
          return true
        end,
      }
    end
  end

  -- Mock more specific plugin functionality as needed
  -- Add mock table for nvim-cmp
  package.loaded["cmp"] = {
    setup = function()
      return true
    end,
    mapping = {
      ["<C-d>"] = function() end,
      ["<C-u>"] = function() end,
      ["<C-Space>"] = function() end,
      ["<CR>"] = function() end,
      ["<Tab>"] = function() end,
      ["<S-Tab>"] = function() end,
    },
    config = {
      sources = function() end,
      formatting = function() end,
    },
  }
end

-- Set up mocks
setup_mocks()

-- Ensure log level is set for debugging
vim.lsp.set_log_level("error")

-- Add minimal options
vim.opt.termguicolors = true
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false

-- Silent mode for notifications during tests
vim.notify = function(msg, level, _)
  if level == vim.log.levels.ERROR then
    print("[ERROR] " .. msg)
  elseif level == vim.log.levels.WARN then
    print("[WARN] " .. msg)
  elseif level == vim.log.levels.INFO and vim.g._test_verbose then
    print("[INFO] " .. msg)
  elseif level == vim.log.levels.DEBUG and vim.g._test_debug then
    print("[DEBUG] " .. msg)
  end
end
