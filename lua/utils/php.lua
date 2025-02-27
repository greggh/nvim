local M = {}

-- Detect if the current project is a Laravel project
function M.find_laravel_root()
  -- Start with current working directory
  local current_dir = vim.fn.getcwd()
  
  -- Check if current directory is already the Laravel root
  if vim.fn.filereadable(current_dir .. "/artisan") == 1 then
    return current_dir
  end
  
  -- If current buffer is a file, use its directory as starting point
  local current_buf = vim.api.nvim_get_current_buf()
  local file_path = vim.api.nvim_buf_get_name(current_buf)
  if file_path and file_path ~= "" then
    local file_dir = vim.fn.fnamemodify(file_path, ":h")
    if file_dir and file_dir ~= "" then
      current_dir = file_dir
    end
  end
  
  -- Recursively check parent directories for artisan file
  local max_depth = 10 -- Avoid infinite loop
  local depth = 0
  local dir = current_dir
  
  while depth < max_depth do
    if vim.fn.filereadable(dir .. "/artisan") == 1 then
      return dir -- Found Laravel root
    end
    
    -- Go up one directory
    local parent_dir = vim.fn.fnamemodify(dir, ":h")
    if parent_dir == dir then
      break -- Reached root directory, stop searching
    end
    dir = parent_dir
    depth = depth + 1
  end
  
  return nil -- Not a Laravel project
end

-- Detect if the current project is a Laravel project
function M.is_laravel_project()
  return M.find_laravel_root() ~= nil
end

-- Read user preferences from the .nvim-helper file
function M.read_user_preference(laravel_root)
  if not laravel_root then
    return nil
  end
  
  local prefs_file = laravel_root .. "/.nvim-helper"
  if vim.fn.filereadable(prefs_file) ~= 1 then
    return nil
  end
  
  local content = vim.fn.readfile(prefs_file)
  local prefs = {}
  
  for _, line in ipairs(content) do
    local key, value = line:match("([^=]+)=(.+)")
    if key and value then
      prefs[key:gsub("^%s*(.-)%s*$", "%1")] = value:gsub("^%s*(.-)%s*$", "%1")
    end
  end
  
  return prefs
end

-- Save user preferences to the .nvim-helper file
function M.save_user_preference(laravel_root, key, value)
  if not laravel_root then
    return false, "No Laravel root directory specified"
  end
  
  -- Check if directory exists and is writable
  if vim.fn.isdirectory(laravel_root) ~= 1 then
    return false, "Laravel root directory does not exist: " .. laravel_root
  end
  
  if vim.fn.filewritable(laravel_root) ~= 2 then
    return false, "Laravel root directory is not writable: " .. laravel_root
  end
  
  local prefs_file = laravel_root .. "/.nvim-helper"
  local prefs = M.read_user_preference(laravel_root) or {}
  
  -- Update or add the preference
  prefs[key] = value
  
  -- Header with explanation of the file format and available settings
  local header = {
    "# Neovim Helper Configuration for Laravel Projects",
    "# This file stores your preferences for Neovim's Laravel integration.",
    "# ",
    "# Available settings:",
    "# - ide_helper_install=declined   (Skip prompts to install Laravel IDE Helper)",
    "# - ide_helper_generate=declined  (Skip prompts to generate helper files)",
    "# - use_standard_php=always       (Always use standard PHP instead of Sail)",
    "# ",
    "# To change a setting, edit the value or remove the line to reset to default behavior.",
    "# Example: Change 'declined' to 'prompt' to start getting prompts again.",
    "# "
  }
  
  -- Convert preferences back to file format
  local lines = {}
  
  -- Only add header if creating a new file or the file doesn't have our header
  if vim.fn.filereadable(prefs_file) ~= 1 or 
     not vim.fn.readfile(prefs_file, "", 1)[1] or
     not vim.fn.readfile(prefs_file, "", 1)[1]:match("^# Neovim Helper Configuration") then
    for _, line in ipairs(header) do
      table.insert(lines, line)
    end
  end
  
  -- Add actual preference key-value pairs
  for k, v in pairs(prefs) do
    table.insert(lines, k .. "=" .. v)
  end
  
  -- Try to write to file and capture result
  local result = vim.fn.writefile(lines, prefs_file)
  if result == 0 then
    return true
  else
    local error_msg
    if vim.fn.filewritable(prefs_file) == 1 then
      error_msg = "File exists but is not writable: " .. prefs_file
    elseif vim.fn.filewritable(laravel_root) ~= 2 then
      error_msg = "Directory is not writable: " .. laravel_root
    else
      error_msg = "Failed to write to file (code: " .. result .. ")"
    end
    return false, error_msg
  end
end

-- Check if the IDE Helper has been explicitly declined
function M.is_ide_helper_declined(laravel_root)
  local prefs = M.read_user_preference(laravel_root)
  if not prefs then
    return false
  end
  
  return prefs["ide_helper_install"] == "declined"
end

-- Handle "remember this choice" prompt and save user preference
function M.handle_remember_choice(laravel_root, pref_key, pref_value, prompt_text, success_message)
  local remember_choice = vim.fn.confirm(
    prompt_text or "Would you like to remember this choice for this Laravel project?",
    "&Yes\n&No",
    2 -- Default to No
  )
  
  if remember_choice == 1 then
    -- Save the preference to the .nvim-helper file
    local success, error_msg = M.save_user_preference(laravel_root, pref_key, pref_value)
    if success then
      vim.notify(
        success_message or "Preference saved in .nvim-helper. To enable prompts again, change value to 'prompt' or delete the line.",
        vim.log.levels.INFO,
        { title = "Laravel IDE Helper" }
      )
    else
      vim.notify(
        "Failed to save preference: " .. (error_msg or "Unknown error"),
        vim.log.levels.WARN,
        { title = "Laravel IDE Helper" }
      )
    end
    
    return true
  end
  
  return false
end

-- Check if the Laravel project is in production environment
function M.is_production_environment()
  local laravel_root = M.find_laravel_root()
  if not laravel_root then
    return false -- Not a Laravel project
  end
  
  -- First check for .env file which should contain APP_ENV
  local env_file = laravel_root .. "/.env"
  if vim.fn.filereadable(env_file) == 1 then
    local env_content = vim.fn.readfile(env_file)
    for _, line in ipairs(env_content) do
      -- Look for APP_ENV=production (ignoring whitespace and case)
      if line:lower():match("^%s*app_env%s*=%s*production%s*$") then
        return true
      end
    end
  end
  
  -- If .env doesn't indicate production, check config/app.php as a fallback
  local app_config = laravel_root .. "/config/app.php"
  if vim.fn.filereadable(app_config) == 1 then
    local config_content = vim.fn.readfile(app_config)
    local env_line_found = false
    for _, line in ipairs(config_content) do
      -- Look for 'env' => 'production' (case insensitive)
      local line_lower = line:lower()
      if line_lower:match("'env'%s*=>%s*'production'") or 
         line_lower:match('"env"%s*=>%s*"production"') then
        return true
      end
    end
  end
  
  return false -- Default to assuming it's not production
end

-- Detect if Laravel IDE Helper is installed
function M.has_ide_helper()
  local laravel_root = M.find_laravel_root()
  if not laravel_root then
    return false
  end
  
  -- Check for the package in composer.json
  if vim.fn.filereadable(laravel_root .. "/composer.json") == 1 then
    local composer_json = vim.fn.readfile(laravel_root .. "/composer.json")
    local composer_content = table.concat(composer_json, "\n")
    if composer_content:find("barryvdh/laravel%-ide%-helper") then
      return true
    end
  end
  return false
end

-- Check if Sail is running by checking Docker containers
function M.is_sail_running()
  local laravel_root = M.find_laravel_root()
  if not laravel_root or not M.has_sail() then
    return false
  end
  
  -- A more reliable way to check if Sail is running by checking Docker containers
  local cmd = "docker ps --format '{{.Names}}' | grep -q 'laravel\\.test\\|sail'"
  local exit_code = os.execute(cmd)
  
  -- os.execute returns true (and exit code 0) if the command succeeds
  return exit_code == 0 or exit_code == true
end

-- Common Sail command functions to prevent duplication
function M.get_sail_up_cmd()
  return "./vendor/bin/sail up --remove-orphans -d"
end

function M.get_sail_down_cmd()
  return "./vendor/bin/sail down"
end

function M.get_sail_install_cmd(options)
  return "php artisan sail:install" .. (options and (" --with=" .. options) or "")
end

function M.get_full_command(cmd, cwd)
  return "cd " .. vim.fn.shellescape(cwd) .. " && " .. cmd
end

