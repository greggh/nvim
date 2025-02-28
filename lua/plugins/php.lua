return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
  },
  event = { "BufReadPre", "BufNewFile" },
  ft = { "php" },
  config = function()
    local php_utils = require("utils.php")
    
    -- Run Laravel IDE Helper setup
    php_utils.setup_auto_ide_helper()
    
    -- Set up key mappings for PHP-specific commands
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "php",
      callback = function()
        -- Only set up mappings in Laravel projects
        if php_utils.is_laravel_project() then
          local opts = { buffer = 0, silent = true }
          
          -- Generate IDE Helper files
          vim.keymap.set("n", "<leader>lph", function()
            php_utils.generate_ide_helper(true)
          end, vim.tbl_extend("force", opts, { desc = "Generate Laravel IDE Helper files" }))
          
          -- Install IDE Helper if not already installed
          vim.keymap.set("n", "<leader>lpi", function()
            php_utils.install_ide_helper()
          end, vim.tbl_extend("force", opts, { desc = "Install Laravel IDE Helper" }))
          
          -- Toggle debug mode for Laravel IDE Helper
          vim.keymap.set("n", "<leader>lpd", function()
            php_utils.toggle_debug_mode()
          end, vim.tbl_extend("force", opts, { desc = "Toggle Laravel IDE Helper debug mode" }))
          
          -- Run Artisan commands
          vim.keymap.set("n", "<leader>lpa", function()
            vim.ui.input({
              prompt = "Artisan command: ",
              default = "route:list",
            }, function(input)
              if input and input ~= "" then
                local cmd = php_utils.has_sail() 
                  and ("./vendor/bin/sail artisan " .. input)
                  or ("php artisan " .. input)
                  
                local job_id = vim.fn.jobstart(cmd, {
                  cwd = vim.fn.getcwd(),
                  on_exit = function(_, code)
                    if code == 0 then
                      vim.notify("Artisan command completed successfully", 
                                vim.log.levels.INFO, { title = "Laravel Artisan" })
                    end
                  end,
                  stdout_buffered = true,
                  on_stdout = function(_, data)
                    if data and #data > 0 then
                      vim.schedule(function()
                        -- Create or get the output buffer
                        local bufnr = vim.fn.bufnr("Laravel Artisan Output")
                        if bufnr == -1 then
                          bufnr = vim.api.nvim_create_buf(false, true)
                          vim.api.nvim_buf_set_name(bufnr, "Laravel Artisan Output")
                        end
                        
                        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, data)
                        vim.api.nvim_command("sbuffer " .. bufnr)
                        vim.api.nvim_command("setlocal buftype=nofile")
                        vim.api.nvim_command("setlocal bufhidden=wipe")
                        vim.api.nvim_command("setlocal noswapfile")
                      end)
                    end
                  end
                })
                
                if job_id <= 0 then
                  vim.notify("Failed to run artisan command", vim.log.levels.ERROR, { title = "Laravel Artisan" })
                else
                  vim.notify("Running: " .. cmd, vim.log.levels.INFO, { title = "Laravel Artisan" })
                end
              end
            end)
          end, vim.tbl_extend("force", opts, { desc = "Run Laravel Artisan command" }))
          
          -- Register keymappings with which-key if available
          local ok, wk = pcall(require, "which-key")
          if ok then
            wk.register({
              ["<leader>lp"] = { name = "Laravel PHP" },
              ["<leader>lph"] = { desc = "Generate IDE Helper", icon = "𝓗" },
              ["<leader>lpi"] = { desc = "Install IDE Helper", icon = "𝓘" },
              ["<leader>lpd"] = { desc = "Toggle Debug Mode", icon = "𝓓" },
              ["<leader>lpa"] = { desc = "Artisan Command", icon = "𝓐" },
            }, { mode = "n" })
          end
        end
      end,
    })
  end,
}