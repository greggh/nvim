-- Standalone profiling module for Neovim optimization
local M = {}

-- Store profile data
local profile_data = {
  start_time = os.clock(),
  events = {},
  plugins = {},
}

-- Flag to ensure commands are only registered once
local commands_registered = false

-- Get Neovim version safely using multiple approaches
local function get_nvim_version()
  local nvim_version = "Unknown"

  -- Try vim.version() function first (newer Neovim versions)
  if type(vim.version) == "function" then
    local v = vim.version()
    if type(v) == "string" then
      nvim_version = v
    end
  end

  -- If that didn't work, try the vim.version table
  if nvim_version == "Unknown" and type(vim.version) == "table" then
    if vim.version.major then
      nvim_version = vim.version.major .. "." .. (vim.version.minor or "0") .. "." .. (vim.version.patch or "0")
    end
  end

  -- If both failed, try api.nvim_get_version()
  if nvim_version == "Unknown" then
    local ok, v = pcall(function()
      return vim.api.nvim_get_version()
    end)
    if ok and type(v) == "table" and v.major then
      nvim_version = v.major .. "." .. v.minor .. "." .. v.patch
    end
  end

  -- As a last resort, try :version and parse output
  if nvim_version == "Unknown" then
    local ok, v = pcall(function()
      local output = vim.fn.execute("version")
      local ver = output:match("NVIM v([%d%.]+)")
      return ver or "Unknown"
    end)
    if ok and v ~= "Unknown" then
      nvim_version = v
    end
  end

  return nvim_version
end

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
  -- Get version using our helper function
  local nvim_version = get_nvim_version()
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

