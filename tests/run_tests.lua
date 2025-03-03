-- Test runner for Neovim config
-- Inspired by laravel-helper plugin test framework

local M = {}

-- Variables to track test results
local test_counts = {
  passed = 0,
  failed = 0,
  total = 0,
}

local errors = {}

-- Test result tracking functions
local function record_pass()
  test_counts.passed = test_counts.passed + 1
  test_counts.total = test_counts.total + 1
  if vim.g._test_verbose then
    print("✅ TEST PASSED")
  end
end

local function record_fail(message, trace)
  test_counts.failed = test_counts.failed + 1
  test_counts.total = test_counts.total + 1
  local error_info = {
    message = message or "Test failed without error message",
    trace = trace or debug.traceback("Test failed", 2),
  }
  table.insert(errors, error_info)
  print("❌ TEST FAILED: " .. error_info.message)
end

-- Testing API
function M.describe(description, tests_fn)
  print("\n=== " .. description .. " ===")
  tests_fn()
end

function M.it(description, test_fn)
  io.write("- " .. description .. "... ")
  io.flush()

  local status, err = pcall(test_fn)

  if status then
    record_pass()
  else
    record_fail(err)
  end
end

function M.expect(value)
  return {
    to_be = function(expected)
      if value ~= expected then
        error(string.format("Expected %s but got %s", vim.inspect(expected), vim.inspect(value)))
      end
    end,

    to_be_truthy = function()
      if not value then
        error("Expected value to be truthy but got " .. vim.inspect(value))
      end
    end,

    to_be_falsy = function()
      if value then
        error("Expected value to be falsy but got " .. vim.inspect(value))
      end
    end,

    to_contain = function(expected)
      if type(value) ~= "table" then
        error("Expected a table but got " .. type(value))
      end

      local found = false
      for _, v in ipairs(value) do
        if v == expected then
          found = true
          break
        end
      end

      if not found then
        error("Expected table to contain " .. vim.inspect(expected))
      end
    end,

    to_equal = function(expected)
      if vim.deep_equal(value, expected) ~= true then
        error(string.format("Expected %s to equal %s", vim.inspect(value), vim.inspect(expected)))
      end
    end,

    to_match = function(pattern)
      if type(value) ~= "string" then
        error("Expected a string but got " .. type(value))
      end

      if not string.match(value, pattern) then
        error(string.format("Expected '%s' to match pattern '%s'", value, pattern))
      end
    end,
  }
end

-- Run all tests from a directory
function M.run_tests(dir)
  vim.g._test_verbose = vim.g._test_verbose or false

  local test_files = vim.fn.globpath(dir, "**/*_spec.lua", false, true)

  print("\n==================================")
  print("Running " .. #test_files .. " test files")
  print("==================================\n")

  for _, file in ipairs(test_files) do
    print("\nRunning tests from: " .. file)
    dofile(file)
  end

  -- Print summary
  print("\n==================================")
  print(
    string.format(
      "Test Results: %d total, %d passed, %d failed",
      test_counts.total,
      test_counts.passed,
      test_counts.failed
    )
  )

  if #errors > 0 then
    print("\nErrors:")
    for i, err in ipairs(errors) do
      print(string.format("\n%d) %s\n%s", i, err.message, err.trace))
    end
  end

  print("==================================")

  -- Return non-zero exit code if tests failed
  if test_counts.failed > 0 then
    vim.cmd("cquit " .. test_counts.failed)
  else
    print("\n✅ All tests passed!")
    vim.cmd("quit") -- Explicitly exit Neovim with success
  end
end

-- Export module
return M