-- Run a command asynchronously with buffer output support
function M.run_job(cmd, cwd, buffer, on_success, on_failure, options)
  options = options or {}
  local log_to_buffer = M.create_buffer_logger(buffer)
  local timeout = options.timeout or 30000 -- Default 30 second timeout
  local completion_message = options.completion_message or "Command completed successfully"
  local success_prefix = options.success_prefix or ""
  local error_prefix = options.error_prefix or ""
  
  -- Add command information to the buffer, but skip for certain commands
  if cmd:match("echo.*Waiting for database") then
    -- For wait commands, only show the message without command details
    log_to_buffer({
      "",
      "Waiting for database to initialize...",
      "-------------------------------------------",
      ""
    })
  else
    -- For other commands, show the full details
    log_to_buffer({
      "",
      "Running command: " .. cmd,
      "Working directory: " .. cwd,
      "-------------------------------------------",
      "",
    })
  end
  
  -- Handle special error detection for Sail/Docker and Laravel
  local detect_sail_errors = options.detect_sail_errors or false
  local detect_laravel_errors = options.detect_laravel_errors or false
  local sail_error_detected = false
  local docker_error_detected = false
  local db_connection_error = false
  local model_not_found_error = false
  
  -- Keep track of command success/failure
  local job_success = false
  local job_complete = false
  
  -- Start the command
  local job_id = vim.fn.jobstart(cmd, {
    cwd = cwd,
    stdout_buffered = false,
    stderr_buffered = false,
    on_stdout = function(_, data)
      if data and #data > 0 then
        -- Try to detect sail-specific errors in the output if requested
        if detect_sail_errors then
          for _, line in ipairs(data) do
            if type(line) == "string" then
              if line:match("Docker.* not running") or line:match("Cannot connect to the Docker daemon") then
                docker_error_detected = true
              elseif line:match("Error response from daemon") or line:match("Sail is not running") then
                sail_error_detected = true
              end
            end
          end
        end
        
        -- Detect Laravel-specific errors if requested
        if detect_laravel_errors then
          for _, line in ipairs(data) do
            if type(line) == "string" then
              if line:match("could not find driver") or 
                 line:match("database.+connection") or
                 line:match("SQLSTATE") then
                db_connection_error = true
              elseif line:match("Model.+not found") or 
                     line:match("Class.+not found") or
                     line:match("table.+does not exist") then
                model_not_found_error = true
              end
            end
          end
        end
        
        -- Log all stdout to buffer
        log_to_buffer(data)
      end
    end,
    on_stderr = function(_, data)
      if data and #data > 0 then
        -- Try to detect sail-specific errors in stderr if requested
        if detect_sail_errors then
          for _, line in ipairs(data) do
            if type(line) == "string" then
              if line:match("Docker.* not running") or line:match("Cannot connect to the Docker daemon") then
                docker_error_detected = true
              elseif line:match("Error response from daemon") or line:match("Sail is not running") then
                sail_error_detected = true
              end
            end
          end
        end
        
        -- Detect Laravel-specific errors if requested (stderr often has the more detailed errors)
        if detect_laravel_errors then
          for _, line in ipairs(data) do
            if type(line) == "string" then
              if line:match("could not find driver") or 
                 line:match("database.+connection") or
                 line:match("SQLSTATE") then
                db_connection_error = true
              elseif line:match("Model.+not found") or 
                     line:match("Class.+not found") or
                     line:match("table.+does not exist") or
                     line:match("ReflectionException") then
                model_not_found_error = true
              end
            end
          end
        end
        
        -- Log stderr to buffer
        log_to_buffer(data)
      end
    end,
    on_exit = function(_, code)
      if code == 0 then
        job_success = true
        log_to_buffer({
          "",
          "-------------------------------------------",
          success_prefix .. completion_message,
          "-------------------------------------------",
          ""
        })
        
        job_complete = true
        
        -- Call success callback after a brief delay
        if on_success then
          vim.defer_fn(function()
            on_success({
              sail_error_detected = sail_error_detected,
              docker_error_detected = docker_error_detected
            })
          end, 100)
        end
      else
        job_success = false
        
        -- Prepare error message based on detected errors
        local error_msg = {
          "",
          "-------------------------------------------",
          error_prefix .. "Command failed with exit code: " .. code,
          "",
        }
        
        -- Add specific error information if available
        if detect_sail_errors then
          if docker_error_detected then
            table.insert(error_msg, "Docker does not appear to be running or accessible.")
            table.insert(error_msg, "Possible next steps:")
            table.insert(error_msg, "1. Start Docker Desktop or the Docker daemon")
            table.insert(error_msg, "2. Make sure the current user has permissions to access Docker")
          elseif sail_error_detected then
            table.insert(error_msg, "Sail environment appears to have issues.")
            table.insert(error_msg, "Possible next steps:")
            table.insert(error_msg, "1. Try starting Sail manually: " .. M.get_sail_up_cmd())
            table.insert(error_msg, "2. Check docker-compose.yml for configuration errors")
            table.insert(error_msg, "3. Ensure no conflicting services are using the same ports")
          end
        end
        
        table.insert(error_msg, "-------------------------------------------")
        table.insert(error_msg, "")
        
        log_to_buffer(error_msg)
        
        job_complete = true
        
        -- Call failure callback after a brief delay
        if on_failure then
          vim.defer_fn(function()
            on_failure({
              exit_code = code,
              sail_error_detected = sail_error_detected,
              docker_error_detected = docker_error_detected
            })
          end, 100)
        end
      end
    end
  })
  
  if job_id <= 0 then
    log_to_buffer({
      "",
      "-------------------------------------------",
      "Failed to start command",
      "Command: " .. cmd,
      "-------------------------------------------",
      ""
    })
    
    job_complete = true
    job_success = false
    
    -- Call failure callback after a brief delay
    if on_failure then
      vim.defer_fn(function()
        on_failure({
          exit_code = -1,
          job_start_failed = true
        })
      end, 100)
    end
    
    return false
  end
  
  -- For synchronous execution, wait for completion if requested
  if options.wait then
    -- Wait for job to complete with timeout
    local wait_result = vim.wait(timeout, function() return job_complete end, 100)
    
    if not wait_result then
      log_to_buffer({
        "",
        "-------------------------------------------",
        "Command timed out after " .. (timeout / 1000) .. " seconds",
        "The operation may still be running in the background",
        "-------------------------------------------",
        ""
      })
      
      if on_failure then
        on_failure({
          exit_code = -2,
          timed_out = true
        })
      end
      
      return false
    end
    
    return job_success
  end
  
  return true -- Job started successfully
end

