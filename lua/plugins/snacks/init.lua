return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  import = "plugins.snacks",
  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        _G.dd = function(...)
          Snacks.debug.inspect(...)
        end
        _G.bt = function()
          Snacks.debug.backtrace()
        end
        vim.print = _G.dd

        Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>os")
        Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>ow")
        Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>oL")
        Snacks.toggle.diagnostics():map("<leader>od")
        Snacks.toggle.line_number():map("<leader>ol")
        Snacks.toggle
          .option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
          :map("<leader>oc")
        Snacks.toggle.treesitter():map("<leader>oT")
        Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ob")
        Snacks.toggle.inlay_hints():map("<leader>oh")
        Snacks.toggle.indent():map("<leader>og")
        Snacks.toggle.dim():map("<leader>oD")
      end,
    })
  end,
}
