# Neovim Configuration Tests

This directory contains tests for the Neovim configuration files.

## Test Structure

- `minimal-init.lua`: Minimal Lua initialization for tests
- `run_tests.lua`: Main test runner with testing API
- `test_config.lua`: Configuration for tests
- `spec/`: Directory containing test specifications
  - `basic_spec.lua`: Basic tests for verifying test environment
  - `config_spec.lua`: Tests for configuration modules
  - `keymappings_spec.lua`: Tests for keybinding configurations
  - `plugin_management_spec.lua`: Tests for lazy.nvim and plugin setup
  - `ui_components_spec.lua`: Tests for UI components like statusline
  - `plugins/example_plugin_spec.lua`: Example of testing plugin configurations

## Running Tests

You can run tests using the following commands:

```bash
# Run all tests
make test

# Run with verbose output
make test-verbose

# Run the test script directly
./tests/scripts/run_tests.sh
```

Tests run automatically as part of the pre-commit hook and in CI workflows. The tests use a standardized `minimal-init.lua` initialization file that works across all related Neovim projects.

## Writing Tests

Tests use a simple BDD-style API:

```lua
local test = require("tests.run_tests")

test.describe("Module Name", function()
  test.it("should do something", function()
    -- Test code here
    test.expect(something).to_be(expected_value)
  end)
end)
```

### Mocking Dependencies

The testing framework includes mocks for common Neovim plugins and modules. When testing modules that depend on external plugins, the framework provides mock implementations to ensure tests can run without the actual plugins being installed.

Key mocked plugins include:

- `luasnip`: Full mock of snippet functionality
- `nvim-treesitter`: Basic setup functions
- `cmp`: Completion plugin with mapping functions
- Other common plugins (telescope, lspconfig, mason, etc.)

To extend the mocks for additional plugins, edit `tests/minimal-init.lua` and add the mock implementation in the `setup_mocks()` function:

```lua
-- Example: Mock a new plugin
package.loaded['new-plugin'] = {
  setup = function() return true end,
  some_function = function() return "mocked value" end
}
```

### Available Assertions

- `to_be(value)`: Check exact equality
- `to_be_truthy()`: Check if value is truthy (not false or nil)
- `to_be_falsy()`: Check if value is falsy (false or nil)
- `to_contain(value)`: Check if table contains value
- `to_equal(value)`: Check deep equality for tables
- `to_match(pattern)`: Check if string matches pattern

## Running in GitHub Actions

These tests are designed to be run in CI environments and will return appropriate exit codes
to signal test failures.