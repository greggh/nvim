------------------------------------------
-- NEOVIM MAINTENANCE UTILITIES
------------------------------------------
-- This module provides utilities for maintaining a clean and efficient Neovim setup
-- by managing cache files, log files, and other temporary data

local M = {}

-- Clean Neovim cache files that are older than a specified number of days
function M.clean_cache_files(days_old)
  -- Default to 30 days if not specified
  days_old = days_old or 30

  local cache_dir = vim.fn.stdpath("cache")
  local data_dir = vim.fn.stdpath("data")
  local log_dir = vim.fn.stdpath("log")

  -- List of directories to clean up
  local clean_dirs = {
    cache_dir .. "/nvim", -- General cache
    data_dir .. "/shada", -- Session history
    data_dir .. "/swap", -- Swap files
    data_dir .. "/view", -- View files
    log_dir, -- Log files
    cache_dir .. "/luacache", -- Lua module cache
    cache_dir .. "/lazy/cache", -- Lazy plugin cache
  }

  -- Count removed files
  local removed_count = 0
  local total_size = 0

  -- Current time in seconds
  local now = os.time()
  local cutoff_time = now - (days_old * 24 * 60 * 60)

  -- Process each directory
  for _, dir in ipairs(clean_dirs) do
    if vim.fn.isdirectory(dir) == 1 then
      local files = vim.fn.glob(dir .. "/*", false, true)

      for _, file in ipairs(files) do
        -- Skip directories
        if vim.fn.isdirectory(file) ~= 1 then
          local last_modified = vim.fn.getftime(file)

          -- Check if the file is older than the cutoff time
          if last_modified > 0 and last_modified < cutoff_time then
            -- Get file size before deletion
            local file_size = vim.fn.getfsize(file)
            if file_size > 0 then
              total_size = total_size + file_size
            end

            -- Try to delete the file
            if vim.fn.delete(file) == 0 then
              removed_count = removed_count + 1
            end
          end
        end
      end
    end
  end

  -- Format the total size in a human-readable format
  local function format_size(bytes)
    local units = { "B", "KB", "MB", "GB" }
    local size = bytes
    local unit_index = 1

    while size > 1024 and unit_index < #units do
      size = size / 1024
      unit_index = unit_index + 1
    end

    return string.format("%.2f %s", size, units[unit_index])
  end

  -- Show notification with results
  local ui = require("utils.ui")
  if removed_count > 0 then
    ui.notify_operation_status(
      "Cache Cleanup",
      "success",
      string.format("Removed %d old cache files (freed %s)", removed_count, format_size(total_size))
    )
  else
    ui.notify_operation_status("Cache Cleanup", "info", "No old cache files found to remove")
  end

  return removed_count, total_size
end

-- Setup periodic cache cleaning
function M.setup_auto_cleanup()
  -- Check for cache files older than 30 days once a week
  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
      -- Check if we already cleaned up recently
      local last_cleanup = vim.g.last_cache_cleanup or 0
      local now = os.time()
      local week_seconds = 7 * 24 * 60 * 60

      -- If it's been more than a week since last cleanup
      if now - last_cleanup > week_seconds then
        -- Use defer_fn to not slow down startup
        vim.defer_fn(function()
          local ui = require("utils.ui")
          ui.notify_operation_status("Maintenance", "info", "Running scheduled cache cleanup in background...")

          -- Run in background after a delay
          vim.defer_fn(function()
            M.clean_cache_files(30)
            vim.g.last_cache_cleanup = now
          end, 2000) -- Slight delay after notification
        end, 10000) -- Wait 10 seconds after startup
      end
    end,
    once = true,
  })
end

-- Reduce log file sizes by truncating large log files
function M.truncate_large_logs(max_size_mb)
  max_size_mb = max_size_mb or 10 -- Default 10MB limit
  local max_bytes = max_size_mb * 1024 * 1024

  local log_dir = vim.fn.stdpath("log")
  local logs = vim.fn.glob(log_dir .. "/*.log", false, true)

  local truncated = 0

  for _, log_file in ipairs(logs) do
    local file_size = vim.fn.getfsize(log_file)

    if file_size > max_bytes then
      -- Backup the file before truncating
      local backup = log_file .. ".bak"
      vim.fn.rename(log_file, backup)

      -- Read only the last part of the file to keep
      local keep_size = max_bytes * 0.7 -- Keep 70% of max size
      local lines_to_keep = {}

      local file = io.open(backup, "r")
      if file then
        -- Skip to the part we want to keep
        local pos = file_size - keep_size
        if pos > 0 then
          file:seek("set", pos)
          -- Discard partial line
          ---@diagnostic disable-next-line: discard-returns
          file:read("*line")
        end

        -- Read remaining lines
        for line in file:lines() do
          table.insert(lines_to_keep, line)
        end
        file:close()

        -- Write truncated file
        file = io.open(log_file, "w")
        if file then
          file:write("--- LOG TRUNCATED AT " .. os.date("%Y-%m-%d %H:%M:%S") .. " ---\n")
          file:write(table.concat(lines_to_keep, "\n"))
          file:close()
          truncated = truncated + 1

          -- Delete backup
          vim.fn.delete(backup)
        end
      end
    end
  end

  if truncated > 0 then
    require("utils.ui").notify_operation_status(
      "Log Maintenance",
      "info",
      string.format("Truncated %d large log files", truncated)
    )
  end

  return truncated
end

-- Register user commands for maintenance tasks
function M.register_commands()
  -- Command to clean cache files manually
  vim.api.nvim_create_user_command("CleanCache", function(opts)
    local days = tonumber(opts.args) or 30
    M.clean_cache_files(days)
  end, {
    desc = "Clean Neovim cache files older than specified days (default: 30)",
    nargs = "?",
  })

  -- Command to truncate large log files
  vim.api.nvim_create_user_command("TruncateLogs", function(opts)
    local size_mb = tonumber(opts.args) or 10
    M.truncate_large_logs(size_mb)
  end, {
    desc = "Truncate large log files over specified size in MB (default: 10)",
    nargs = "?",
  })

  -- Command to run all maintenance tasks
  vim.api.nvim_create_user_command("Maintenance", function()
    M.clean_cache_files()
    M.truncate_large_logs()
  end, {
    desc = "Run all Neovim maintenance tasks",
  })
end

-- Setup everything
function M.setup()
  M.setup_auto_cleanup()
  M.register_commands()
end

return M