-- Create a docker-compose.yml for Laravel Sail using artisan sail:install
function M.create_default_docker_compose(laravel_root)
  local buffer = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(buffer, "Laravel Sail Setup")
  vim.api.nvim_buf_set_lines(buffer, 0, -1, false, {
    "Setting up Laravel Sail using artisan sail:install...",
    "Working directory: " .. laravel_root,
    "-------------------------------------------",
    ""
  })
  
  -- Show buffer to user
  vim.cmd("sbuffer " .. buffer)
  vim.cmd("setlocal buftype=nofile bufhidden=wipe noswapfile ft=log")
  
  -- Use the common buffer logger
  local log_to_buffer = M.create_buffer_logger(buffer)
  
  -- Use php artisan sail:install to create docker-compose.yml
  -- First check if this artisan command is available (it was added in Laravel 8.12)
  log_to_buffer("Checking for sail:install command in Laravel...")
  
  -- Make sure we have proper debug information
  log_to_buffer("Laravel root: " .. laravel_root)
  log_to_buffer("Testing PHP availability...")
  local php_version = vim.fn.system("php --version 2>/dev/null")
  local php_available = php_version ~= "" and not php_version:match("command not found")
  log_to_buffer("PHP " .. (php_available and "is available" or "is NOT available"))
  
  -- Verify artisan command exists
  log_to_buffer("Checking if artisan file exists...")
  local artisan_exists = vim.fn.filereadable(laravel_root .. "/artisan") == 1
  log_to_buffer("Artisan file " .. (artisan_exists and "exists" or "does NOT exist"))
  
  -- Try artisan command
  log_to_buffer("Testing artisan command...")
  local check_artisan_cmd = "cd " .. vim.fn.shellescape(laravel_root) .. " && php artisan --version 2>&1"
  local artisan_output = vim.fn.system(check_artisan_cmd)
  local artisan_available = artisan_output:match("Laravel Framework")
  log_to_buffer("Artisan output: " .. artisan_output:gsub("\n", " | "))
  log_to_buffer("Artisan command " .. (artisan_available and "works correctly" or "has issues"))
  
  -- Check for sail:install command
  log_to_buffer("Checking for sail:install command...")
  local check_command = "cd " .. vim.fn.shellescape(laravel_root) .. " && php artisan list 2>/dev/null | grep -i 'sail:install'"
  local sail_install_output = vim.fn.system(check_command)
  local has_sail_install = sail_install_output:match("sail:install") or sail_install_output:match("sail:install")
  
  -- Handle sail:install command output logging
  if sail_install_output ~= "" and type(sail_install_output) == "string" then
    log_to_buffer("Found sail:install in command output: " .. (has_sail_install and "Yes" or "No"))
    log_to_buffer("sail:install output: " .. sail_install_output:gsub("\n", " | "))
  else
    log_to_buffer("No output from sail:install check")
  end
  
  log_to_buffer("Command exit code: " .. vim.v.shell_error)
  log_to_buffer("---------- Sail detection summary ----------")
  log_to_buffer("Sail detection results:")
  log_to_buffer("- PHP available: " .. (php_available and "Yes" or "No"))
  log_to_buffer("- Artisan file exists: " .. (artisan_exists and "Yes" or "No"))
  log_to_buffer("- Artisan command works: " .. (artisan_available and "Yes" or "No"))
  log_to_buffer("- sail:install detected: " .. (has_sail_install and "Yes" or "No"))
  log_to_buffer("---------- End summary ----------")
  
  local success = false
  
  if has_sail_install then
    -- Laravel 8.12+ with sail:install command - ask user for database preference
    log_to_buffer("Found sail:install command. Asking user for database preference...")
    
    -- Schedule on the main thread to show a UI prompt
    local db_choice
    vim.schedule(function()
      db_choice = vim.fn.confirm(
        "Which database would you like to use with Laravel Sail?",
        "&MySQL\n&PostgreSQL\n&MariaDB\n&Cancel",
        1 -- Default to MySQL
      )
    end)
    
    -- Wait for user to make a choice
    vim.wait(10000, function() return db_choice ~= nil end, 100)
    
    -- Process the user's database choice
    local db_type
    if db_choice == 1 then -- MySQL
      db_type = "mysql"
    elseif db_choice == 2 then -- PostgreSQL
      db_type = "pgsql"
    elseif db_choice == 3 then -- MariaDB
      db_type = "mariadb"
    else -- Cancel
      log_to_buffer("User cancelled database selection.")
      vim.notify("Laravel Sail installation cancelled by user", 
                vim.log.levels.INFO, { title = "Laravel IDE Helper" })
      success = nil
      return nil
    end
    
    -- Now ask about additional services (Mailpit, Redis, Meilisearch)
    log_to_buffer("Asking user about additional services...")
    
    -- Create a list to store selected services
    local services = { db_type }
    
    -- Function to confirm if user wants to include a service
    local function ask_for_service(service_name, service_id)
      local service_choice
      vim.schedule(function()
        service_choice = vim.fn.confirm(
          "Would you like to include " .. service_name .. " in your Sail setup?",
          "&Yes\n&No",
          2 -- Default to No
        )
      end)
      
      -- Wait for user to make a choice
      vim.wait(10000, function() return service_choice ~= nil end, 100)
      
      if service_choice == 1 then -- Yes
        table.insert(services, service_id)
        log_to_buffer("Adding " .. service_name .. " to Sail configuration.")
        return true
      end
      
      return false
    end
    
    -- Ask about each service
    -- Build a clear message about selected services as we go
    local selected_services_msg = "Selected database: " .. db_type
    
    -- Ask about Redis
    if ask_for_service("Redis", "redis") then
      selected_services_msg = selected_services_msg .. ", redis"
    end
    
    -- Ask about Mailpit
    if ask_for_service("Mailpit (mail testing)", "mailpit") then
      selected_services_msg = selected_services_msg .. ", mailpit"
    end
    
    -- Ask about Meilisearch
    if ask_for_service("Meilisearch (search engine)", "meilisearch") then
      selected_services_msg = selected_services_msg .. ", meilisearch"
    end
    
    -- Construct the final with argument
    local with_arg = table.concat(services, ",")
    
    log_to_buffer({
      "",
      "-------------------------------------------",
      "Summary of selected services:",
      selected_services_msg,
      "Installing Sail with these options: " .. with_arg,
      "-------------------------------------------",
      ""
    })
    
    -- Create a completion flag for synchronization
    local install_complete = false
    local install_success = false
    
    log_to_buffer({
      "",
      "Running sail:install command synchronously - please wait...",
      "Command: php artisan sail:install --with=" .. with_arg
    })
    
    -- Create a buffer-only way to display output from the command
    local function append_install_output(data, is_stderr)
      if data and #data > 0 then
        -- Process string or table of strings
        local lines = type(data) == "table" and data or {data}
        for _, line in ipairs(lines) do
          if line and line ~= "" then
            -- Check if this is an actual error message
            local is_real_error = is_stderr and 
                                  line:match("^ERROR:") or 
                                  line:match("^Fatal:") or 
                                  line:match("exception") or
                                  line:match("failed") or
                                  line:match("Error:")
            
            -- Docker output to stderr often isn't an error, just normal status messages
            if is_real_error then
              log_to_buffer("ERROR: " .. line)
            else
              log_to_buffer(line)
            end
          end
        end
      end
    end
    
    -- Run the sail:install command asynchronously but with proper coordination
    local install_cmd = M.get_sail_install_cmd(with_arg)
    local job_id = vim.fn.jobstart(install_cmd, {
      cwd = laravel_root,
      stdout_buffered = false,
      stderr_buffered = false,
      on_stdout = function(_, data)
        append_install_output(data, false) -- stdout, not stderr
      end,
      on_stderr = function(_, data)
        append_install_output(data, true)  -- stderr, might not be an actual error 
      end,
      on_exit = function(_, code)
        if code == 0 then
          log_to_buffer({
            "",
            "-------------------------------------------",
            "Laravel Sail installed successfully!",
            "Docker compose file has been created at: " .. laravel_root .. "/docker-compose.yml",
            "-------------------------------------------",
            ""
          })
          install_success = true
        else
          log_to_buffer({
            "",
            "-------------------------------------------",
            "Failed to install Laravel Sail with exit code: " .. code,
            "-------------------------------------------",
            ""
          })
          install_success = false
        end
        install_complete = true -- Signal command completion
      end
    })
    
    if job_id <= 0 then
      log_to_buffer({
        "Failed to execute artisan sail:install command.",
        "This could mean PHP is not available or the artisan command is broken."
      })
      install_complete = true
      install_success = false
    end
    
    -- Wait for the sail:install command to complete
    log_to_buffer("Waiting for sail:install to complete...")
    local wait_result = vim.wait(30000, function() return install_complete end, 100) -- 30 second timeout
    
    if not wait_result then
      log_to_buffer({
        "",
        "-------------------------------------------",
        "ERROR: sail:install command timed out after 30 seconds!",
        "-------------------------------------------",
        ""
      })
      install_success = false
    end
    
    -- Now handle the result of the sail:install command
    if install_success then
      -- Sail was installed successfully
      log_to_buffer("Docker compose file created successfully.")
      
      -- Verify that the docker-compose.yml file exists
      if vim.fn.filereadable(laravel_root .. "/docker-compose.yml") == 1 then
        log_to_buffer("Verified docker-compose.yml file exists.")
        
        -- Now try to start Sail with the new docker-compose.yml
        log_to_buffer({
          "",
          "-------------------------------------------",
          "Starting Laravel Sail with the new configuration...",
          "-------------------------------------------",
          ""
        })
        
        -- Reset the completion flags for Sail startup
        install_complete = false
        install_success = false
        
        -- Start Sail with --remove-orphans to clean up old containers
        local sail_cmd = M.get_full_command(M.get_sail_up_cmd(), laravel_root)
        local sail_job_id = vim.fn.jobstart(sail_cmd, {
          stdout_buffered = false,
          stderr_buffered = false,
          on_stdout = function(_, data)
            append_install_output(data, false) -- stdout, not stderr
          end,
          on_stderr = function(_, data)
            append_install_output(data, true)  -- stderr, might not be an actual error
          end,
          on_exit = function(_, code)
            if code == 0 then
              log_to_buffer({
                "",
                "-------------------------------------------",
                "Laravel Sail started successfully!",
                "Now proceeding with IDE Helper installation using Sail.",
                "-------------------------------------------",
                ""
              })
              install_success = true
            else
              log_to_buffer({
                "",
                "-------------------------------------------",
                "Failed to start Laravel Sail with exit code: " .. code,
                "-------------------------------------------",
                ""
              })
              install_success = false
            end
            install_complete = true -- Signal command completion
          end
        })
        
        if sail_job_id <= 0 then
          log_to_buffer({
            "Failed to execute sail up command.",
            "This could mean the sail script is not executable."
          })
          install_complete = true
          install_success = false
        end
        
        -- Wait for the sail startup command to complete
        log_to_buffer("Waiting for Sail to start...")
        local sail_wait_result = vim.wait(45000, function() return install_complete end, 100) -- 45 second timeout for sail startup
        
        if not sail_wait_result then
          log_to_buffer({
            "",
            "-------------------------------------------",
            "ERROR: Sail startup timed out after 45 seconds!",
            "-------------------------------------------",
            ""
          })
          install_success = false
        end
        
        -- Set final success based on Sail startup
        success = install_success
        
        -- If Sail started successfully, give it a moment to fully initialize
        if success then
          log_to_buffer("Waiting 5 seconds for Docker containers to fully initialize...")
          vim.cmd("sleep 5000m") -- Sleep for 5 seconds (5000 milliseconds)
        else
          -- Ask how to proceed if Sail startup failed
          log_to_buffer("Sail startup was not successful.")
          
          local choice
          vim.schedule(function()
            choice = vim.fn.confirm(
              "Failed to start Laravel Sail. How would you like to proceed?",
              "&Continue with standard PHP\nC&ancel installation",
              1 -- Default to continuing with PHP
            )
          end)
          
          -- Wait for user choice
          vim.wait(10000, function() return choice ~= nil end, 100)
          
          if choice == 1 then -- Continue with standard PHP
            log_to_buffer({
              "",
              "User chose to continue with standard PHP.",
              ""
            })
            success = false -- This will trigger fallback to standard PHP
          else -- Cancel
            log_to_buffer({
              "",
              "User cancelled the IDE Helper installation.",
              ""
            })
            vim.notify("Laravel IDE Helper installation cancelled by user", 
                      vim.log.levels.INFO, { title = "Laravel IDE Helper" })
            success = nil -- Special value to indicate cancellation
          end
        end
      else
        log_to_buffer("WARNING: docker-compose.yml file not found despite successful installation!")
        log_to_buffer("Continuing with standard PHP since we can't start Sail without docker-compose.yml.")
        success = false
      end
    else
      -- Sail installation failed - ask how to proceed
      log_to_buffer("Sail installation was not successful.")
      
      local choice
      vim.schedule(function()
        choice = vim.fn.confirm(
          "Laravel Sail installation failed. How would you like to proceed?",
          "&Continue with standard PHP\nC&ancel installation",
          1 -- Default to continuing with PHP
        )
      end)
      
      -- Wait for user choice
      vim.wait(10000, function() return choice ~= nil end, 100)
      
      if choice == 1 then -- Continue with standard PHP
        log_to_buffer({
          "",
          "User chose to continue with standard PHP.",
          ""
        })
        success = false -- This will trigger fallback to standard PHP
      else -- Cancel
        log_to_buffer({
          "",
          "User cancelled the IDE Helper installation.",
          ""
        })
        vim.notify("Laravel IDE Helper installation cancelled by user", 
                  vim.log.levels.INFO, { title = "Laravel IDE Helper" })
        success = nil -- Special value to indicate cancellation
      end
    end
  else
    -- Command not found
    log_to_buffer({
      "The 'sail:install' command was not found in your Laravel project.",
      "Debug information:",
      "- Working directory: " .. laravel_root,
      "- Artisan command available: " .. (artisan_available and "Yes" or "No"),
      "- Sail executable exists: " .. (vim.fn.filereadable(laravel_root .. "/vendor/bin/sail") == 1 and "Yes" or "No"),
      "",
      "Possible causes:",
      "1. You're using an older Laravel version (< 8.12) that doesn't have the sail:install command",
      "2. Laravel Sail is not properly installed in this project",
      "3. The php command might not be available in your PATH",
      "4. The artisan command might be customized or broken in this project",
      "",
      "We cannot use Sail for IDE Helper installation without this command."
    })
    
    -- Ask user how to proceed
    vim.schedule(function()
      local choice = vim.fn.confirm(
        "Laravel Sail cannot be set up automatically (command not available). How would you like to proceed?",
        "&Continue with standard PHP\nC&ancel installation",
        1 -- Default to continuing with PHP
      )
      
      if choice == 1 then -- Continue with standard PHP
        log_to_buffer({
          "",
          "User chose to continue with standard PHP.",
          ""
        })
        success = false -- This will trigger fallback to standard PHP
      else -- Cancel
        log_to_buffer({
          "",
          "User cancelled the IDE Helper installation.",
          ""
        })
        vim.notify("Laravel IDE Helper installation cancelled by user", 
                  vim.log.levels.INFO, { title = "Laravel IDE Helper" })
        success = nil -- Special value to indicate cancellation
      end
    end)
  end
  
  -- Wait for the job to complete (this is synchronous)
  -- Also handle timeout by putting a maximum wait time
  local wait_result = vim.wait(10000, function() return success ~= nil end, 100)
  
  if success == nil then
    -- Installation was cancelled by user
    return nil -- Return nil to indicate cancellation
  elseif success then
    vim.notify("Successfully set up Laravel Sail and created docker-compose.yml", 
              vim.log.levels.INFO, { title = "Laravel IDE Helper" })
    return true
  else
    -- Failed but user chose to continue with standard PHP
    vim.notify("Continuing with standard PHP install for Laravel IDE Helper", 
              vim.log.levels.INFO, { title = "Laravel IDE Helper" })
    return false
  end
end

