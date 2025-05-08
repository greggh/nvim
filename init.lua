-- "Load the profiling module and include error handling."
local profile_module
pcall(function()
  profile_module = require("utils.profile").setup()

  -- Register global access to profiling module for easier debugging
  _G.profile_module = profile_module

  -- Record events if profiling is enabled
  if os.getenv("NVIM_PROFILE") then
    profile_module.record_event("profile_module_loaded")
    profile_module.record_event("init_start")
  end
end)

-- Track startup time with more granular logging
local startup_time = os.clock()
local module_timing = {}

local function track(name)
  local start = os.clock()
  local module = require(name)
  local duration = os.clock() - start
  table.insert(module_timing, { name = name, time = duration })

  -- Record in profile module if profiling is enabled
  if os.getenv("NVIM_PROFILE") and profile_module then
    pcall(function()
      profile_module.record_event("load_" .. name)
      profile_module.record_plugin(name, duration)
    end)
  end

  return module
end
-- Use a single table to track timing information
local timing = {

  start = startup_time,
  modules = {},
  events = {},
  flags = {
    preload_enabled = true, -- Enable smart module preloading
    defer_ui_init = true, -- Defer UI initialization
    batch_lsp_setup = true, -- Batch LSP server setup
  },
}

-- Track timing for a named event
local function mark_event(name)
  local now = os.clock()
  local duration = now - timing.start
  timing.events[name] = {
    time = duration,
    timestamp = now,
  }

  -- Record in profile module if profiling is enabled
  if os.getenv("NVIM_PROFILE") and profile_module then
    pcall(function()
      profile_module.record_event(name)
    end)
  end

  return now
end

-- Load core modules sequentially to measure their individual times
track("config.flags")
timing.modules["config.flags"] = os.clock() - startup_time
local last_time = os.clock()

track("config.options")
timing.modules["config.options"] = os.clock() - last_time
last_time = os.clock()

track("config.lazy")
timing.modules["config.lazy"] = os.clock() - last_time
last_time = os.clock()

track("config.keymaps")
timing.modules["config.keymaps"] = os.clock() - last_time
last_time = os.clock()

track("config.autocmd")
timing.modules["config.autocmd"] = os.clock() - last_time

-- After core modules are loaded, do optimization-specific setup
mark_event("core_modules_loaded")

-- Register more event markers
vim.api.nvim_create_autocmd("UIEnter", {
  callback = function()
    mark_event("ui_enter")
  end,
  once = true,
})

vim.api.nvim_create_autocmd("User", {
  pattern = "LazyDone",
  callback = function()
    mark_event("lazy_done")
  end,
  once = true,
})

vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    mark_event("very_lazy")
  end,
  once = true,
})

-- Preload common modules in the background after a small delay
if timing.flags.preload_enabled then
  vim.defer_fn(function()
    local preload = require("utils.preload")
    preload.preload_common_modules()

    -- Set up filetype-based preloading
    vim.api.nvim_create_autocmd("FileType", {
      callback = function(args)
        local filetype = args.match
        vim.defer_fn(function()
          preload.preload_filetype_modules(filetype)
        end, 100) -- Small delay after filetype is set
      end,
    })
  end, 100) -- Wait for the editor to settle before preloading
end

-- Report startup time - enhanced with module timing when NVIM_PROFILE is set
if os.getenv("NVIM_PROFILE") then
  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
      local end_time = os.clock()
      mark_event("vim_enter")
      local total_time = (end_time - startup_time) * 1000

      -- Create log file paths - one with timestamp for history, one latest
      local timestamp = os.date("%Y%m%d_%H%M%S")
      local log_path = vim.fn.stdpath("cache") .. "/nvim_startup_" .. timestamp .. ".log"
      local latest_log_path = vim.fn.stdpath("cache") .. "/nvim_startup.log"

      -- Generate log content
      local log_content = string.format("Neovim Startup: %.2f ms total\n\n", total_time)

      -- Log events timing
      log_content = log_content .. "Events:\n"
      local sorted_events = {}
      for event, _ in pairs(timing.events) do
        table.insert(sorted_events, event)
      end
      table.sort(sorted_events)

      for _, event in ipairs(sorted_events) do
        local time_ms = timing.events[event].time * 1000
        log_content = log_content .. string.format("- %s: %.2f ms\n", event, time_ms)
      end

      log_content = log_content .. "\nModule loading times:\n"

      -- Sort modules to get consistent ordering
      local sorted_modules = {}
      for module, _ in pairs(timing.modules) do
        table.insert(sorted_modules, module)
      end
      table.sort(sorted_modules)

      -- Calculate total module time
      local total_module_time = 0
      for _, module in ipairs(sorted_modules) do
        total_module_time = total_module_time + timing.modules[module]
      end

      -- Display each module's time
      for _, module in ipairs(sorted_modules) do
        local time_ms = timing.modules[module] * 1000
        local percentage = (timing.modules[module] / total_module_time) * 100
        log_content = log_content .. string.format("- %s: %.2f ms (%.1f%%)\n", module, time_ms, percentage)
      end

      -- Additional performance metrics
      log_content = log_content
        .. string.format("\nPost-module initialization: %.2f ms\n", (end_time - (last_time or startup_time)) * 1000)

      -- System information for comparison
      log_content = log_content .. "\nSystem Information:\n"
      log_content = log_content .. string.format("- Neovim Version: %s\n", vim.version())

      -- Memory usage
      local memory_info = vim.loop.resident_set_memory()
      log_content = log_content .. string.format("- Memory Usage: %.2f MB\n", memory_info / 1024 / 1024)

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

      -- Run our separate profiler too (for more details)
      vim.defer_fn(function()
        if profile_module then
          pcall(function()
            profile_module.write_profile_log()
          end)
        end
      end, 1000) -- Wait a bit to ensure everything is loaded
    end,
  })

  -- Register commands for profiling
  vim.api.nvim_create_user_command("ProfileDetail", function()
    if profile_module then
      pcall(function()
        profile_module.write_profile_log()
      end)
    else
      -- Attempt to load profile module directly
      pcall(function()
        require("utils.profile").setup().write_profile_log()
      end)
    end
  end, { desc = "Generate detailed profiling report" })

  -- Set up an autocmd to register all profile commands after startup
  vim.api.nvim_create_autocmd("VimEnter", {
    pattern = "*",
    callback = function()
      vim.defer_fn(function()
        -- Load and setup profile commands
        local status, msg = pcall(function()
          return require("utils.profile_commands").setup_commands()
        end)

        if status and msg then
          vim.notify(msg, vim.log.levels.INFO)

          -- Update keymaps to use the commands
          local keymap_cmd = vim.keymap.set
          keymap_cmd("n", "<leader>pp", "<cmd>Profile<CR>", { silent = true, desc = "Generate profile report" })
          keymap_cmd("n", "<leader>ps", "<cmd>ProfileSummary<CR>", { silent = true, desc = "Show profile summary" })
          keymap_cmd("n", "<leader>pL", "<cmd>ProfileLogs<CR>", { silent = true, desc = "List profile logs" })
          keymap_cmd(
            "n",
            "<leader>pa",
            "<cmd>ProfilePlugins<CR>",
            { silent = true, desc = "Analyze plugin performance" }
          )
        end
      end, 500) -- Short delay to ensure everything is loaded
    end,
    once = true,
  })
end
