-- Standalone profiling module for Neovim optimization
local M = {}

-- Store profile data
local profile_data = {
  start_time = os.clock(),
  events = {},
  plugins = {},
}

-- Create profile log
function M.write_profile_log()
  -- Make sure we have data
  if not profile_data.events then
    profile_data.events = {}
  end
  
  -- Calculate runtime
  local runtime = os.clock() - profile_data.start_time
  
  -- Create log path
  local log_path = vim.fn.stdpath("cache") .. "/nvim_profile_" .. os.date("%Y%m%d_%H%M%S") .. ".log"
  local log_file = io.open(log_path, "w")
  
  if not log_file then
    vim.notify("Could not create profile log: " .. log_path, vim.log.levels.ERROR)
    return
  end
  
  -- Write header
  log_file:write("# Neovim Profile Report\n")
  log_file:write("Generated: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n")
  log_file:write("Runtime: " .. string.format("%.2f ms\n\n", runtime * 1000))
  
  -- System information
  log_file:write("## System Information\n")
  -- Get version safely
  local nvim_version = ""
  if type(vim.version) == "function" then
    nvim_version = vim.version()
  elseif type(vim.version) == "table" then
    if vim.version.major then
      nvim_version = vim.version.major .. "." .. 
                     (vim.version.minor or "0") .. "." .. 
                     (vim.version.patch or "0")
    end
  end
  log_file:write("- Neovim Version: " .. nvim_version .. "\n")
  
  -- Memory usage
  if vim.loop.resident_set_memory then
    local memory = vim.loop.resident_set_memory()
    log_file:write("- Memory Usage: " .. string.format("%.2f MB\n", memory / 1024 / 1024))
  end
  
  -- Event timings
  log_file:write("\n## Event Timings\n")
  for event, time in pairs(profile_data.events) do
    log_file:write("- " .. event .. ": " .. string.format("%.2f ms\n", time * 1000))
  end
  
  -- Plugin analysis (if available)
  if #profile_data.plugins > 0 then
    log_file:write("\n## Plugin Analysis\n")
    
    -- Sort plugins by time
    table.sort(profile_data.plugins, function(a, b)
      return a.time > b.time
    end)
    
    -- Write top 20 plugins
    for i = 1, math.min(20, #profile_data.plugins) do
      local plugin = profile_data.plugins[i]
      log_file:write(string.format("- %s: %.2f ms\n", plugin.name, plugin.time * 1000))
    end
  end
  
  -- Collect loaded modules
  log_file:write("\n## Loaded Modules\n")
  local modules = {}
  for modname, _ in pairs(package.loaded) do
    table.insert(modules, modname)
  end
  table.sort(modules)
  
  -- Show module load status
  for _, modname in ipairs(modules) do
    if not modname:match("^_") then -- Skip internal modules
      log_file:write("- " .. modname .. "\n")
    end
  end
  
  log_file:close()
  
  -- Report success
  vim.notify("Profile written to: " .. log_path, vim.log.levels.INFO)
  return log_path
end

-- Record an event
function M.record_event(name)
  profile_data.events[name] = os.clock() - profile_data.start_time
end

-- Record a plugin load
function M.record_plugin(name, time)
  table.insert(profile_data.plugins, { name = name, time = time })
end

-- Profile a function
function M.profile_func(func, name)
  local start = os.clock()
  local result = func()
  local elapsed = os.clock() - start
  
  profile_data.events[name or "function"] = elapsed
  
  return result, elapsed
end

-- Create user command
function M.setup()
  vim.api.nvim_create_user_command("Profile", function()
    M.write_profile_log()
  end, { desc = "Generate a profile report" })
  
  -- Auto-record some common events
  vim.api.nvim_create_autocmd("UIEnter", {
    callback = function()
      M.record_event("ui_enter")
    end,
    once = true
  })
  
  vim.api.nvim_create_autocmd("BufRead", {
    callback = function()
      M.record_event("first_buf_read")
    end,
    once = true
  })
  
  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
      M.record_event("vim_enter")
    end,
    once = true
  })
  
  return M
end

return M