-- Install Laravel IDE Helper
function M.install_ide_helper()
  local laravel_root = M.find_laravel_root()
  if not laravel_root then
    vim.notify("Not a Laravel project", vim.log.levels.WARN)
    return false
  end
  
  -- Check if this is a production environment and warn the user
  if M.is_production_environment() then
    vim.notify(
      "⚠️ WARNING: This appears to be a production Laravel environment. ⚠️\n" ..
      "Installing IDE Helper in production is not recommended.\n" ..
      "Please check your .env file or config/app.php.",
      vim.log.levels.ERROR,
      { 
        title = "Laravel IDE Helper - PRODUCTION ENVIRONMENT DETECTED",
        timeout = 10000  -- 10 seconds (twice the default 5000ms)
      }
    )
    
    -- Ask for confirmation before proceeding
    local choice = vim.fn.confirm(
      "This appears to be a production Laravel environment. IDE Helper should NOT be used in production.\n" ..
      "Are you absolutely sure you want to continue?",
      "&Cancel\n&I understand the risks, proceed anyway",
      1 -- Default to Cancel
    )
    
    if choice ~= 2 then -- Not confirmed
      vim.notify("Laravel IDE Helper installation cancelled", vim.log.levels.INFO)
      return false
    end
    
    -- If they confirm, show one more strong warning
    vim.notify(
      "⚠️ Proceeding with IDE Helper in PRODUCTION environment at user's request! ⚠️\n" ..
      "This is NOT recommended and could potentially modify production data.",
      vim.log.levels.WARN,
      { 
        title = "Laravel IDE Helper - PROCEEDING IN PRODUCTION", 
        timeout = 10000  -- 10 seconds (twice the default 5000ms)
      }
    )
  end
  
  -- Check user preference for standard PHP first
  if M.prefer_standard_php(laravel_root) then
    vim.notify("Using standard PHP/composer (as per saved preference).", 
              vim.log.levels.INFO, { title = "Laravel IDE Helper" })
    return M.install_ide_helper_with_command(laravel_root, false, nil)
  end
  
  local use_sail = M.has_sail()
  local is_docker_available = M.is_docker_available()
  
  -- If Sail is available but Docker isn't, we should fall back to standard composer
  if use_sail and not is_docker_available then
    vim.notify("Laravel Sail is available, but Docker is not installed or not running. Using standard composer.", 
              vim.log.levels.WARN, { title = "Laravel IDE Helper" })
    use_sail = false
  end
  
  local sail_running = use_sail and M.is_sail_running()
  local has_docker_compose = use_sail and M.has_docker_compose()
  
  -- Special case: Sail is installed but docker-compose.yml is missing
  if use_sail and not has_docker_compose then
    local compose_choice = vim.fn.confirm(
      "Laravel Sail is installed but no docker-compose.yml file was found. What would you like to do?",
      "&Create default docker-compose.yml\n&Use standard composer\nCa&ncel",
      1 -- Default to creating docker-compose.yml
    )
    
    if compose_choice == 1 then -- Create docker-compose.yml
      if M.create_default_docker_compose(laravel_root) then
        has_docker_compose = true
        -- Continue with the usual flow, now with docker-compose.yml
      else
        -- Failed to create docker-compose.yml, fall back to standard composer
        use_sail = false
      end
    elseif compose_choice == 2 then -- Use standard composer
      use_sail = false
    else -- Cancel (choice == 3 or any other value)
      vim.notify("Laravel IDE Helper installation cancelled by user", 
                vim.log.levels.INFO, { title = "Laravel IDE Helper" })
      return false -- This should exit the function and prevent any installation
    end
  end
  
  -- Now handle the case where Sail is installed but not running
  if use_sail and not sail_running then
    local choice = vim.fn.confirm(
      "Laravel Sail is installed but not running. How would you like to install IDE Helper?",
      "&Start Sail first\n&Use standard composer\n&Cancel",
      1 -- Default to starting Sail first now that we know compose exists
    )
    
    if choice == 1 then -- Start Sail first
      vim.notify("Starting Laravel Sail...", vim.log.levels.INFO, { title = "Laravel IDE Helper" })
      
      -- Create a buffer to show output from the Sail start process
      local sail_buffer = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_name(sail_buffer, "Laravel Sail Startup")
      vim.api.nvim_buf_set_lines(sail_buffer, 0, -1, false, {
        "Starting Laravel Sail...",
        "Command: " .. M.get_sail_up_cmd(),
        "Working directory: " .. laravel_root,
        "-------------------------------------------",
        ""
      })
      vim.cmd("sbuffer " .. sail_buffer)
      vim.cmd("setlocal buftype=nofile bufhidden=wipe noswapfile ft=log")
      
      -- Function to add lines to the buffer
      local function log_to_sail_buffer(message)
        if not message or #message == 0 then return end
        
        local lines = type(message) == "table" and message or {message}
        local filtered_lines = {}
        
        for _, line in ipairs(lines) do
          if line and line ~= "" then
            table.insert(filtered_lines, line)
          end
        end
        
        vim.schedule(function()
          local line_count = vim.api.nvim_buf_line_count(sail_buffer)
          vim.api.nvim_buf_set_lines(sail_buffer, line_count, line_count, false, filtered_lines)
          
          -- Auto-scroll
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            if vim.api.nvim_win_get_buf(win) == sail_buffer then
              vim.api.nvim_win_set_cursor(win, {line_count + #filtered_lines, 0})
            end
          end
        end)
      end
      
      -- Start Sail with more verbose output and orphan container cleanup
      local sail_start_cmd = M.get_sail_up_cmd()
      local sail_job_id = vim.fn.jobstart(sail_start_cmd, {
        cwd = laravel_root,
        stdout_buffered = false,
        stderr_buffered = false,
        on_stdout = function(_, data)
          if data and #data > 0 then
            log_to_sail_buffer(data)
          end
        end,
        on_stderr = function(_, data)
          if data and #data > 0 then
            log_to_sail_buffer(data)
          end
        end,
        on_exit = function(_, code)
          if code == 0 then
            log_to_sail_buffer({
              "",
              "-------------------------------------------",
              "Laravel Sail started successfully!",
              "Installing IDE Helper with Sail..."
            })
            
            vim.notify("Laravel Sail started successfully. Installing IDE Helper...", 
                      vim.log.levels.INFO, { title = "Laravel IDE Helper" })
            
            -- Wait a bit for Docker to fully initialize
            vim.defer_fn(function()
              -- Now install with Sail
              M.install_ide_helper_with_command(laravel_root, true, nil)
            end, 5000) -- Increased delay to ensure Docker is fully ready
          else
            log_to_sail_buffer({
              "",
              "-------------------------------------------",
              "Failed to start Laravel Sail with exit code: " .. code,
              "",
              "Possible issues:",
              "1. Docker might not be running",
              "2. There might be port conflicts with existing services",
              "3. Docker compose might have configuration errors",
              "",
              "Falling back to standard composer..."
            })
            
            vim.notify("Failed to start Laravel Sail. Using standard composer instead.", 
                      vim.log.levels.WARN, { title = "Laravel IDE Helper" })
            
            -- Fall back to standard composer
            vim.defer_fn(function()
              M.install_ide_helper_with_command(laravel_root, false, nil) 
            end, 1000)
          end
        end
      })
      
      if sail_job_id <= 0 then
        log_to_sail_buffer({
          "",
          "-------------------------------------------",
          "Failed to execute Sail command.",
          "Check if ./vendor/bin/sail is executable.",
          "Falling back to standard composer..."
        })
        
        vim.notify("Failed to execute Sail command. Using standard composer instead.", 
                  vim.log.levels.WARN, { title = "Laravel IDE Helper" })
        
        vim.defer_fn(function()
          M.install_ide_helper_with_command(laravel_root, false, nil)
        end, 1000)
      else
        -- We've scheduled the installation after Sail starts
        return true
      end
    elseif choice == 2 then -- Use standard composer
      use_sail = false
    else -- Cancel (choice == 3 or any other value)
      vim.notify("Laravel IDE Helper installation cancelled by user", 
                vim.log.levels.INFO, { title = "Laravel IDE Helper" })
      return false -- This should exit the function completely
    end
  end
  
  if not use_sail then
    return M.install_ide_helper_with_command(laravel_root, false, nil)
  else
    return M.install_ide_helper_with_command(laravel_root, true, nil)
  end
end

-- Helper function to install with specific command type
function M.install_ide_helper_with_command(laravel_root, use_sail, existing_bufnr)
  local cmd = use_sail
    and "./vendor/bin/sail composer require --dev barryvdh/laravel-ide-helper"
    or "composer require --dev barryvdh/laravel-ide-helper"
  
  -- Check if Sail is accessible if we're supposed to use it
  if use_sail and vim.fn.executable(laravel_root .. "/vendor/bin/sail") ~= 1 then
    vim.notify("Sail executable not found or not executable. Using standard composer.", 
              vim.log.levels.WARN, { title = "Laravel IDE Helper" })
    
    -- Fall back to standard composer
    cmd = "composer require --dev barryvdh/laravel-ide-helper"
    use_sail = false
  end
  
  vim.notify("Installing Laravel IDE Helper..." .. (use_sail and " (using Sail)" or ""), 
            vim.log.levels.INFO, { title = "Laravel IDE Helper" })
  
  -- Use existing buffer or create a new one
  local bufnr
  if existing_bufnr then
    bufnr = existing_bufnr
    
    -- Add separator to existing buffer
    vim.schedule(function()
      local line_count = vim.api.nvim_buf_line_count(bufnr)
      vim.api.nvim_buf_set_lines(bufnr, line_count, line_count, false, {
        "",
        "-------------------------------------------",
        use_sail and "Installing with Laravel Sail..." or "Retrying installation with standard composer...",
        "Command: " .. cmd,
        "Working directory: " .. laravel_root,
        "-------------------------------------------",
        "",
      })
    end)
  else
    -- Create new buffer
    bufnr = vim.api.nvim_create_buf(false, true)
    
    -- Try to set buffer name, but handle if it already exists
    local success, err = pcall(function()
      vim.api.nvim_buf_set_name(bufnr, "Laravel IDE Helper Install")
    end)
    
    if not success then
      -- If naming fails, just use a unique buffer name with timestamp
      vim.api.nvim_buf_set_name(bufnr, "Laravel IDE Helper Install " .. os.time())
    end
    
    -- Add initial content to buffer
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
      "Installing Laravel IDE Helper..." .. (use_sail and " (using Sail)" or ""),
      "Command: " .. cmd,
      "Working directory: " .. laravel_root,
      "-------------------------------------------",
      "",
    })
    
    -- Show buffer to user
    vim.cmd("sbuffer " .. bufnr)
    vim.cmd("setlocal buftype=nofile bufhidden=wipe noswapfile ft=log")
  end
  
  -- Use the common buffer logger
  local log_to_buffer = M.create_buffer_logger(bufnr)
  
  -- Specific error detection for Sail
  local sail_error_detected = false
  local docker_error_detected = false
  
  -- Start the install process
  local job_id = vim.fn.jobstart(cmd, {
    cwd = laravel_root,  -- Use the Laravel root directory
    stdout_buffered = false,
    stderr_buffered = false,
    on_stdout = function(_, data)
      if data and #data > 0 then
        -- Try to detect sail-specific errors in the output
        if use_sail then
          for _, line in ipairs(data) do
            if line:match("Docker.* not running") or line:match("Cannot connect to the Docker daemon") then
              docker_error_detected = true
            elseif line:match("Error response from daemon") or line:match("Sail is not running") then
              sail_error_detected = true
            end
          end
        end
        
        -- Log all stdout to buffer only, no notifications
        log_to_buffer(data)
      end
    end,
    on_stderr = function(_, data)
      if data and #data > 0 then
        -- Try to detect sail-specific errors in the output
        if use_sail then
          for _, line in ipairs(data) do
            if line:match("Docker.* not running") or line:match("Cannot connect to the Docker daemon") then
              docker_error_detected = true
            elseif line:match("Error response from daemon") or line:match("Sail is not running") then
              sail_error_detected = true
            end
          end
        end
        
        -- Don't mark as errors, just log normally
        log_to_buffer(data)
      end
    end,
    on_exit = function(_, code)
      if code == 0 then
        log_to_buffer({
          "",
          "-------------------------------------------",
          "Laravel IDE Helper installed successfully!",
          "Generating IDE helper files..."
        })
        
        vim.notify("Laravel IDE Helper installed successfully", 
                  vim.log.levels.INFO, { title = "Laravel IDE Helper" })
        
        -- Generate IDE helper files automatically after install
        vim.defer_fn(function()
          M.generate_ide_helper(true, use_sail, bufnr) -- Pass buffer and use_sail setting
        end, 1000) -- Slight delay to let composer finalize
      else
        -- Provide different error messages based on the detected errors
        if use_sail and docker_error_detected then
          log_to_buffer({
            "",
            "-------------------------------------------",
            "INSTALLATION FAILED with exit code: " .. code,
            "",
            "Docker does not appear to be running or accessible.",
            "Possible next steps:",
            "1. Start Docker Desktop or the Docker daemon",
            "2. Make sure the current user has permissions to access Docker",
            "3. Try running the command manually after Docker is running:",
            "   " .. cmd,
            "",
            "Falling back to standard composer..."
          })
        elseif use_sail and sail_error_detected then
          log_to_buffer({
            "",
            "-------------------------------------------",
            "INSTALLATION FAILED with exit code: " .. code,
            "",
            "Sail environment appears to have issues.",
            "Possible next steps:", 
            "1. Try starting Sail manually: " .. M.get_sail_up_cmd(), 
            "2. Check docker-compose.yml for configuration errors",
            "3. Ensure no conflicting services are using the same ports",
            "",
            "Falling back to standard composer..."
          })
        else
          log_to_buffer({
            "",
            "-------------------------------------------",
            "INSTALLATION FAILED with exit code: " .. code,
            "",
            "Possible next steps:",
            "1. Try running the command manually in your Laravel project directory:",
            "   " .. cmd,
            "2. Check if " .. (use_sail and "Docker/Sail" or "Composer") .. " is properly installed",
            "3. Check network connectivity for package downloads"
          })
          
          -- If using Sail, suggest additional debugging steps
          if use_sail then
            log_to_buffer({
              "",
              "For Sail-specific issues:",
              "1. Verify Docker is running",
              "2. Check docker-compose.yml exists and is valid",
              "3. Try manual troubleshooting:",
              "   " .. M.get_sail_down_cmd(),
              "   " .. M.get_sail_up_cmd()
            })
          end
        end
        
        -- If using sail failed, try with standard composer
        if use_sail then
          log_to_buffer({
            "",
            "Attempting installation with standard composer instead..."
          })
          
          vim.notify("Sail installation failed. Trying with standard composer...", 
                    vim.log.levels.WARN, { title = "Laravel IDE Helper" })
          
          vim.defer_fn(function()
            M.install_ide_helper_with_command(laravel_root, false, bufnr)
          end, 1000)
        else
          vim.notify("Failed to install Laravel IDE Helper. See output buffer for details.", 
                    vim.log.levels.ERROR, { title = "Laravel IDE Helper" })
        end
      end
    end
  })
  
  if job_id <= 0 then
    local error_msg
    if use_sail then
      error_msg = "Failed to start Sail command. Check if Sail is accessible."
      
      vim.defer_fn(function()
        vim.notify("Trying with standard composer instead...", 
                  vim.log.levels.WARN, { title = "Laravel IDE Helper" })
        M.install_ide_helper_with_command(laravel_root, false, bufnr)
      end, 1000)
    else
      error_msg = "Failed to start Composer command. Check if Composer is installed."
    end
    
    log_to_buffer({
      "",
      "-------------------------------------------",
      error_msg
    })
    
    vim.notify(error_msg, vim.log.levels.ERROR, { title = "Laravel IDE Helper" })
    return false
  end
  
  return true
