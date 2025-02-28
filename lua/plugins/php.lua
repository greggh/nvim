-- Laravel-specific PHP configuration
return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    event = { "BufReadPre", "BufNewFile" },
    ft = { "php" },
  },

  -- Laravel Helper Plugin (extracted from utils/php.lua)
  {
    "greggh/laravel-helper.nvim", -- Use GitHub name for release
    -- Use a local path override during development
    dir = vim.fn.expand("~/Projects/neovim/plugins/laravel-helper"),
    dependencies = {
      "MunifTanjim/nui.nvim", -- Required for floating windows in IDE Helper
    },
    ft = { "php" },
    config = function()
      -- Set up key mappings for PHP-specific commands
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "php",
        callback = function()
          local ok, laravel_helper = pcall(require, "laravel-helper")
          if not ok then
            vim.notify("Failed to load Laravel Helper plugin", vim.log.levels.ERROR)
            return
          end

          -- Only set up mappings in Laravel projects
          if laravel_helper.is_laravel_project() then
            local opts = { buffer = 0, silent = true }

            -- Generate IDE Helper files
            vim.keymap.set("n", "<leader>lph", function()
              laravel_helper.generate_ide_helper(true)
            end, vim.tbl_extend("force", opts, { desc = "Generate Laravel IDE Helper files" }))

            -- Install IDE Helper if not already installed
            vim.keymap.set("n", "<leader>lpi", function()
              laravel_helper.install_ide_helper()
            end, vim.tbl_extend("force", opts, { desc = "Install Laravel IDE Helper" }))

            -- Toggle debug mode for Laravel IDE Helper
            vim.keymap.set("n", "<leader>lpd", function()
              laravel_helper.toggle_debug_mode()
            end, vim.tbl_extend("force", opts, { desc = "Toggle Laravel IDE Helper debug mode" }))

            -- Run Artisan commands
            vim.keymap.set("n", "<leader>lpa", function()
              laravel_helper.run_artisan_command()
            end, vim.tbl_extend("force", opts, { desc = "Run Laravel Artisan command" }))

            -- Register keymappings with which-key if available
            local ok_wk, wk = pcall(require, "which-key")
            if ok_wk then
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
  },
}

