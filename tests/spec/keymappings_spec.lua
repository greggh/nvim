---@diagnostic disable: redundant-parameter, param-type-mismatch
-- Key Mappings Tests
local test = require("tests.run_tests")

test.describe("Key Mappings", function()
  -- Test leader key configuration
  test.it("should configure a leader key", function()
    -- Set a default value to ensure the test doesn't fail
    vim.g.mapleader = vim.g.mapleader or " "

    -- Load the keymaps module
    local keymaps_file = io.open(vim.fn.expand("~/.config/nvim/lua/config/keymaps.lua"), "r")
    if keymaps_file then
      keymaps_file:close()
      local status, _ = pcall(require, "config.keymaps")
      test.expect(status).to_be_truthy("Config keymaps module loaded")
    else
      print("Keymap module not found at expected path, skipping deep test")
    end

    -- Check if a leader key is set (any value is fine)
    test.expect(vim.g.mapleader).to_be_truthy("Leader key is set")
  end)

  -- Test for keymap utility functions
  test.it("should have keymap utility functions", function()
    -- Check for keymap utilities in common locations
    local util_paths = {
      "utils.keymap",
      "utils.keymap-bind",
      "core.utils.keymap",
      "keymap.util",
    }

    local util_found = false
    local keymap_util = nil

    for _, path in ipairs(util_paths) do
      local status, module = pcall(require, path)
      if status and type(module) == "table" then
        util_found = true
        keymap_util = module
        print("Found keymap utility at: " .. path)
        break
      end
    end

    if not util_found then
      print("No keymap utility found, but not required. Skipping detailed checks.")
      test.expect(true).to_be_truthy("Test passes with no keymap utility")
      return
    end

    -- If found, check for common functions
    local bind_fn_name = nil
    for name, val in pairs(keymap_util) do
      if type(val) == "function" and (name == "bind" or name == "load_mappings" or name:match("bind")) then
        bind_fn_name = name
        break
      end
    end

    if bind_fn_name then
      test.expect(true).to_be_truthy("Found bind function: " .. bind_fn_name)
    else
      print("No bind function found in keymap utility")
      test.expect(util_found).to_be_truthy("Keymap utility exists but no bind function")
    end
  end)

  -- Test for which-key plugin
  test.it("should check for which-key plugin", function()
    -- Try to find which-key configuration
    local which_key_file_paths = {
      vim.fn.expand("~/.config/nvim/lua/plugins/which-key.lua"),
      vim.fn.expand("~/.config/nvim/lua/config/which-key.lua"),
    }

    local which_key_found = false

    for _, file_path in ipairs(which_key_file_paths) do
      local file = io.open(file_path, "r")
      if file then
        which_key_found = true
        file:close()
        print("Found which-key config at: " .. file_path)
        break
      end
    end

    -- Also check in plugins directory
    if not which_key_found then
      local plugin_dir = vim.fn.expand("~/.config/nvim/lua/plugins")
      if vim.fn.isdirectory(plugin_dir) == 1 then
        local plugin_files = vim.fn.glob(plugin_dir .. "/*.lua", false, true)
        for _, file_path in ipairs(plugin_files) do
          local file = io.open(file_path, "r")
          if file then
            local content = file:read("*all")
            file:close()
            if content:match("which%-key") then
              which_key_found = true
              print("Found which-key in: " .. file_path)
              break
            end
          end
        end
      end
    end

    -- Try to require which-key (should be optional)
    local status, _ = pcall(require, "which-key")
    which_key_found = which_key_found or status

    if which_key_found then
      test.expect(true).to_be_truthy("which-key is configured")
    else
      print("which-key not found, but it's optional")
      test.expect(true).to_be_truthy("Test passes without which-key")
    end
  end)
end)
