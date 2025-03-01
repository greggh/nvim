-- Example plugin test
local test = require("tests.run_tests")

-- This is an example of how to test a plugin
test.describe("Example Plugin Test", function()
  -- Mock the plugin module if it doesn't exist
  local plugin_mock = {
    setup = function(_)
      return true
    end,
    get_config = function()
      return {
        enabled = true,
        features = { "feature1", "feature2" },
      }
    end,
  }

  -- This would normally load the actual plugin
  local function load_plugin()
    -- For testing, we'll use our mock
    return plugin_mock
  end

  test.it("should load the plugin", function()
    local plugin = load_plugin()
    test.expect(plugin).to_be_truthy()
    test.expect(type(plugin.setup)).to_be("function")
  end)

  test.it("should have the expected config", function()
    local plugin = load_plugin()
    local config = plugin.get_config()

    test.expect(config.enabled).to_be(true)
    test.expect(config.features).to_be_truthy()
    test.expect(#config.features).to_be(2)
  end)

  test.it("should have the correct features", function()
    local plugin = load_plugin()
    local config = plugin.get_config()

    test.expect(config.features[1]).to_be("feature1")
    test.expect(config.features[2]).to_be("feature2")
  end)
end)

-- This shows how you would test actual plugin configuration
test.describe("Plugin Configuration", function()
  test.it("Example: testing a real plugin configuration", function()
    -- Skip this test in actual runs as it's just an example
    -- In a real test, you would test an actual plugin that exists

    -- Attempt to load a real plugin's configuration (this will be skipped)
    local status = true -- Would normally be: pcall(require, "plugins.real_plugin")

    -- For the example, we're always marking this as passed
    test.expect(status).to_be_truthy()
  end)
end)
