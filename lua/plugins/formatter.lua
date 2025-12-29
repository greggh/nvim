-- https://github.com/stevearc/conform.nvim?tab=readme-ov-file#formatters | :h conform-formatters
vim.api.nvim_create_user_command("Format", function(args)
  local range = nil
  if args.count ~= -1 then
    local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
    range = {
      start = { args.line1, 0 },
      ["end"] = { args.line2, end_line:len() },
    }
  end
  require("conform").format({ async = true, lsp_format = "fallback", range = range })
end, { range = true })

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
