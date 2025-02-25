-- Track startup time with more granular logging
local startup_time = os.clock()
local startup_timestamps = {}

local function track(name)
  local start = os.clock()
  local module = require(name)
  startup_timestamps[name] = os.clock() - start
  return module
end

-- Load modules sequentially to measure their individual times
require("config.flags")
startup_timestamps["config.flags"] = os.clock() - startup_time
local last_time = os.clock()

require("config.options")
startup_timestamps["config.options"] = os.clock() - last_time
last_time = os.clock()

require("config.lazy")
startup_timestamps["config.lazy"] = os.clock() - last_time
last_time = os.clock()

require("config.keymaps")
startup_timestamps["config.keymaps"] = os.clock() - last_time
last_time = os.clock()

require("config.autocmd")
startup_timestamps["config.autocmd"] = os.clock() - last_time

-- Report startup time - enhanced with module timing when NVIM_PROFILE is set
if os.getenv("NVIM_PROFILE") then
  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
      local end_time = os.clock()
      local total_time = (end_time - startup_time) * 1000
      
      -- Create log file paths - one with timestamp for history, one latest
      local timestamp = os.date("%Y%m%d_%H%M%S")
      local log_path = vim.fn.stdpath("cache") .. "/nvim_startup_" .. timestamp .. ".log"
      local latest_log_path = vim.fn.stdpath("cache") .. "/nvim_startup.log"
      
      -- Generate log content
      local log_content = string.format("Neovim Startup: %.2f ms total\n\n", total_time)
      log_content = log_content .. "Module loading times:\n"
      
      -- Sort modules to get consistent ordering
      local sorted_modules = {}
      for module, _ in pairs(startup_timestamps) do
        table.insert(sorted_modules, module)
      end
      table.sort(sorted_modules)
      
      -- Calculate total module time
      local total_module_time = 0
      for _, module in ipairs(sorted_modules) do
        total_module_time = total_module_time + startup_timestamps[module]
      end
      
      -- Display each module's time
      for _, module in ipairs(sorted_modules) do
        local time_ms = startup_timestamps[module] * 1000
        local percentage = (startup_timestamps[module] / total_module_time) * 100
        log_content = log_content .. string.format("- %s: %.2f ms (%.1f%%)\n", 
                                                  module, time_ms, percentage)
      end
      
      log_content = log_content .. string.format("\nPost-module initialization: %.2f ms\n", 
                                  (end_time - (last_time or startup_time)) * 1000)
      
      -- Write to timestamped log file
      local log_file = io.open(log_path, "w")
      if log_file then
        log_file:write(log_content)
        log_file:close()
      end
      
      -- Also write to latest log file
      local latest_log_file = io.open(latest_log_path, "w")
      if latest_log_file then
        latest_log_file:write(log_content)
        latest_log_file:close()
        
        print(string.format("Startup Time: %.2f ms (details in %s)", total_time, latest_log_path))
      else
        print(string.format("Startup Time: %.2f ms", total_time))
      end
    end,
  })
end