end

-- Check if IDE Helper files exist
function M.ide_helper_files_exist()
  local laravel_root = M.find_laravel_root()
  if not laravel_root then
    return false
  end
  
  -- Check for the main IDE helper files
  local files = {
    laravel_root .. "/_ide_helper.php",
    laravel_root .. "/_ide_helper_models.php",
    laravel_root .. "/.phpstorm.meta.php"
  }
  
  for _, file in ipairs(files) do
    if vim.fn.filereadable(file) == 1 then
      return true
    end
  end
  return false
end

-- Check if Sail is available
function M.has_sail()
  local laravel_root = M.find_laravel_root()
  if not laravel_root then
    return false
  end
  
  -- Check if the Sail script exists and is executable
  local sail_path = laravel_root .. "/vendor/bin/sail"
  return vim.fn.filereadable(sail_path) == 1 and vim.fn.executable(sail_path) == 1
end

-- Check if user has specified to always use standard PHP instead of Sail
function M.prefer_standard_php(laravel_root)
  local prefs = M.read_user_preference(laravel_root)
  if not prefs then
    return false
  end
  
  return prefs["use_standard_php"] == "always"
end

-- Handle the uninstallation of Laravel Sail
function M.uninstall_sail(laravel_root)
  -- Create a buffer for output
  local buffer = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(buffer, "Laravel Sail Uninstallation")
  vim.api.nvim_buf_set_lines(buffer, 0, -1, false, {
    "Uninstalling Laravel Sail...",
    "Working directory: " .. laravel_root,
    "-------------------------------------------",
    ""
  })
  
  -- Show buffer to user
  vim.cmd("sbuffer " .. buffer)
  vim.cmd("setlocal buftype=nofile bufhidden=wipe noswapfile ft=log")
  
  -- Use the common buffer logger
  local log_to_buffer = M.create_buffer_logger(buffer)
  
  -- Check if Sail is currently running
  if M.is_sail_running() then
    log_to_buffer({
      "Sail is currently running. We'll stop it before uninstalling.",
      "",
      "⚠️ WARNING: Any data stored in Sail's Docker containers (like databases) will be lost.",
      "Make sure you've backed up any important data before proceeding.",
      ""
    })
    
    -- Ask for confirmation before stopping Sail
    local choice = vim.fn.confirm(
      "Sail containers may contain important data (databases, etc).\nAre you sure you want to stop Sail and uninstall it?",
      "&Yes, stop and uninstall\n&No, cancel uninstallation",
      2 -- Default to No (safer)
    )
    
    if choice ~= 1 then
      log_to_buffer("Uninstallation cancelled by user.")
      vim.notify("Sail uninstallation cancelled", vim.log.levels.INFO)
      return false
    end
    
    -- Stop Sail
    log_to_buffer({
      "",
      "Stopping Sail containers...",
      "Command: " .. M.get_sail_down_cmd(),
      ""
    })
    
    -- Run sail down command
    local down_success = M.run_job(
      M.get_sail_down_cmd(),
      laravel_root,
      buffer,
      function() 
        log_to_buffer({
          "",
          "Successfully stopped Sail containers.",
          ""
        })
      end,
      function(error_info) 
        log_to_buffer({
          "",
          "Failed to stop Sail containers. Error: " .. (error_info.exit_code or "unknown"),
          "Proceeding with uninstallation anyway...",
          ""
        })
      end,
      {
        wait = true,
        timeout = 30000, -- 30 seconds
        completion_message = "Sail containers successfully stopped"
      }
    )
  else
    log_to_buffer("Sail is not currently running. Proceeding with uninstallation.")
  end
  
  -- Remove Sail package
  log_to_buffer({
    "",
    "Removing Laravel Sail package with Composer...",
    "Command: composer remove laravel/sail --dev",
    ""
  })
  
  local remove_success = M.run_job(
    "composer remove laravel/sail --dev",
    laravel_root,
    buffer,
    function()
      log_to_buffer({
        "",
        "Successfully removed Sail package.",
        ""
      })
    end,
    function(error_info)
      log_to_buffer({
        "",
        "Failed to remove Sail package. Error: " .. (error_info.exit_code or "unknown"),
        "You may need to manually remove it with: composer remove laravel/sail --dev",
        ""
      })
      
      vim.notify(
        "Failed to remove Laravel Sail package. See buffer for details.",
        vim.log.levels.WARN,
        { title = "Laravel Sail Uninstallation" }
      )
      
      return false
    end,
    {
      wait = true,
      timeout = 60000, -- 60 seconds
      completion_message = "Laravel Sail package successfully removed"
    }
  )
  
  -- Check for docker-compose.yml and ask if user wants to remove it
  local has_docker_compose = M.has_docker_compose()
  if has_docker_compose then
    local compose_files = {}
    
    -- Check common docker-compose file names
    for _, filename in ipairs({"docker-compose.yml", "docker-compose.yaml"}) do
      local filepath = laravel_root .. "/" .. filename
      if vim.fn.filereadable(filepath) == 1 then
        table.insert(compose_files, filepath)
      end
    end
    
    if #compose_files > 0 then
      log_to_buffer({
        "",
        "Found Docker Compose file(s):",
        table.concat(compose_files, "\n"),
        ""
      })
      
      local choice = vim.fn.confirm(
        "Do you want to remove the Docker Compose file(s) as well?",
        "&Yes, remove them\n&No, keep them",
        2 -- Default to No (safer)
      )
      
      if choice == 1 then
        for _, filepath in ipairs(compose_files) do
          local filename = vim.fn.fnamemodify(filepath, ":t")
          log_to_buffer("Removing " .. filename .. "...")
          
          local delete_result = vim.fn.delete(filepath)
          if delete_result == 0 then
            log_to_buffer("Successfully removed " .. filename)
          else
            log_to_buffer("Failed to remove " .. filename .. ". Error code: " .. delete_result)
          end
        end
      else
        log_to_buffer("Keeping Docker Compose file(s) as requested.")
      end
    end
  end
  
  -- Save preference to always use standard PHP
  local success, error_msg = M.save_user_preference(laravel_root, "use_standard_php", "always")
  if success then
    log_to_buffer({
      "",
      "Saved preference to always use standard PHP for this project.",
      "This setting (use_standard_php=always) is stored in .nvim-helper.",
      "To use Sail again in the future:",
      "1. Edit .nvim-helper and delete the 'use_standard_php=always' line",
      "2. Reinstall Sail with 'composer require laravel/sail --dev'",
      ""
    })
  else
    log_to_buffer({
      "",
      "Failed to save preference: " .. (error_msg or "Unknown error"),
      ""
    })
  end
  
  log_to_buffer({
    "",
    "-------------------------------------------",
    "Laravel Sail uninstallation completed!",
    "Standard PHP/Composer will now be used for this project.",
    "-------------------------------------------"
  })
  
  vim.notify(
    "Laravel Sail successfully uninstalled. Standard PHP will be used.",
    vim.log.levels.INFO,
    { title = "Laravel Sail Uninstallation" }
  )
  
  return true
end

-- Check if Docker is installed and running
function M.is_docker_available()
  -- First check if docker is installed
  if vim.fn.executable("docker") ~= 1 then
    return false
  end
  
  -- Then check if docker daemon is running
  local result = vim.fn.system("docker info 2>/dev/null")
  local exit_code = vim.v.shell_error
  
  return exit_code == 0
end

-- Check if Docker Compose file exists for Sail
function M.has_docker_compose()
  local laravel_root = M.find_laravel_root()
  if not laravel_root then
    return false
  end
  
  -- Check for both the newer and older Docker Compose file formats
  return vim.fn.filereadable(laravel_root .. "/docker-compose.yml") == 1 or
         vim.fn.filereadable(laravel_root .. "/docker-compose.yaml") == 1
end

-- State tracking for database connection status
M.last_db_connection_failed = false

