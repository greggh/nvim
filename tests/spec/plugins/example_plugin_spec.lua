-- Example plugin test
-- This file is kept for reference but not actively used in testing

-- This commented out example shows how to structure plugin tests

--[[
local test = require("tests.run_tests")

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
end)
--]]

-- Just define an empty test to prevent errors
local test = require("tests.run_tests")
test.describe("Example Plugin Test (Reference Only)", function()
  test.it("should always pass", function()
    test.expect(true).to_be_truthy()
  end)
end)
