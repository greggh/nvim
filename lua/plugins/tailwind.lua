return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Add tailwindcss LSP configuration
        tailwindcss = {
          -- Default settings
          root_dir = function(fname)
            -- Check for tailwind.config.js or tailwind.config.ts
            return require("lspconfig.util").root_pattern("tailwind.config.js", "tailwind.config.ts")(fname)
          end,
        },
      },
    },
  },
  {
    -- Optional plugin for tailwind color preview
    "roobert/tailwindcss-colorizer-cmp.nvim",
    -- Explicitly load after blink.cmp is loaded
    dependencies = { "saghen/blink.cmp" },
    cond = function()
      -- Only load if blink.cmp is available
      return pcall(require, "blink.cmp")
    end,
    ft = {
      "html",
      "javascript",
      "typescript",
      "javascriptreact",
      "typescriptreact",
      "svelte",
      "vue",
      "astro",
      "php",
      "blade",
    },
    config = function()
      require("tailwindcss-colorizer-cmp").setup({
        color_square_width = 2,
      })
    end,
  },
}
