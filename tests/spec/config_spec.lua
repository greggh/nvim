-- Config tests
local test = require("tests.run_tests")

test.describe("Configuration", function()
  -- Print a debug message
  print("Testing configuration modules...")

  -- Test each module separately to identify which one is failing
  test.it("Module options should load without errors", function()
    local status, module = pcall(require, "config.options")
    test.expect(status).to_be_truthy()
    if not status then
      print("Error loading options: " .. tostring(module))
    end
  end)

  test.it("Module keymaps should load without errors", function()
    local status, module = pcall(require, "config.keymaps")
    test.expect(status).to_be_truthy()
    if not status then
      print("Error loading keymaps: " .. tostring(module))
    end
  end)

  test.it("Module autocmd should load without errors", function()
    print("Attempting to load config.autocmd...")
    -- Try to load the module with proper mocking
    local status, result = pcall(require, "config.autocmd")

    -- Print diagnostic information
    print("Load status: " .. tostring(status))
    if not status then
      print("Error loading autocmd: " .. tostring(result))
    end

    -- Now we should be able to properly load the module
    test.expect(status).to_be_truthy()
    test.expect(result).to_be_truthy()
  end)

  test.it("Options module should set basic editor options", function()
    -- Load options module
    require("config.options")

    -- Check a few key options
    test.expect(vim.opt.number:get()).to_be_truthy()
    test.expect(vim.opt.termguicolors:get()).to_be_truthy()
    test.expect(vim.opt.mouse:get()).to_be_truthy()
  end)

  test.it("Keymaps module should define leader key", function()
    -- Load keymaps module
    require("config.keymaps")

    -- Check if mapleader is set
    test.expect(vim.g.mapleader).to_be(" ")
  end)
end)
