-- https://github.com/stevearc/conform.nvim?tab=readme-ov-file#formatters | :h conform-formatters
return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("conform").setup({
      formatters_by_ft = {
        css = { "prettier" },
        go = { "gofmt", "goimports", stop_after_first = false },
        html = { "prettier" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        json = { "prettier" },
        lua = { "stylua" },
        markdown = { "prettier" },
        php = { "php_cs_fixer" }, -- Requires installing php-cs-fixer via composer
        python = { "ruff" },
        scss = { "prettier" },
        sh = { "shfmt" },
        sql = { "sql_formatter" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        yaml = { "prettier" },
        ["*"] = { "trim_whitespace" },
      },
      default_format_opts = {
        lsp_format = "fallback",
        stop_after_first = true,
        quiet = true,
      },
      format_on_save = {
        lsp_format = "fallback",
        timeout_ms = 500,
      },
      notify_on_error = true,
      log_level = vim.log.levels.ERROR,
      formatters = {
        shfmt = {
          prepend_args = { "-i", "2", "-ci" }, -- Use 2 spaces for indentation and indent switch cases
        },
        stylua = {
          prepend_args = { "--indent-type", "Spaces", "--indent-width", "2" },
        },
        prettier = {
          env = {
            PRETTIERD_DEFAULT_CONFIG = vim.fn.expand("~/.config/nvim/.prettierrc.json"),
          },
        },
      },
    })
  end,
}
