-- Basic test spec
local test = require("tests.run_tests")

test.describe("Basic Functionality", function()
  test.it("Neovim version should be 0.10.0 or higher", function()
    local version = vim.version()
    local version_string = string.format("%d.%d.%d", version.major, version.minor, version.patch)

    -- Major version must be 0
    test.expect(version.major).to_be(0)

    -- Minor version must be 10 or higher
    test.expect(version.minor >= 10).to_be_truthy()

    print("Neovim version: " .. version_string)
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