-- Generate IDE Helper files
function M.generate_ide_helper(force, use_sail_override, existing_bufnr)
  local laravel_root = M.find_laravel_root()
  if not laravel_root then
    vim.notify("Not a Laravel project", vim.log.levels.WARN)
    return false
  end
  
  -- Reset database connection state for this run
  M.last_db_connection_failed = false
  
  -- Check if this is a production environment and warn the user
  if M.is_production_environment() then
    vim.notify(
      "⚠️ WARNING: This appears to be a production Laravel environment. ⚠️\n" ..
      "Generating IDE Helper files in production is not recommended.\n" ..
      "Please check your .env file or config/app.php.",
      vim.log.levels.ERROR,
      { 
        title = "Laravel IDE Helper - PRODUCTION ENVIRONMENT DETECTED",
        timeout = 10000  -- 10 seconds (twice the default 5000ms)
      }
    )
    
    -- Ask for confirmation before proceeding
    local choice = vim.fn.confirm(
      "This appears to be a production Laravel environment. IDE Helper should NOT be used in production.\n" ..
      "Are you absolutely sure you want to continue?",
      "&Cancel\n&I understand the risks, proceed anyway",
      1 -- Default to Cancel
    )
    
    if choice ~= 2 then -- Not confirmed
      vim.notify("Laravel IDE Helper generation cancelled", vim.log.levels.INFO)
      return false
    end
    
    -- If they confirm, show one more strong warning
    vim.notify(
      "⚠️ Proceeding with IDE Helper in PRODUCTION environment at user's request! ⚠️\n" ..
      "This is NOT recommended and could potentially modify production data.",
      vim.log.levels.WARN,
      { 
        title = "Laravel IDE Helper - PROCEEDING IN PRODUCTION", 
        timeout = 10000  -- 10 seconds (twice the default 5000ms)
      }
    )
  end
  
  if not M.has_ide_helper() then
    -- Offer to install the IDE Helper
    local choice = vim.fn.confirm(
      "Laravel IDE Helper is not installed. Would you like to install it?",
      "&Yes\n&No",
      1
    )
    
    if choice == 1 then -- Yes
      M.install_ide_helper()
    else
      vim.notify("Laravel IDE Helper not installed. You can install it with 'composer require --dev barryvdh/laravel-ide-helper'", 
                vim.log.levels.INFO, { title = "Laravel IDE Helper" })
    end
    return false
  end
  
  if not force and M.ide_helper_files_exist() then
    vim.notify("IDE Helper files already exist. Use force=true to regenerate.", 
               vim.log.levels.INFO, { title = "Laravel IDE Helper" })
    return true
  end
  
  -- Check user preference for standard PHP first
  if M.prefer_standard_php(laravel_root) then
    vim.notify("Using standard PHP (as per saved preference).", 
              vim.log.levels.INFO, { title = "Laravel IDE Helper" })
    use_sail_override = false  -- Override with standard PHP
  end
  
  -- Check if Sail usage is explicitly specified 
  local use_sail 
  if use_sail_override ~= nil then
    -- If explicitly specified, use that value
    use_sail = use_sail_override
  else
    -- Otherwise detect it
    use_sail = M.has_sail()
    
    -- Check if Docker is available if we plan to use Sail
    if use_sail and not M.is_docker_available() then
      vim.notify("Laravel Sail is available, but Docker is not installed or not running. Using standard PHP.", 
                vim.log.levels.WARN, { title = "Laravel IDE Helper" })
      use_sail = false
    end
    
    -- If Sail is available, but we don't know if we should use it yet
    if use_sail then
      local sail_running = M.is_sail_running()
      local has_docker_compose = M.has_docker_compose()
      
      -- If Sail is installed but not running, we need to ask what to do
      if not sail_running then
        local choice = vim.fn.confirm(
          "Laravel Sail is installed but not running. How would you like to generate IDE Helper files?",
          "&Start Sail first\n&Use standard PHP\n&Cancel",
          2 -- Default to standard PHP
        )
        
        if choice == 1 then -- Start Sail first
          if not has_docker_compose then
            vim.notify("Docker Compose file not found. Using standard PHP instead.", 
                      vim.log.levels.WARN, { title = "Laravel IDE Helper" })
            use_sail = false
          else
            vim.notify("Starting Laravel Sail...", vim.log.levels.INFO, { title = "Laravel IDE Helper" })
            
            -- This is just for generating files, so we'll create a temporary buffer
            local temp_bufnr = vim.api.nvim_create_buf(false, true)
            vim.api.nvim_buf_set_lines(temp_bufnr, 0, -1, false, {
              "Starting Laravel Sail...",
              "Please wait...",
            })
            vim.cmd("sbuffer " .. temp_bufnr)
            vim.cmd("setlocal buftype=nofile bufhidden=wipe noswapfile")
            
            -- Start Sail
            local sail_start_cmd = M.get_sail_up_cmd()
            local sail_job_id = vim.fn.jobstart(sail_start_cmd, {
              cwd = laravel_root,
              on_exit = function(_, code)
                if code == 0 then
                  vim.api.nvim_buf_set_lines(temp_bufnr, 1, 2, false, {"Sail started successfully!"})
                  vim.notify("Laravel Sail started successfully", 
                          vim.log.levels.INFO, { title = "Laravel IDE Helper" })
                  
                  -- Wait for Docker to initialize fully
                  vim.defer_fn(function()
                    -- Don't delete buffer - keep it open to show the logs
                    vim.api.nvim_buf_set_lines(temp_bufnr, -1, -1, false, {
                      "",
                      "--- Sail started successfully, now generating IDE Helper files ---",
                      ""
                    })
                    -- Restart with sail enabled
                    M.generate_ide_helper(force, true)
                  end, 3000)
                else
                  vim.api.nvim_buf_set_lines(temp_bufnr, 1, 2, false, {"Failed to start Laravel Sail. Using standard PHP."})
                  vim.notify("Failed to start Laravel Sail. Using standard PHP instead.", 
                          vim.log.levels.WARN, { title = "Laravel IDE Helper" })
                  
                  vim.defer_fn(function()
                    -- Don't delete buffer - keep it open to show the logs
                    vim.api.nvim_buf_set_lines(temp_bufnr, -1, -1, false, {
                      "",
                      "--- Failed to start Sail, continuing with standard PHP ---",
                      ""
                    })
                    -- Restart with sail disabled
                    M.generate_ide_helper(force, false) 
                  end, 2000)
                end
              end
            })
            
            if sail_job_id <= 0 then
              vim.api.nvim_buf_set_lines(temp_bufnr, 1, 2, false, {"Failed to execute Sail command. Using standard PHP."})
              vim.notify("Failed to execute Sail command. Using standard PHP instead.", 
                      vim.log.levels.WARN, { title = "Laravel IDE Helper" })
              
              vim.defer_fn(function()
                -- Don't delete buffer - keep it open to show the logs
                vim.api.nvim_buf_set_lines(temp_bufnr, -1, -1, false, {
                  "",
                  "--- Failed to execute Sail command, continuing with standard PHP ---",
                  ""
                })
                -- Continue with sail disabled  
                use_sail = false
              end, 2000)
            else
              -- We've scheduled the generation after Sail starts
              return false
            end
          end
        elseif choice == 2 then -- Use standard PHP
          use_sail = false
        else -- Cancel
          return false
        end
      end
    end
  end
  
  -- Use existing buffer or create a new one
  local bufnr
  if existing_bufnr then
    bufnr = existing_bufnr
    
    -- Add separator to existing buffer
    vim.schedule(function()
      local line_count = vim.api.nvim_buf_line_count(bufnr)
      vim.api.nvim_buf_set_lines(bufnr, line_count, line_count, false, {
        "",
        "-------------------------------------------",
        "Generating Laravel IDE Helper files...",
        "Working directory: " .. laravel_root,
        "Using " .. (use_sail and "Laravel Sail" or "standard PHP"),
        "-------------------------------------------",
        "",
      })
    end)
  else
    -- Create new buffer for output
    bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(bufnr, "Laravel IDE Helper Generation")
    
    -- Add initial content to buffer
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
      "Generating Laravel IDE Helper files...",
      "Working directory: " .. laravel_root,
      "Using " .. (use_sail and "Laravel Sail" or "standard PHP"),
      "-------------------------------------------",
      "",
    })
    
    -- Show buffer to user
    vim.cmd("sbuffer " .. bufnr)
    vim.cmd("setlocal buftype=nofile bufhidden=wipe noswapfile ft=log")
  end
  
  -- Use the common buffer logger
  local log_to_buffer = M.create_buffer_logger(bufnr)
  
  -- Commands to run
  local commands = {}
  
  -- First migrate the database to ensure schema is ready 
  -- (important for IDE helper which relies on the database schema)
  if use_sail then
    -- Wait for the database to be ready - customized message is handled by run_job
    table.insert(commands, "echo 'Waiting for database to initialize...' && sleep 10")
    
    -- Create a database connection test with a command that works in all Laravel versions
    table.insert(commands, "./vendor/bin/sail php artisan tinker --execute=\"try { DB::connection()->getPdo(); echo 'Database connection successful.'; } catch (\\\\Exception \\$e) { echo 'Database connection failed: ' . \\$e->getMessage(); exit(1); }\"")
    
    -- Then include migration command with reduced verbosity
    table.insert(commands, "./vendor/bin/sail php artisan migrate --quiet") -- Run migrations with minimal output
  end
  
  -- Then add the IDE helper commands
  table.insert(commands, "php artisan ide-helper:generate --quiet") -- Generates basic PHPDoc with minimal output
  table.insert(commands, "php artisan ide-helper:models -N --quiet") -- Generates PHPDocs for models with minimal output
  table.insert(commands, "php artisan ide-helper:meta --quiet")  -- Generates PhpStorm meta file with minimal output
  
  -- Use Sail if needed (for the standard commands that don't already have the sail prefix)
  if use_sail then
    -- We've already added database commands with sail prefixes
    -- Now add sail prefix to the IDE helper commands (start from regular PHP commands)
    for i = 4, #commands do  -- Skip the first three commands which already have sail prefix
      commands[i] = "./vendor/bin/sail " .. commands[i]
    end
  else
    -- If we're not using Sail but need database setup, add standard migration command
    -- Only add this in non-Sail mode, since we've already added Sail-specific versions above
    
    -- Add database connection check and migration, but for standard PHP
    table.insert(commands, 1, "php artisan tinker --execute=\"try { DB::connection()->getPdo(); echo 'Database connection successful.'; } catch (\\\\Exception \\$e) { echo 'Database connection failed: ' . \\$e->getMessage(); exit(1); }\"")
    table.insert(commands, 2, "php artisan migrate --quiet") -- Add migration after connection check with minimal output
  end
  
  -- Only one notification at the beginning
  vim.notify("Generating Laravel IDE Helper files. See buffer for progress.", 
            vim.log.levels.INFO, { title = "Laravel IDE Helper" })
  
  -- Track success of all commands
  local all_succeeded = true
  
  -- Run commands sequentially in background
  local run_next_command
  local command_index = 1
  
  -- Variables to allow conditional execution
  local skip_migration_index = nil
  local db_connection_check_index = nil
  
  -- Find the indexes of DB connection check and migration commands
  for i, cmd in ipairs(commands) do
    if cmd:match("artisan tinker.*DB::connection") then
      db_connection_check_index = i
    elseif cmd:match("artisan migrate") and db_connection_check_index then
      -- This is a migration command that follows a DB check
      skip_migration_index = i
      break
    end
  end
  
  -- Let's create a modified command list that dynamically skips migrations
  -- based on previous DB connection results
  local function get_next_command()
    if command_index > #commands then
      return nil
    end
    
    local cmd = commands[command_index]
    command_index = command_index + 1
    
    -- If this is a migration command and previous DB connection failed,
    -- skip it and get the next command
    if cmd:match("artisan migrate") and M.last_db_connection_failed then
      log_to_buffer({
        "",
        "Skipping database migration due to previous connection failure.",
        ""
      })
      return get_next_command() -- Recursively get the next valid command
    end
    
    return cmd
  end
  
  run_next_command = function()
    local cmd = get_next_command()
    
    if not cmd then
      -- All commands complete
      if all_succeeded then
        log_to_buffer({
          "",
          "-------------------------------------------",
          "All Laravel IDE Helper files generated successfully!",
          "Restarting PHP LSP server..."
        })
        
        -- Final success notification is still useful
        vim.notify("Laravel IDE Helper files generated successfully", 
                 vim.log.levels.INFO, { title = "Laravel IDE Helper" })
        
        -- Reload LSP for the current buffer to pick up the new definitions
        vim.schedule(function()
          -- Restart all active LSP servers without specifying a particular one
          vim.cmd("LspRestart")
          log_to_buffer("LSP server restart initiated")
          
          -- Give it a moment to restart, then reload the current buffer
          vim.defer_fn(function()
            -- Force reload of the current buffer
            local current_buf = vim.api.nvim_get_current_buf()
            local current_file = vim.api.nvim_buf_get_name(current_buf)
            
            if current_file ~= "" then
              -- Don't force reload the current buffer, it could discard user changes 
              -- and would close the output buffer. Instead just notify success.
              vim.notify("LSP restarted to load IDE Helper files", 
                        vim.log.levels.INFO, { title = "Laravel IDE Helper" })
              log_to_buffer({
                "",
                "-------------------------------------------",
                "IDE Helper process completed successfully!",
                "All files have been generated and the LSP server has been restarted.",
                "You may now close this buffer manually when you're done reviewing the output.",
                "-------------------------------------------",
                ""
              })
            end
          end, 2000) -- 2 second delay to allow LSP to restart fully
        end)
      else
        log_to_buffer({
          "",
          "-------------------------------------------",
          "Some IDE Helper commands failed. Check the logs above for details.",
          "You may need to run the commands manually in your Laravel project directory."
        })
        
        vim.notify("Some Laravel IDE Helper commands failed. See buffer for details.", 
                  vim.log.levels.WARN, { title = "Laravel IDE Helper" })
      end
      return
    end
    
    -- No notifications needed during command execution - everything goes to buffer
    
    local cmd = commands[command_index]
    log_to_buffer({
      "",
      "Running: " .. cmd
    })
    
    -- If no command (might be at the end), just stop
    if not cmd then
      return
    end
    
    local job_id = vim.fn.jobstart(cmd, {
      cwd = laravel_root,
      stdout_buffered = false,
      stderr_buffered = false,
      on_stdout = function(_, data)
        if data and #data > 0 then
          -- Check for Laravel-specific errors in the output
          for _, line in ipairs(data) do
            if type(line) == "string" then
              if line:match("could not find driver") or 
                line:match("database.+connection") or
                line:match("SQLSTATE") then
                -- Detected database connection issue
                log_to_buffer({
                  "DATABASE CONNECTION ERROR DETECTED: This might be because the database is not ready or properly configured.",
                  "Consider running 'php artisan migrate' manually if this is a fresh Laravel project.",
                })
              elseif line:match("Model.+not found") or 
                    line:match("Class.+not found") or
                    line:match("table.+does not exist") then
                -- Detected schema/model issue
                log_to_buffer({
                  "MODEL/SCHEMA ERROR DETECTED: This might be because database tables are not properly set up.",
                  "The IDE helper might still generate partial information despite this error.",
                })
              end
            end
          end
          
          -- Only log to buffer, no notifications
          log_to_buffer(data)
        end
      end,
      on_stderr = function(_, data)
        if data and #data > 0 then
          -- Check for Laravel-specific errors in stderr
          for _, line in ipairs(data) do
            if type(line) == "string" then
              if line:match("could not find driver") or 
                line:match("database.+connection") or
                line:match("SQLSTATE") then
                -- Detected database connection issue
                log_to_buffer({
                  "DATABASE CONNECTION ERROR DETECTED: This might be because the database is not ready or properly configured.",
                  "Consider running 'php artisan migrate' manually if this is a fresh Laravel project.",
                })
              elseif line:match("Model.+not found") or 
                    line:match("Class.+not found") or
                    line:match("ReflectionException") or
                    line:match("table.+does not exist") then
                -- Detected schema/model issue
                log_to_buffer({
                  "MODEL/SCHEMA ERROR DETECTED: This might be because database tables are not properly set up.",
                  "The IDE helper might still generate partial information despite this error.",
                })
              end
            end
          end
          
          -- Don't mark as errors, just log normally
          log_to_buffer(data)
        end
      end,
      on_exit = function(_, code)
        -- Check if this is a DB-related command which can fail but we should continue
      local is_db_command = cmd:match("artisan migrate") or 
                           cmd:match("artisan db:seed") or
                           cmd:match("artisan tinker") or
                           cmd:match("sleep [0-9]+")
      
      if code ~= 0 then
        -- Only mark as failure if it's not a database command
        if not is_db_command then
          all_succeeded = false
        end
        
        if is_db_command then
          if cmd:match("artisan tinker") and cmd:match("DB::connection") then
            -- Record that DB connection failed for later commands
            M.last_db_connection_failed = true
            
            log_to_buffer({
              "Database connection failed. Database may still be initializing or credentials may be incorrect.",
              "Will skip migration and continue with IDE Helper generation.",
              "Some model information may be incomplete without database connection.",
              "-------------------------------------------"
            })
          elseif cmd:match("artisan migrate") then
            -- Record that database setup failed
            M.last_db_connection_failed = true
            
            log_to_buffer({
              "Database migration failed with code: " .. code,
              "This is non-critical, continuing with IDE Helper generation...",
              "Note: Some IDE helper model information may be incomplete without migrated tables.",
              "-------------------------------------------"
            })
          else
            log_to_buffer({
              "Database command exited with code: " .. code,
              "This is non-critical, continuing with IDE Helper generation...",
              "-------------------------------------------"
            })
          end
        else
          log_to_buffer({
            "Command failed with exit code: " .. code,
            "-------------------------------------------"
          })
        end
      else
        -- Show success message, with special handling for IDE Helper model generation
        if cmd:match("ide%-helper:models") and M.last_db_connection_failed then
          -- If we had a previous DB connection failure, the models command may not have worked fully
          log_to_buffer({
            "Command completed, but database connection issues may have limited the results.",
            "-------------------------------------------"
          })
        else
          log_to_buffer({
            "Command completed successfully",
            "-------------------------------------------"
          })
        end
      end
      
      -- Move to next command
      command_index = command_index + 1
      run_next_command()
      end
    })
    
    if job_id <= 0 then
      log_to_buffer("Failed to start command: " .. cmd)
      all_succeeded = false
      command_index = command_index + 1
      run_next_command()
    end
  end
  
  -- Start the command chain
  run_next_command()
  
  return true
end

-- Auto-check and generate IDE Helper files
function M.setup_auto_ide_helper()
  -- Create the command to manually generate IDE helper files
  vim.api.nvim_create_user_command("LaravelGenerateIDEHelper", function()
    M.generate_ide_helper(true)
  end, { desc = "Generate Laravel IDE Helper files" })
  
  -- Create a command to install IDE helper package
  vim.api.nvim_create_user_command("LaravelInstallIDEHelper", function()
    M.install_ide_helper()
  end, { desc = "Install Laravel IDE Helper package" })
  
  -- Set a flag to avoid showing multiple prompts in the same session
  if not vim.g.laravel_ide_helper_checked then
    vim.g.laravel_ide_helper_checked = {}
  end
  
  -- Handle Sail startup with proper error handling and buffer logging
function M.start_sail(laravel_root, buffer, on_success, on_failure)
  local log_to_buffer = M.create_buffer_logger(buffer)
  
  log_to_buffer({
    "",
    "Starting Laravel Sail...",
    "Command: " .. M.get_sail_up_cmd(),
    "Working directory: " .. laravel_root,
    "-------------------------------------------",
    ""
  })
  
  vim.notify("Starting Laravel Sail...", vim.log.levels.INFO, { title = "Laravel IDE Helper" })
  
  -- Start Sail with more verbose output and orphan container cleanup
  local sail_start_cmd = M.get_sail_up_cmd()
  local sail_job_id = vim.fn.jobstart(sail_start_cmd, {
    cwd = laravel_root,
    stdout_buffered = false,
    stderr_buffered = false,
    on_stdout = function(_, data)
      if data and #data > 0 then
        log_to_buffer(data)
      end
    end,
    on_stderr = function(_, data)
      if data and #data > 0 then
        log_to_buffer(data)
      end
    end,
    on_exit = function(_, code)
      if code == 0 then
        log_to_buffer({
          "",
          "-------------------------------------------",
          "Laravel Sail started successfully!",
          ""
        })
        
        vim.notify("Laravel Sail started successfully", 
                  vim.log.levels.INFO, { title = "Laravel IDE Helper" })
        
        -- Wait a bit for Docker to fully initialize
        vim.defer_fn(function()
          on_success()
        end, 5000) -- Increased delay to ensure Docker is fully ready
      else
        log_to_buffer({
          "",
          "-------------------------------------------",
          "Failed to start Laravel Sail with exit code: " .. code,
          "",
          "Possible issues:",
          "1. Docker might not be running",
          "2. There might be port conflicts with existing services",
          "3. Docker compose might have configuration errors",
          "",
          "Falling back to standard composer..."
        })
        
        vim.notify("Failed to start Laravel Sail. Using standard PHP/composer instead.", 
                  vim.log.levels.WARN, { title = "Laravel IDE Helper" })
        
        vim.defer_fn(function()
          on_failure()
        end, 1000)
      end
    end
  })
  
  if sail_job_id <= 0 then
    log_to_buffer({
      "",
      "-------------------------------------------",
      "Failed to execute Sail command.",
      "Check if ./vendor/bin/sail is executable.",
      "Falling back to standard PHP/composer..."
    })
    
    vim.notify("Failed to execute Sail command. Using standard PHP/composer instead.", 
              vim.log.levels.WARN, { title = "Laravel IDE Helper" })
    
    vim.defer_fn(function()
      on_failure()
    end, 1000)
  end
end

-- Handle Docker compose creation with improved flow
function M.handle_docker_compose_creation(laravel_root, on_success, on_standard_php, on_cancel)
  local compose_choice = vim.fn.confirm(
    "Laravel Sail is installed but no docker-compose.yml file was found. What would you like to do?",
    "&Create default docker-compose.yml\n&Use standard PHP/composer\nCa&ncel",
    1 -- Default to creating docker-compose.yml
  )
  
  if compose_choice == 1 then -- Create docker-compose.yml
    local result = M.create_default_docker_compose(laravel_root)
    if result == true then
      vim.notify("Created docker-compose.yml, now starting Sail...", 
                vim.log.levels.INFO, { title = "Laravel IDE Helper" })
      on_success()
    elseif result == false then
      -- Failed to create docker-compose.yml but user chose to continue
      vim.notify("Failed to create docker-compose.yml. Using standard PHP/composer instead.", 
               vim.log.levels.WARN, { title = "Laravel IDE Helper" })
      on_standard_php()
    else
      -- result is nil (user cancelled)
      vim.notify("Operation cancelled by user", 
               vim.log.levels.INFO, { title = "Laravel IDE Helper" })
      on_cancel()
    end
  elseif compose_choice == 2 then -- Use standard PHP/composer
    on_standard_php()
  else -- Cancel
    vim.notify("Laravel IDE Helper operation cancelled by user", 
              vim.log.levels.INFO, { title = "Laravel IDE Helper" })
    on_cancel()
  end
end

-- Handle Sail not running with improved flow
function M.handle_sail_not_running(laravel_root, operation_type, buffer, on_success_with_sail, on_standard, on_cancel)
  local message = "Laravel Sail is installed but not running. How would you like to " 
  if operation_type == "install" then
    message = message .. "install IDE Helper?"
  else
    message = message .. "generate IDE Helper files?"
  end
  
  local sail_choice = vim.fn.confirm(
    message,
    "&Start Sail first\n&Use standard " .. (operation_type == "install" and "composer" or "PHP") .. "\n&Cancel",
    2 -- Default to standard option
  )
  
  if sail_choice == 1 then -- Start Sail first
    if not M.has_docker_compose() then
      -- Handle missing docker-compose.yml
      M.handle_docker_compose_creation(
        laravel_root,
        on_success_with_sail,  -- When compose created successfully
        on_standard,          -- When falling back to standard PHP/composer
        on_cancel             -- When operation is cancelled
      )
    else
      -- Docker compose exists, start Sail
      M.start_sail(
        laravel_root, 
        buffer,
        on_success_with_sail,  -- When Sail starts successfully
        on_standard           -- When Sail fails and we fall back to standard
      )
    end
  elseif sail_choice == 2 then -- Use standard option
    -- Ask if they want to use standard PHP for all operations in this project
    local remember_choice = vim.fn.confirm(
      "Would you like to always use standard PHP/composer for this project?\n" ..
      "You won't be prompted about Sail again.",
      "&Just this time\n&Always use standard PHP\n&Always use standard PHP and uninstall Sail",
      1 -- Default to just this time
    )
    
    if remember_choice == 2 then -- Always use standard PHP
      local success, error_msg = M.save_user_preference(laravel_root, "use_standard_php", "always")
      if success then
        vim.notify(
          "Preference saved in .nvim-helper. To use Sail again, edit 'use_standard_php=always' to 'prompt' or delete the line.",
          vim.log.levels.INFO,
          { title = "Laravel IDE Helper" }
        )
      else
        vim.notify(
          "Failed to save preference: " .. (error_msg or "Unknown error"),
          vim.log.levels.WARN,
          { title = "Laravel IDE Helper" }
        )
      end
    elseif remember_choice == 3 then -- Uninstall Sail
      -- First handle the current operation with standard PHP
      on_standard()
      
      -- Then uninstall Sail
      vim.defer_fn(function()
        M.uninstall_sail(laravel_root)
      end, 500)
      
      -- Return early since we've already called on_standard()
      return
    end
    
    -- Proceed with standard PHP for this operation
    on_standard()
  else -- Cancel
    vim.notify("Laravel IDE Helper operation cancelled by user", 
              vim.log.levels.INFO, { title = "Laravel IDE Helper" })
    on_cancel()
  end
end

-- Create a unified buffer logger function
function M.create_buffer_logger(buffer)
  -- Create a new buffer if one wasn't provided
  local bufnr = buffer
  if not bufnr then
    bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(bufnr, "Laravel IDE Helper Log " .. os.time())
    vim.cmd("sbuffer " .. bufnr)
    vim.cmd("setlocal buftype=nofile bufhidden=wipe noswapfile ft=log")
  end
  
  -- Return a function that logs to this buffer
  return function(message)
    if not message or (type(message) == "string" and message == "") or 
       (type(message) == "table" and #message == 0) then 
      return 
    end
    
    local filtered_lines = {}
    
    if type(message) == "table" then
      -- Handle table of lines
      for _, line in ipairs(message) do
        if line and line ~= "" then
          -- Split each line in case it contains newlines
          if type(line) == "string" and line:find("\n") then
            for subline in line:gmatch("[^\r\n]+") do
              -- Strip ANSI color codes
              subline = subline:gsub("\27%[[0-9;:]*m", "")
              table.insert(filtered_lines, subline)
            end
          else
            if type(line) == "string" then
              -- Strip ANSI color codes
              line = line:gsub("\27%[[0-9;:]*m", "")
            end
            table.insert(filtered_lines, line)
          end
        end
      end
    else
      -- Handle string, possibly with newlines
      if message:find("\n") then
        for line in message:gmatch("[^\r\n]+") do
          -- Strip ANSI color codes
          line = line:gsub("\27%[[0-9;:]*m", "")
          table.insert(filtered_lines, line)
        end
      else
        -- Strip ANSI color codes
        message = message:gsub("\27%[[0-9;:]*m", "")
        table.insert(filtered_lines, message)
      end
    end
    
    -- Only proceed if we have valid lines to add
    if #filtered_lines == 0 then return end
    
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(bufnr) then
        local line_count = vim.api.nvim_buf_line_count(bufnr)
        vim.api.nvim_buf_set_lines(bufnr, line_count, line_count, false, filtered_lines)
        
        -- Auto-scroll
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == bufnr then
            vim.api.nvim_win_set_cursor(win, {line_count + #filtered_lines, 0})
          end
        end
      end
    end)
    
    return bufnr
  end
end

-- Only run on PHP files and only in Laravel projects
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*.php",
  callback = function()
    -- Get the Laravel root if it exists
    local laravel_root = M.find_laravel_root()
    if not laravel_root then return end
    
    -- Skip if we've already checked this project in this session
    if vim.g.laravel_ide_helper_checked[laravel_root] then return end
    
    -- Mark this project as checked to avoid multiple prompts
    vim.g.laravel_ide_helper_checked[laravel_root] = true
    
    -- Check for IDE Helper in this Laravel project
    vim.defer_fn(function()
      -- First check if this is a production environment
      if M.is_production_environment() then
        -- Just show a warning notification but don't prompt to install
        vim.notify(
          "⚠️ This appears to be a production Laravel environment. ⚠️\n" ..
          "IDE Helper installation has been disabled for safety.\n" ..
          "If this is actually a development environment, check your .env file.",
          vim.log.levels.WARN,
          { 
            title = "Laravel IDE Helper - PRODUCTION ENVIRONMENT DETECTED",
            timeout = 10000  -- 10 seconds (twice the default 5000ms)
          }
        )
        return -- Don't proceed with auto-prompts in production
      end
      
      -- Check if user has previously declined IDE Helper installation
      if M.is_ide_helper_declined(laravel_root) then
        -- User has previously declined and chosen to remember that decision
        -- Silently respect their choice without bothering them
        return
      end
      
      if not M.has_ide_helper() then
        -- Ask user if they want to install IDE helper package
        local choice = vim.fn.confirm(
          "Laravel IDE Helper is not installed in " .. vim.fn.fnamemodify(laravel_root, ":~") .. 
          ". Install for better autocompletion?", 
          "&Yes\n&No", 
          1
        )
        
        if choice == 1 then
          -- User wants to install, proceed with installation
          -- If it's a Sail project but Sail isn't running, ask what to do
          if M.has_sail() and not M.is_sail_running() then
            -- Create a buffer for output
            local buffer = vim.api.nvim_create_buf(false, true)
            vim.api.nvim_buf_set_name(buffer, "Laravel IDE Helper Install")
            vim.api.nvim_buf_set_lines(buffer, 0, -1, false, {
              "Installing Laravel IDE Helper...",
              "Working directory: " .. laravel_root,
              "-------------------------------------------",
              "",
            })
            vim.cmd("sbuffer " .. buffer)
            vim.cmd("setlocal buftype=nofile bufhidden=wipe noswapfile ft=log")
            
            M.handle_sail_not_running(
              laravel_root,
              "install",
              buffer,
              function() 
                -- On success with Sail
                M.install_ide_helper_with_command(laravel_root, true, buffer)
              end,
              function() 
                -- On standard composer
                M.install_ide_helper_with_command(laravel_root, false, buffer)
              end,
              function() 
                -- On cancel
                return
              end
            )
          else
            -- No special handling needed, just install
            M.install_ide_helper()
          end
        else
          -- User declined installation, ask if they want to remember this choice
          M.handle_remember_choice(
            laravel_root,
            "ide_helper_install",
            "declined",
            "Would you like to remember this choice for this Laravel project?\n" ..
            "This will prevent future installation prompts.",
            "Preference saved in .nvim-helper. To enable installation prompts again, edit 'ide_helper_install=declined' to 'prompt'."
          )
        end
      elseif not M.ide_helper_files_exist() then
        -- Check if user has declined file generation before
        if M.read_user_preference(laravel_root) and 
           M.read_user_preference(laravel_root)["ide_helper_generate"] == "declined" then
          -- User previously declined, respect their choice
          return
        end
        
        -- IDE Helper is installed but files aren't generated
        local choice = vim.fn.confirm(
          "Generate Laravel IDE Helper files for better LSP integration?", 
          "&Yes\n&No", 
          1
        )
        
        if choice == 1 then
          -- First, if it's a Sail project but Sail isn't running, ask what to do
          if M.has_sail() and not M.is_sail_running() then
            -- Create a buffer for output
            local buffer = vim.api.nvim_create_buf(false, true)
            vim.api.nvim_buf_set_name(buffer, "Laravel IDE Helper Generation")
            vim.api.nvim_buf_set_lines(buffer, 0, -1, false, {
              "Generating Laravel IDE Helper files...",
              "Working directory: " .. laravel_root,
              "-------------------------------------------",
              "",
            })
            vim.cmd("sbuffer " .. buffer)
            vim.cmd("setlocal buftype=nofile bufhidden=wipe noswapfile ft=log")
            
            M.handle_sail_not_running(
              laravel_root,
              "generate",
              buffer,
              function() 
                -- On success with Sail
                M.generate_ide_helper(false, true, buffer)
              end,
              function() 
                -- On standard PHP
                M.generate_ide_helper(false, false, buffer)
              end,
              function() 
                -- On cancel
                return
              end
            )
          else
            -- No special handling needed, just generate
            M.generate_ide_helper(false)
          end
        else
          -- User declined generation, ask if they want to remember this choice
          M.handle_remember_choice(
            laravel_root,
            "ide_helper_generate",
            "declined",
            "Would you like to remember this choice for this Laravel project?\n" ..
            "This will prevent future file generation prompts.",
            "Preference saved in .nvim-helper. To enable generation prompts again, edit 'ide_helper_generate=declined' to 'prompt'."
          )
        end
      end
    end, 1000) -- Delay to avoid disrupting startup
  end
})
end

return M