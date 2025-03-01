return {
  "nvim-dap",
  opts = function()
    local dap = require("dap")
    -- We don't need utils.debugger here
    local git = require("utils.git")
    local debug_adapter_path = vim.env.MASON .. "/packages/php-debug-adapter/vscode-php-debug/out/phpDebug.js"
    local cwd = vim.fs.root(0, { "composer.json", "index.php" }) or git.get_git_root() or "${workspaceFolder}"

    -- Detect Laravel project with Sail
    local is_laravel = vim.fn.filereadable(cwd .. "/artisan") == 1
    local is_sail = is_laravel
      and vim.fn.filereadable(cwd .. "/docker-compose.yml") == 1
      and vim.fn.filereadable(cwd .. "/vendor/bin/sail") == 1

    dap.adapters.php = {
      type = "executable",
      command = vim.fn.exepath("node"),
      args = { debug_adapter_path },
    }

    -- Default configurations
    local php_configurations = {
      {
        name = "Listen for Xdebug",
        type = "php",
        request = "launch",
        port = 9003,
        stopOnEntry = false,
        pathMappings = {
          ["/var/www/html"] = cwd, -- Adjust for Docker/remote environments
        },
      },
      {
        name = "Debug current script",
        type = "php",
        request = "launch",
        port = 9003,
        cwd = cwd,
        program = "${file}",
        stopOnEntry = false,
        pathMappings = {
          ["/var/www/html"] = cwd, -- Adjust for Docker/remote environments
        },
      },
      {
        name = "Debug with custom config",
        type = "php",
        request = "launch",
        port = function()
          local co = coroutine.running()
          return coroutine.create(function()
            vim.ui.input({
              prompt = "Enter port: ",
              default = "9003",
            }, function(port)
              if port == nil or port == "" then
                port = "9003"
              end
              coroutine.resume(co, tonumber(port))
            end)
          end)
        end,
        pathMappings = function()
          local co = coroutine.running()
          return coroutine.create(function()
            vim.ui.input({
              prompt = "Remote path: ",
              default = "/var/www/html",
            }, function(remote_path)
              if remote_path == nil or remote_path == "" then
                remote_path = "/var/www/html"
              end
              local path_mappings = {}
              path_mappings[remote_path] = cwd
              coroutine.resume(co, path_mappings)
            end)
          end)
        end,
        hostname = "localhost",
        stopOnEntry = false,
      },
    }

    -- Add Laravel Sail specific configurations if detected
    if is_laravel then
      if is_sail then
        -- Laravel Sail configuration
        table.insert(php_configurations, 1, {
          name = "Debug Laravel (Sail)",
          type = "php",
          request = "launch",
          port = 9003,
          pathMappings = {
            ["/var/www/html"] = cwd, -- Default Docker path for Laravel Sail
          },
          hostname = "0.0.0.0", -- Listen on all interfaces
          stopOnEntry = false,
          serverSourceRoot = "/var/www/html",
          localSourceRoot = cwd,
          ignore = {
            -- Ignore vendor and node_modules when stepping through code
            "**/vendor/**/*.php",
            "**/node_modules/**/*.php",
          },
        })

        -- Add instructions for Sail setup
        vim.api.nvim_create_autocmd("FileType", {
          pattern = "php",
          callback = function()
            if is_sail and not vim.g.sail_debug_info_shown then
              vim.defer_fn(function()
                vim.notify(
                  "Laravel Sail detected. To enable Xdebug, run:\n"
                    .. "./vendor/bin/sail build --no-cache\n"
                    .. "Add this to your .env file:\n"
                    .. "SAIL_XDEBUG_MODE=develop,debug\n"
                    .. 'SAIL_XDEBUG_CONFIG="client_host=host.docker.internal discover_client_host=true log_level=0"',
                  vim.log.levels.INFO,
                  { title = "PHP Debug Setup", timeout = 10000 }
                )
              end, 1000)
              vim.g.sail_debug_info_shown = true
            end
          end,
        })

        -- Add Laravel Artisan debug command via Sail
        table.insert(php_configurations, {
          name = "Debug Artisan Command (Sail)",
          type = "php",
          request = "launch",
          port = 9003,
          pathMappings = {
            ["/var/www/html"] = cwd,
          },
          preLaunchTask = function()
            local co = coroutine.running()
            return coroutine.create(function()
              vim.ui.input({
                prompt = "Artisan command: ",
                default = "route:list",
              }, function(command)
                if command and command ~= "" then
                  -- Execute the sail artisan command with xdebug enabled
                  local job_id = vim.fn.jobstart(
                    "cd " .. cwd .. " && XDEBUG_SESSION=1 ./vendor/bin/sail artisan " .. command,
                    { detach = true }
                  )
                  if job_id <= 0 then
                    vim.notify("Failed to start artisan command", vim.log.levels.ERROR)
                  else
                    vim.notify("Launched artisan " .. command .. " with Xdebug enabled", vim.log.levels.INFO)
                  end
                  coroutine.resume(co, nil)
                else
                  coroutine.resume(co, dap.ABORT)
                end
              end)
            end)
          end,
          hostname = "0.0.0.0",
          stopOnEntry = false,
        })
      else
        -- Regular Laravel configuration (without Sail)
        table.insert(php_configurations, 1, {
          name = "Debug Laravel (Standard)",
          type = "php",
          request = "launch",
          port = 9003,
          cwd = cwd,
          program = "${workspaceFolder}/artisan",
          stopOnEntry = false,
          pathMappings = {
            [cwd] = cwd, -- Direct mapping for non-containerized Laravel
          },
          ignore = {
            -- Ignore vendor and node_modules when stepping through code
            "**/vendor/**/*.php",
            "**/node_modules/**/*.php",
          },
        })
      end

      -- Add Artisan command debug configuration
      table.insert(php_configurations, {
        name = "Debug Artisan Command",
        type = "php",
        request = "launch",
        port = 9003,
        cwd = cwd,
        program = function()
          local co = coroutine.running()
          return coroutine.create(function()
            vim.ui.input({
              prompt = "Artisan command: ",
              default = "route:list",
            }, function(command)
              if command and command ~= "" then
                coroutine.resume(co, cwd .. "/artisan " .. command)
              else
                coroutine.resume(co, dap.ABORT)
              end
            end)
          end)
        end,
        stopOnEntry = false,
      })
    end

    dap.configurations.php = php_configurations
  end,
}
