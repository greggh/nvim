-- Basic test spec
local test = require("tests.run_tests")

test.describe("Basic Functionality", function()
  test.it("Neovim version should be 0.9.0 or higher", function()
    local version = vim.version()
    local version_string = string.format("%d.%d.%d", version.major, version.minor, version.patch)

    -- Print version for diagnostics
    print("Neovim version: " .. version_string)

    -- Version tests - supports both 0.9+ (stable) and future 1.0+
    if version.major == 0 then
      -- For 0.x versions, minor version must be 9 or higher
      test.expect(version.minor >= 9).to_be_truthy()
    else
      -- For 1.x+ versions (future), any minor version is fine
      test.expect(version.major >= 1).to_be_truthy()
    end
  end)

  test.it("Test mode flag should be set", function()
    test.expect(vim.g._test_mode).to_be_truthy()
  end)

  test.it("Required global variables should exist", function()
    -- Test that vim.g has common settings
    test.expect(vim.g).to_be_truthy()
    test.expect(type(vim.g)).to_be("table")
  end)
end)
