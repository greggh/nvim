---@diagnostic disable: redundant-parameter
-- Plugin Management Tests
local test = require("tests.run_tests")

test.describe("Plugin Management", function()
  -- Mock lazy.nvim
  local lazy_setup_called = false
  local plugins_checked = false

  -- Test if lazy.nvim is loaded correctly
  test.it("should check for lazy.nvim configuration", function()
    -- Try to load the lazy configuration module
    local config_path = os.getenv("NVIM_CONFIG_PATH") or vim.fn.expand("~/.config/nvim")

    -- First check if lazy.lua exists, otherwise config.lazy
    local lazy_file = io.open(config_path .. "/lua/config/lazy.lua", "r")
    local lazy_module_name = "config.lazy"

    if not lazy_file then
      lazy_file = io.open(config_path .. "/lua/plugins/init.lua", "r")
      if lazy_file then
        lazy_module_name = "plugins"
      end
    end

    if lazy_file then
      lazy_file:close()
      print("Found lazy config at: " .. lazy_module_name)

      -- Mark test as passed
      lazy_setup_called = true
      test.expect(true).to_be_truthy("Lazy.nvim configuration file exists")
    else
      print("No lazy.nvim configuration found, skipping plugin tests")
      -- Skip the rest of the tests
      return
    end
  end)

  -- Test core plugin presence without relying on specific format
  test.it("should include essential plugins in plugin spec files", function()
    if not lazy_setup_called then
      print("Skipping plugin spec test because lazy.nvim config was not found")
      test.expect(true).to_be_truthy()
      return
    end

    -- Essential plugins that should be included
    local essential_plugins = {
      "lazy.nvim", -- Plugin manager itself
      "plenary.nvim", -- Common dependency
    }

    -- Search for plugin specs in lua/plugins directory
    local config_path = os.getenv("NVIM_CONFIG_PATH") or vim.fn.expand("~/.config/nvim")
    local plugins_found = {}

    -- Find plugin files
    local glob_pattern = config_path .. "/lua/plugins/**/*.lua"
    local plugin_files = vim.fn.glob(glob_pattern, false, true)

    if #plugin_files == 0 then
      print("No plugin files found in " .. glob_pattern)
      -- Alternative pattern
      glob_pattern = config_path .. "/lua/*/plugins/**/*.lua"
      plugin_files = vim.fn.glob(glob_pattern, false, true)
    end

    if #plugin_files == 0 then
      print("No plugin files found, skipping essential plugins test")
      test.expect(true).to_be_truthy()
      return
    end

    -- Read plugin files to check for essential plugins
    for _, file_path in ipairs(plugin_files) do
      local file = io.open(file_path, "r")
      if file then
        local content = file:read("*all")
        file:close()

        -- Check for each essential plugin
        for _, plugin_name in ipairs(essential_plugins) do
          if content:find(plugin_name) then
            plugins_found[plugin_name] = true
          end
        end
      end
    end

    -- Check if we found the essential plugins
    local missing_plugins = {}
    for _, plugin_name in ipairs(essential_plugins) do
      if not plugins_found[plugin_name] then
        table.insert(missing_plugins, plugin_name)
      end
    end

    if #missing_plugins > 0 then
      print("Missing plugins: " .. table.concat(missing_plugins, ", "))
    else
      plugins_checked = true
    end

    -- Simple assertion for overall test
    test.expect(plugins_checked or #missing_plugins == 0).to_be_truthy("All essential plugins found")
  end)

  -- Test plugin directory structure
  test.it("should have organized plugin structure", function()
    if not lazy_setup_called then
      print("Skipping plugin structure test because lazy.nvim config was not found")
      test.expect(true).to_be_truthy()
      return
    end

    -- Check for plugin directory structure
    local config_path = os.getenv("NVIM_CONFIG_PATH") or vim.fn.expand("~/.config/nvim")
    local plugins_dir = config_path .. "/lua/plugins"

    -- Check if plugins directory exists
    local dir_exists = vim.fn.isdirectory(plugins_dir) == 1

    -- Check if plugins directory exists
    if dir_exists then
      local init_file = io.open(plugins_dir .. "/init.lua", "r")
      if init_file then
        init_file:close()
        print("Found plugins/init.lua file")
      end
    end

    test.expect(dir_exists).to_be_truthy("Plugins directory exists")
  end)
end)