-- Display profile summary in a float window
function M.show_profile_summary()
  -- Get current memory usage
  local memory = vim.loop.resident_set_memory and vim.loop.resident_set_memory() or 0
  local memory_mb = memory / 1024 / 1024

  -- Get Neovim version
  local nvim_version = get_nvim_version()

  -- Check if we have startup logs
  local startup_log_path = vim.fn.stdpath("cache") .. "/nvim_startup.log"
  local startup_data = ""
  local startup_file = io.open(startup_log_path, "r")
  if startup_file then
    startup_data = startup_file:read("*a")
    startup_file:close()
  end

  -- Create buffer content
  local lines = {
    "# Neovim Profile Summary",
    "",
    "## Current State",
    string.format("- Neovim Version: %s", nvim_version),
    string.format("- Memory Usage: %.2f MB", memory_mb),
    string.format("- Uptime: %.2f s", os.clock() - profile_data.start_time),
    string.format("- Loaded Modules: %d", vim.tbl_count(package.loaded)),
    "",
    "## Latest Startup Log",
    "",
  }

  -- Add startup data if available
  if startup_data ~= "" then
    for line in startup_data:gmatch("[^\r\n]+") do
      table.insert(lines, line)
    end
  else
    table.insert(lines, "No startup log available")
  end

  -- Create buffer and window
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  -- Apply markdown highlighting
  vim.bo[buf].filetype = "markdown"

  -- Calculate window size
  local width = math.min(80, vim.o.columns - 4)
  local height = math.min(#lines + 2, vim.o.lines - 4)

  -- Create window
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
    title = "Neovim Profile",
  })

  -- Set window options
  vim.wo[win].wrap = true
  vim.wo[win].conceallevel = 2
  vim.wo[win].foldenable = false

  -- Add keymaps to close the window
  vim.api.nvim_buf_set_keymap(buf, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
  vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", "<cmd>close<CR>", { noremap = true, silent = true })

  -- Set buffer options
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = "wipe"

  return buf, win
end

-- List profile logs in a floating window with selection capabilities
function M.list_profile_logs()
  local cache_dir = vim.fn.stdpath("cache")
  local log_files = vim.fn.glob(cache_dir .. "/nvim_profile_*.log", true, true)
  table.sort(log_files, function(a, b)
    return a > b
  end) -- Sort newest first

  if #log_files == 0 then
    vim.notify("No profile logs found", vim.log.levels.WARN)
    return
  end

  -- Create a nice display of the log files with their timestamps
  local lines = {}
  local file_lookup = {}

  ---@diagnostic disable-next-line: unused-local
  for i, file in ipairs(log_files) do
    local timestamp = file:match("nvim_profile_(%d%d%d%d%d%d%d%d_%d%d%d%d%d%d)%.log$")
    local display_line

    if timestamp then
      local formatted = timestamp:gsub("(%d%d%d%d)(%d%d)(%d%d)_(%d%d)(%d%d)(%d%d)", "%1-%2-%3 %4:%5:%6")
      display_line = string.format("%s - %s", formatted, vim.fn.fnamemodify(file, ":t"))
    else
      display_line = vim.fn.fnamemodify(file, ":t")
    end

    -- Add to our displayed lines and lookup table
    table.insert(lines, display_line)
    file_lookup[display_line] = file
  end

  -- Create buffer and window
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  -- Calculate window size
  local width = math.min(80, vim.o.columns - 4)
  local height = math.min(#lines + 2, vim.o.lines - 4)

  -- Create window
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
    title = "Profile Logs",
  })

  -- Set window options
  vim.wo[win].wrap = true
  vim.wo[win].foldenable = false
  vim.wo[win].cursorline = true

  -- Set up syntax highlighting for the log list
  vim.bo[buf].filetype = "markdown"

  -- Function to open the selected log
  local function open_selected_log()
    local cursor_pos = vim.api.nvim_win_get_cursor(win)
    local current_line = vim.api.nvim_buf_get_lines(buf, cursor_pos[1] - 1, cursor_pos[1], false)[1]
    local selected_file = file_lookup[current_line]

    if selected_file then
      -- Close picker window
      vim.api.nvim_win_close(win, true)

      -- Read the log file content
      local log_content = {}
      local file = io.open(selected_file, "r")
      if file then
        for line in file:lines() do
          table.insert(log_content, line)
        end
        file:close()
      else
        vim.notify("Could not open log file: " .. selected_file, vim.log.levels.ERROR)
        return
      end

      -- Create a new buffer for the log content
      local log_buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_lines(log_buf, 0, -1, false, log_content)

      -- Apply markdown formatting
      vim.bo[log_buf].filetype = "markdown"

      -- Calculate window size
      local win_width = math.min(90, vim.o.columns - 4)
      local win_height = math.min(#log_content + 2, vim.o.lines - 4)

      -- Create window for the log file
      local log_win = vim.api.nvim_open_win(log_buf, true, {
        relative = "editor",
        width = win_width,
        height = win_height,
        row = math.floor((vim.o.lines - win_height) / 2),
        col = math.floor((vim.o.columns - win_width) / 2),
        style = "minimal",
        border = "rounded",
        title = vim.fn.fnamemodify(selected_file, ":t"),
      })

      -- Set window options
      vim.wo[log_win].wrap = true
      vim.wo[log_win].conceallevel = 2
      vim.wo[log_win].foldenable = false

      -- Add keymaps to close the window
      vim.api.nvim_buf_set_keymap(log_buf, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
      vim.api.nvim_buf_set_keymap(log_buf, "n", "<Esc>", "<cmd>close<CR>", { noremap = true, silent = true })

      -- Set buffer options
      vim.bo[log_buf].modifiable = false
      vim.bo[log_buf].bufhidden = "wipe"

      -- Return to the beginning of the file
      vim.api.nvim_win_set_cursor(log_win, { 1, 0 })
    end
  end

  -- Add keymaps for selection
  vim.api.nvim_buf_set_keymap(buf, "n", "<CR>", "", {
    noremap = true,
    silent = true,
    callback = open_selected_log,
  })

  vim.api.nvim_buf_set_keymap(buf, "n", "<2-LeftMouse>", "", {
    noremap = true,
    silent = true,
    callback = open_selected_log,
  })

  -- Add keymaps to close the window
  vim.api.nvim_buf_set_keymap(buf, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
  vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", "<cmd>close<CR>", { noremap = true, silent = true })

  -- Set buffer options
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = "wipe"

  -- Add buffer-local autocommands
  vim.api.nvim_create_autocmd("BufLeave", {
    buffer = buf,
    callback = function()
      -- Auto-close the window when leaving
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
    end,
    once = true,
  })

  -- Set the cursor at the first item
  vim.api.nvim_win_set_cursor(win, { 1, 0 })

  return buf, win
end

-- Generate a detailed analysis of plugins
function M.analyze_plugins()
  -- Check if lazy is available
  local has_lazy, lazy_config = pcall(require, "lazy.core.config")
  if not has_lazy then
    vim.notify("Lazy.nvim not available", vim.log.levels.ERROR)
    return
  end

  local plugins = lazy_config.plugins
  local has_stats, stats = pcall(require, "lazy.stats")
  local stats_data = has_stats and stats.stats() or { count = 0, loaded = 0, startuptime = 0 }

  -- First, update the plugin mapping without showing a window
  M.update_plugin_mapping()

  -- Create a complete mapping of plugin references to names
  local plugin_lookup = {}

  -- Initialize if needed
  if not M.memory_address_to_name then
    M.memory_address_to_name = {}
  end

  -- Copy over all entries from the static mapping updated by debug_plugin_names
  -- Make sure it exists and is a table
  if M.memory_address_to_name and type(M.memory_address_to_name) == "table" then
    for addr, name in pairs(M.memory_address_to_name) do
      plugin_lookup[addr] = name
    end
  end

  -- Direct plugin object to name mapping
  for name, plugin in pairs(plugins) do
    -- Store the name with the plugin object as key
    plugin_lookup[plugin] = name

    -- Also store by string representation (memory address)
    local addr = tostring(plugin):gsub("table: ", "")
    plugin_lookup["plugin_" .. addr] = name
    plugin_lookup[addr] = name
    plugin_lookup["0x" .. addr:gsub("0x", "")] = name

    -- Store additional variations for better matching
    local addr_plain = addr:gsub("^0x", "")
    plugin_lookup["plugin_" .. addr_plain] = name
    plugin_lookup[addr_plain] = name
    plugin_lookup["0x" .. addr_plain] = name
    plugin_lookup["plugin_0x" .. addr_plain] = name

    -- Store by plugin name itself
    plugin_lookup[name] = name
  end

  -- Build a reverse lookup of all plugin_data entries to find their real names
  if profile_data.plugins and #profile_data.plugins > 0 then
    for i, plugin_data in ipairs(profile_data.plugins) do
      if plugin_data.name and plugin_data.name:match("^plugin_0x") then
        local addr = plugin_data.name:gsub("^plugin_", "")

        -- Try to find a real name for this plugin
        for name, plugin in pairs(plugins) do
          local plugin_addr = tostring(plugin):gsub("table: ", "")
          if addr == plugin_addr then
            -- We found a match! Update the stored name
            profile_data.plugins[i].name = name
            break
          end
        end
      end
    end
  end

  -- Get Neovim version
  local nvim_version = get_nvim_version()

  -- Create report
  local lines = {
    "# Neovim Plugin Analysis",
    "Generated: " .. os.date("%Y-%m-%d %H:%M:%S"),
    "",
    "## System Information",
    string.format("- Neovim Version: %s", nvim_version),
    string.format(
      "- Memory Usage: %.2f MB",
      vim.loop.resident_set_memory and vim.loop.resident_set_memory() / 1024 / 1024 or 0
    ),
    "",
    "## Plugin Manager Statistics",
    string.format("- Total plugins: %d", stats_data.count or vim.tbl_count(plugins)),
    string.format("- Loaded plugins: %d", stats_data.loaded or 0),
    string.format("- Startup time: %.2f ms", stats_data.startuptime or 0),
  }

  -- Get plugin loading times
  table.insert(lines, "")
  table.insert(lines, "## Heaviest Plugins (Startup Impact)")

  -- Collect plugins with load time info
  local load_times = {}
  local has_timing_data = false

  -- Try to get data from lazy.nvim first
  for name, plugin in pairs(plugins) do
    if plugin.loaded and plugin.time and plugin.time > 0 then
      has_timing_data = true
      table.insert(load_times, { name = name, time = plugin.time })
    end
  end

  -- Try to get data from lazy's plugin_times table if available
  local lazy_stats_data
  pcall(function()
    -- Access the plugin_times from the global scope or from require
    lazy_stats_data = _G.lazy_stats and _G.lazy_stats.plugin_times or nil
  end)

  if lazy_stats_data then
    for plugin, time in pairs(lazy_stats_data) do
      if time > 0 then
        has_timing_data = true
        -- Get plugin name
        local plugin_name
        if type(plugin) == "string" then
          plugin_name = plugin
        elseif type(plugin) == "table" and plugin.name then
          plugin_name = plugin.name
        else
          -- Try lookup
          plugin_name = plugin_lookup[plugin] or ("plugin_" .. tostring(plugin):gsub("table: ", ""))
        end

        -- Check if this plugin is already in our list
        local exists = false
        for _, p in ipairs(load_times) do
          if p.name == plugin_name then
            exists = true
            break
          end
        end

        if not exists then
          table.insert(load_times, { name = plugin_name, time = time })
        end
      end
    end
  end

  -- Always try to use our profile_data as it should have the most complete information
  if profile_data.plugins and #profile_data.plugins > 0 then
    for _, plugin_data in ipairs(profile_data.plugins) do
      if plugin_data.name and plugin_data.time and plugin_data.time > 0 then
        -- Check if we already have this plugin in our list
        local exists = false
        for _, p in ipairs(load_times) do
          if p.name == plugin_data.name then
            exists = true
            -- Update time if this is larger
            if plugin_data.time > p.time then
              p.time = plugin_data.time
            end
            break
          end
        end

        if not exists then
          has_timing_data = true
          -- Try to look up a better name if this is a memory address
          local name = plugin_data.name
          if type(name) == "string" and name:match("^plugin_0x") then
            local addr = name:gsub("^plugin_", "")
            name = plugin_lookup[addr] or plugin_lookup[name] or name
          end

          -- Final sanity check: if we have a plugin with this exact name, use that
          for plug_name, _ in pairs(plugins) do
            if string.lower(plug_name) == string.lower(name) then
              name = plug_name
              break
            end
          end

          table.insert(load_times, { name = name, time = plugin_data.time })
        end
      end
    end
  end

  -- If we still have no data but NVIM_PROFILE is set, suggest running with profiling
  if not has_timing_data then
    if not os.getenv("NVIM_PROFILE") then
      table.insert(lines, "No plugin timing data available. Try running with NVIM_PROFILE=1 for more details.")
      table.insert(lines, "Example: NVIM_PROFILE=1 nvim")
    else
      table.insert(lines, "No plugin timing data available yet. Try generating a profile report first.")
      table.insert(lines, "Use <leader>pp or :Profile to generate timing data.")
    end
  else
    -- Sort by load time
    table.sort(load_times, function(a, b)
      return a.time > b.time
    end)

    -- Add top 20 plugins to the report
    for i = 1, math.min(20, #load_times) do
      local plugin = load_times[i]
      -- Helper function to get a clean plugin name
      local function force_name(plugin_entry, index)
        local raw_name = plugin_entry.name
        local debug_output = {} -- For debugging

        -- Add debug message
        local function debug(msg)
          table.insert(debug_output, msg)
        end

        debug("Original name: " .. tostring(raw_name))

        -- Already a clean string name without memory address?
        if type(raw_name) == "string" and not raw_name:match("0x") then
          -- Try to match case exactly with a known plugin name
          for plug_name, _ in pairs(plugins) do
            if string.lower(plug_name) == string.lower(raw_name) then
              debug("Matched by name: " .. plug_name)
              return plug_name -- Return the proper case
            end
          end
          debug("Keeping original name")
          return raw_name -- Keep as is
        end

        -- Try lookup table if name is a reference
        if plugin_lookup[raw_name] then
          debug("Found in plugin_lookup direct key")
          return plugin_lookup[raw_name]
        end

        -- Is it a memory address format? Try different variants
        if type(raw_name) == "string" then
          -- With plugin_ prefix
          if raw_name:match("^plugin_0x") then
            local addr = raw_name:gsub("^plugin_", "")
            debug("Checking address: " .. addr)

            -- Try directly with the current format
            if plugin_lookup[addr] then
              debug("Found in plugin_lookup[addr]")
              return plugin_lookup[addr]
            end

            if M.memory_address_to_name[addr] then
              debug("Found in M.memory_address_to_name[addr]")
              return M.memory_address_to_name[addr]
            end

            -- Try without 0x prefix
            local addr_plain = addr:gsub("^0x", "")
            debug("Checking plain address: " .. addr_plain)

            if plugin_lookup[addr_plain] then
              debug("Found in plugin_lookup[addr_plain]")
              return plugin_lookup[addr_plain]
            end

            if M.memory_address_to_name[addr_plain] then
              debug("Found in M.memory_address_to_name[addr_plain]")
              return M.memory_address_to_name[addr_plain]
            end

            -- Try with 0x prefix regardless of source
            if not addr:match("^0x") then
              local addr_with_0x = "0x" .. addr
              debug("Checking with 0x: " .. addr_with_0x)

              if plugin_lookup[addr_with_0x] then
                debug("Found in plugin_lookup[addr_with_0x]")
                return plugin_lookup[addr_with_0x]
              end

              if M.memory_address_to_name[addr_with_0x] then
                debug("Found in M.memory_address_to_name[addr_with_0x]")
                return M.memory_address_to_name[addr_with_0x]
              end
            end
          end

          -- Direct address (with 0x prefix but no plugin_)
          if raw_name:match("^0x") then
            debug("Direct 0x address: " .. raw_name)

            if plugin_lookup[raw_name] then
              debug("Found in plugin_lookup direct 0x")
              return plugin_lookup[raw_name]
            end

            if M.memory_address_to_name[raw_name] then
              debug("Found in M.memory_address_to_name direct 0x")
              return M.memory_address_to_name[raw_name]
            end

            -- Try without 0x prefix
            local addr_plain = raw_name:gsub("^0x", "")
            debug("Checking plain from 0x: " .. addr_plain)

            if plugin_lookup[addr_plain] then
              debug("Found in plugin_lookup plain from 0x")
              return plugin_lookup[addr_plain]
            end

            if M.memory_address_to_name[addr_plain] then
              debug("Found in M.memory_address_to_name plain from 0x")
              return M.memory_address_to_name[addr_plain]
            end
          end

          -- Try without any prefix at all
          if not raw_name:match("^plugin_") and not raw_name:match("^0x") then
            debug("No prefix address: " .. raw_name)

            -- Try with 0x prefix
            local addr_with_0x = "0x" .. raw_name
            debug("Adding 0x: " .. addr_with_0x)

            if plugin_lookup[addr_with_0x] then
              debug("Found in plugin_lookup with added 0x")
              return plugin_lookup[addr_with_0x]
            end

            if M.memory_address_to_name[addr_with_0x] then
              debug("Found in M.memory_address_to_name with added 0x")
              return M.memory_address_to_name[addr_with_0x]
            end

            -- Try with plugin_ prefix
            local addr_with_plugin = "plugin_" .. raw_name
            debug("Adding plugin_: " .. addr_with_plugin)

            if plugin_lookup[addr_with_plugin] then
              debug("Found in plugin_lookup with added plugin_")
              return plugin_lookup[addr_with_plugin]
            end

            if M.memory_address_to_name[addr_with_plugin] then
              debug("Found in M.memory_address_to_name with added plugin_")
              return M.memory_address_to_name[addr_with_plugin]
            end

            -- Try with both prefixes
            local addr_with_both = "plugin_0x" .. raw_name
            debug("Adding plugin_0x: " .. addr_with_both)

            if plugin_lookup[addr_with_both] then
              debug("Found in plugin_lookup with added plugin_0x")
              return plugin_lookup[addr_with_both]
            end

            if M.memory_address_to_name[addr_with_both] then
              debug("Found in M.memory_address_to_name with added plugin_0x")
              return M.memory_address_to_name[addr_with_both]
            end
          end

          -- Last check - look for any memory_address with partial match at the end
          for addr, name in pairs(M.memory_address_to_name) do
            if type(addr) == "string" and type(raw_name) == "string" then
              -- Check if the raw_name ends with the significant part of addr
              if raw_name:match(addr:gsub("^plugin_", ""):gsub("^0x", "") .. "$") then
                debug("Found by suffix matching: " .. name)
                return name
              end
            end
          end
        end

        -- Still no match? Try all plugins to see if any match this reference's string representation
        local ref_str = tostring(raw_name)
        for name, plugin_match in pairs(plugins) do
          if tostring(plugin_match) == ref_str then
            return name
          end

          -- Check if the raw_name contains the address of this plugin
          local plugin_addr = tostring(plugin_match):gsub("table: ", "")
          local plugin_addr_plain = plugin_addr:gsub("^0x", "")

          if type(raw_name) == "string" then
            if raw_name:match(plugin_addr_plain) then
              -- Found a match by address substring, store it for future use
              M.memory_address_to_name[raw_name] = name
              return name
            end
          end
        end

        -- Check the static mapping table from Lazy
        if _G.lazy_stats and _G.lazy_stats.plugin_times then
          for lazy_plugin, _ in pairs(_G.lazy_stats.plugin_times) do
            if type(lazy_plugin) == "table" then
              local entry_addr = tostring(lazy_plugin):gsub("table: ", "")
              if type(raw_name) == "string" and raw_name:match(entry_addr:gsub("^0x", "")) then
                -- Found a match from lazy_stats, get the name
                local entry_name = lazy_plugin.name or "unknown"
                if lazy_plugin.name then
                  -- Store for future lookups
                  M.memory_address_to_name[raw_name] = entry_name
                  return entry_name
                end
              end
            end
          end
        end

        -- Last resort fallback
        return raw_name or ("Plugin " .. index)
      end

      -- Get the best possible name for this plugin
      local name = force_name(plugin, i)

      -- Add to our mapping for future use
      -- This helps with progressive resolution of names across multiple runs
      if type(plugin.name) == "string" and plugin.name:match("^plugin_0x") then
        local addr = plugin.name:gsub("^plugin_", "")
        if name ~= plugin.name and type(name) == "string" and not name:match("^plugin_0x") then
          -- We resolved this name, store it for future reference
          M.memory_address_to_name[addr] = name
          M.memory_address_to_name[plugin.name] = name
          -- Also store without 0x
          local addr_plain = addr:gsub("^0x", "")
          M.memory_address_to_name[addr_plain] = name
          M.memory_address_to_name["plugin_" .. addr_plain] = name
        end
      end

      -- Format the time value correctly based on its magnitude
      local time_ms = plugin.time
      -- Apply multiplier if needed - sometimes time is already in ms
      if time_ms < 1 then
        time_ms = time_ms * 1000
      end
      table.insert(lines, string.format("%d. %s - %.2f ms", i, name, time_ms))
    end
  end

  -- Count modules by category
  local module_categories = {}
  for module_name, _ in pairs(package.loaded) do
    local category = module_name:match("^[^%.]+")
    if category then
      module_categories[category] = (module_categories[category] or 0) + 1
    end
  end

  -- Add module category counts
  table.insert(lines, "")
  table.insert(lines, "## Module Categories")
  local categories = {}
  for category, count in pairs(module_categories) do
    table.insert(categories, { name = category, count = count })
  end

  table.sort(categories, function(a, b)
    return a.count > b.count
  end)

  for _, category in ipairs(categories) do
    if category.count > 5 then -- Only show categories with more than 5 modules
      table.insert(lines, string.format("- %s: %d modules", category.name, category.count))
    end
  end

  -- Write to file
  local report_path = vim.fn.stdpath("cache") .. "/nvim_plugins_analysis.log"
  local file = io.open(report_path, "w")
  if file then
    file:write(table.concat(lines, "\n"))
    file:close()
    vim.notify("Plugin analysis written to: " .. report_path, vim.log.levels.INFO)
  else
    vim.notify("Failed to write plugin analysis", vim.log.levels.ERROR)
    return
  end

  -- Display in floating window
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  -- Apply markdown highlighting
  vim.bo[buf].filetype = "markdown"

  -- Calculate window size
  local width = math.min(90, vim.o.columns - 4)
  local height = math.min(#lines + 2, vim.o.lines - 4)

  -- Create window
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
    title = "Plugin Analysis",
  })

  -- Set window options
  vim.wo[win].wrap = true
  vim.wo[win].conceallevel = 2
  vim.wo[win].foldenable = false

  -- Add keymaps to close the window
  vim.api.nvim_buf_set_keymap(buf, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
  vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", "<cmd>close<CR>", { noremap = true, silent = true })
  vim.api.nvim_buf_set_keymap(
    buf,
    "n",
    "o",
    "<cmd>e " .. report_path .. "<CR>",
    { noremap = true, silent = true, desc = "Open full report" }
  )

  -- Set buffer options
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = "wipe"

  return buf, win, report_path
end

-- Record an event
function M.record_event(name)
  profile_data.events[name] = os.clock() - profile_data.start_time
end

-- Record a plugin load
function M.record_plugin(name, time)
  -- Convert table to string if needed
  local plugin_name = name
  if type(name) == "table" then
    -- Try to extract the plugin name from the table
    if name.name then
      plugin_name = name.name
    else
      -- Create a placeholder name
      plugin_name = "plugin_" .. tostring(name):gsub("table: ", "")
    end
  end

  -- Ensure we have a string
  plugin_name = tostring(plugin_name)

  -- Add to our plugin data
  table.insert(profile_data.plugins, { name = plugin_name, time = time })
end

-- Profile a function
function M.profile_func(func, name)
  local start = os.clock()
  local result = func()
  local elapsed = os.clock() - start

  profile_data.events[name or "function"] = elapsed

  return result, elapsed
end

-- Create a static mapping of memory addresses to plugin names
-- This will be refreshed each time debug_plugin_names is called
M.memory_address_to_name = {}

-- Debug function to identify plugins and their names
function M.update_plugin_mapping()
  local has_lazy, lazy_config = pcall(require, "lazy.core.config")
  if not has_lazy then
    vim.notify("Lazy.nvim not available", vim.log.levels.ERROR)
    return {}
  end

  -- Make profile module available globally for recording
  _G.profile_module = M

  local plugins = lazy_config.plugins
  local debug_lines = { "# Plugin Names Debug", "" }

  -- Only reset if empty - we want to keep any mappings we've built up
  if not M.memory_address_to_name or vim.tbl_isempty(M.memory_address_to_name) then
    M.memory_address_to_name = {}
  end
  for name, plugin in pairs(plugins) do
    -- Add to our memory address mapping with all possible formats
    local orig_addr = tostring(plugin):gsub("table: ", "")
    local addr_with_0x = "0x" .. orig_addr:gsub("^0x", "")
    local addr_plain = orig_addr:gsub("^0x", "")

    -- Store all variations
    M.memory_address_to_name[orig_addr] = name
    M.memory_address_to_name["plugin_" .. orig_addr] = name
    M.memory_address_to_name[addr_with_0x] = name
    M.memory_address_to_name["plugin_" .. addr_with_0x] = name
    M.memory_address_to_name[addr_plain] = name
    M.memory_address_to_name["plugin_" .. addr_plain] = name
    M.memory_address_to_name["0x" .. addr_plain] = name
    M.memory_address_to_name["plugin_0x" .. addr_plain] = name

    -- Build the debug output
    table.insert(debug_lines, string.format("Plugin: %s", name))
    table.insert(debug_lines, string.format("  - Reference: %s", tostring(plugin)))
    table.insert(debug_lines, string.format("  - Address: %s", tostring(plugin):gsub("table: ", "")))
    table.insert(debug_lines, string.format("  - Loaded: %s", plugin.loaded and "Yes" or "No"))
    table.insert(debug_lines, string.format("  - Time: %s", plugin.time or "N/A"))
    table.insert(debug_lines, "")
  end

  -- Also update the profile data with the correct names
  if profile_data.plugins and #profile_data.plugins > 0 then
    for i, plugin_data in ipairs(profile_data.plugins) do
      if
        plugin_data.name
        and type(plugin_data.name) == "string"
        and (plugin_data.name:match("^plugin_0x") or plugin_data.name:match("^0x"))
      then
        -- Extract the address part
        local addr
        if plugin_data.name:match("^plugin_0x") then
          addr = plugin_data.name:gsub("^plugin_", "")
        else
          addr = plugin_data.name
        end

        -- Look up the name
        if M.memory_address_to_name[addr] then
          profile_data.plugins[i].name = M.memory_address_to_name[addr]
        end
      end
    end
  end

  return {
    mapping = M.memory_address_to_name,
    debug_lines = debug_lines,
  }
end

-- Debug function to display plugin mapping information
function M.debug_plugin_names()
  local result = M.update_plugin_mapping()

  if not result or not result.debug_lines then
    vim.notify("Failed to generate plugin mapping information", vim.log.levels.ERROR)
    return
  end

  -- Display in a buffer
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, result.debug_lines)
  vim.bo[buf].filetype = "markdown"
  vim.api.nvim_command("split")
  vim.api.nvim_win_set_buf(vim.api.nvim_get_current_win(), buf)
end

-- Function to clean up profile logs with confirmation
function M.clean_profile_logs()
  local cache_dir = vim.fn.stdpath("cache")

  -- Get all types of profile logs
  local log_patterns = {
    cache_dir .. "/nvim_profile_*.log", -- Main profile logs
    cache_dir .. "/nvim_plugins_analysis.log", -- Plugin analysis logs
    cache_dir .. "/nvim_startup.log", -- Startup logs
    cache_dir .. "/lazy_plugins.log", -- Lazy plugin logs
  }

  local log_files = {}
  local type_counts = {
    profile = 0,
    plugins = 0,
    startup = 0,
    lazy = 0,
  }

  -- Collect all log files
  for _, pattern in ipairs(log_patterns) do
    local files = vim.fn.glob(pattern, true, true)
    for _, file in ipairs(files) do
      table.insert(log_files, file)

      -- Count by type
      if file:match("nvim_profile_") then
        type_counts.profile = type_counts.profile + 1
      elseif file:match("nvim_plugins_analysis") then
        type_counts.plugins = type_counts.plugins + 1
      elseif file:match("nvim_startup") then
        type_counts.startup = type_counts.startup + 1
      elseif file:match("lazy_plugins") then
        type_counts.lazy = type_counts.lazy + 1
      end
    end
  end

  table.sort(log_files, function(a, b)
    return a > b
  end) -- Sort newest first

  if #log_files == 0 then
    vim.notify("No profile logs found to clean up", vim.log.levels.WARN)
    return
  end

  -- Create a nice display of the log files that will be deleted
  local lines = { "# Profile Logs to Delete", "", "The following profile logs will be deleted:" }

  -- Group files by type
  local grouped_files = {
    ["Profile Logs"] = {},
    ["Plugin Analysis"] = {},
    ["Startup Logs"] = {},
    ["Lazy Plugin Logs"] = {},
  }

  for _, file in ipairs(log_files) do
    local filename = vim.fn.fnamemodify(file, ":t")
    if filename:match("^nvim_profile_") then
      table.insert(grouped_files["Profile Logs"], { file = file, name = filename })
    elseif filename:match("^nvim_plugins_analysis") then
      table.insert(grouped_files["Plugin Analysis"], { file = file, name = filename })
    elseif filename:match("^nvim_startup") then
      table.insert(grouped_files["Startup Logs"], { file = file, name = filename })
    elseif filename:match("^lazy_plugins") then
      table.insert(grouped_files["Lazy Plugin Logs"], { file = file, name = filename })
    end
  end

  -- Display files by group
  for group_name, files in pairs(grouped_files) do
    if #files > 0 then
      table.insert(lines, "")
      table.insert(lines, "## " .. group_name .. " (" .. #files .. ")")

      ---@diagnostic disable-next-line: unused-local
      for i, file_data in ipairs(files) do
        local file = file_data.file
        if file:match("nvim_profile_(%d%d%d%d%d%d%d%d_%d%d%d%d%d%d)%.log$") then
          local timestamp = file:match("nvim_profile_(%d%d%d%d%d%d%d%d_%d%d%d%d%d%d)%.log$")
          local formatted = timestamp:gsub("(%d%d%d%d)(%d%d)(%d%d)_(%d%d)(%d%d)(%d%d)", "%1-%2-%3 %4:%5:%6")
          table.insert(lines, string.format("- %s - %s", formatted, file_data.name))
        else
          table.insert(lines, string.format("- %s", file_data.name))
        end
      end
    end
  end

  table.insert(lines, "")
  table.insert(lines, string.format("## Summary"))
  table.insert(lines, string.format("- Profile logs: %d", type_counts.profile))
  table.insert(lines, string.format("- Plugin analysis logs: %d", type_counts.plugins))
  table.insert(lines, string.format("- Startup logs: %d", type_counts.startup))
  table.insert(lines, string.format("- Lazy plugin logs: %d", type_counts.lazy))
  table.insert(lines, string.format("- Total: %d files", #log_files))
  table.insert(lines, "")
  table.insert(lines, "Press 'y' to confirm deletion or any other key to cancel.")

  -- Create buffer and window
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  -- Apply markdown highlighting
  vim.bo[buf].filetype = "markdown"

  -- Calculate window size
  local width = math.min(80, vim.o.columns - 4)
  local height = math.min(#lines + 2, vim.o.lines - 4)

  -- Create window
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
    title = "Clean Profile Logs",
  })

  -- Set window options
  vim.wo[win].wrap = true
  vim.wo[win].conceallevel = 2
  vim.wo[win].foldenable = false

  -- Function to delete logs when confirmed
  local function delete_logs()
    -- Close the window
    vim.api.nvim_win_close(win, true)

    -- Delete the files
    local deleted_count = 0
    for _, file in ipairs(log_files) do
      local success, err = os.remove(file)
      if success then
        deleted_count = deleted_count + 1
      else
        vim.notify("Failed to delete " .. file .. ": " .. (err or "unknown error"), vim.log.levels.ERROR)
      end
    end

    -- Show a summary of what was deleted by type
    local msg = string.format(
      "Cleaned up %d/%d files:\n- %d profile logs\n- %d plugin analysis logs\n- %d startup logs\n- %d lazy plugin logs",
      deleted_count,
      #log_files,
      type_counts.profile,
      type_counts.plugins,
      type_counts.startup,
      type_counts.lazy
    )
    vim.notify(msg, vim.log.levels.INFO)
  end

  -- Function to cancel deletion
  local function cancel_deletion()
    vim.api.nvim_win_close(win, true)
    vim.notify("Log cleanup cancelled", vim.log.levels.INFO)
  end

  -- Add keymaps for confirmation
  vim.api.nvim_buf_set_keymap(buf, "n", "y", "", {
    noremap = true,
    silent = true,
    callback = delete_logs,
  })

  vim.api.nvim_buf_set_keymap(buf, "n", "Y", "", {
    noremap = true,
    silent = true,
    callback = delete_logs,
  })

  -- All other keys cancel
  local function add_cancel_keymap(key)
    vim.api.nvim_buf_set_keymap(buf, "n", key, "", {
      noremap = true,
      silent = true,
      callback = cancel_deletion,
    })
  end

  add_cancel_keymap("n")
  add_cancel_keymap("q")
  add_cancel_keymap("<Esc>")
  add_cancel_keymap("<CR>")

  -- Set buffer options
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = "wipe"

  return buf, win
end

-- Create user commands and setup profiling
function M.setup()
  -- Make profile module available globally for recording
  _G.profile_module = M

  -- Only register commands once
  if not commands_registered then
    -- Command to generate a detailed profile log
    vim.api.nvim_create_user_command("Profile", function()
      M.write_profile_log()
    end, { desc = "Generate a detailed profile report" })

    -- Command to show a quick summary in a floating window
    vim.api.nvim_create_user_command("ProfileSummary", function()
      M.show_profile_summary()
    end, { desc = "Show profile summary in a float window" })

    -- Command to list profile logs
    vim.api.nvim_create_user_command("ProfileLogs", function()
      M.list_profile_logs()
    end, { desc = "List profile logs" })

    -- Command to clean up profile logs
    vim.api.nvim_create_user_command("ProfileClean", function()
      M.clean_profile_logs()
    end, { desc = "Clean up profile logs" })

    -- Command to analyze plugins
    vim.api.nvim_create_user_command("ProfilePlugins", function()
      M.analyze_plugins()
    end, { desc = "Analyze plugin performance" })

    -- Debug command
    vim.api.nvim_create_user_command("ProfileDebug", function()
      M.debug_plugin_names()
    end, { desc = "Debug plugin names" })

    commands_registered = true

    -- Log successful registration
    vim.notify("Profile commands registered", vim.log.levels.INFO)
  end

  -- Auto-record some common events if profiling is enabled
  if os.getenv("NVIM_PROFILE") then
    vim.api.nvim_create_autocmd("UIEnter", {
      callback = function()
        M.record_event("ui_enter")
      end,
      once = true,
    })

    vim.api.nvim_create_autocmd("BufRead", {
      callback = function()
        M.record_event("first_buf_read")
      end,
      once = true,
    })

    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        M.record_event("vim_enter")
      end,
      once = true,
    })
  end

  return M
end

return M
