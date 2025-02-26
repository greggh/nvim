---@module "Snacks"
return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  import = "plugins.snacks",
  opts = {
    -- Memory optimization settings
    memory = {
      -- Limit memory usage for snacks modules
      limit = 1024 * 1024 * 50, -- 50MB limit
      check_interval = 5000, -- Check every 5 seconds
      gc_threshold = 0.8, -- Trigger GC at 80% of limit
    },
    -- Improve performance by optimizing cache settings
    cache = {
      enabled = true,
      ttl = 600, -- 10 minutes cache TTL
      size = 100, -- Maximum cache entries
    },
    styles = {
      zen = {
        enter = true,
        fixbuf = false,
        minimal = false,
        width = 120,
        height = 0,
        backdrop = { transparent = true, blend = 20 },
        keys = { q = false },
        zindex = 40,
        wo = {
          winhighlight = "NormalFloat:Normal",
        },
        w = {
          snacks_main = true,
        },
      },
    },
  },
  init = function()
    -- Set up essential debug utilities immediately
    ---@diagnostic disable-next-line: duplicate-set-field
    _G.dd = function(...)
      if Snacks and Snacks.debug then
        Snacks.debug.inspect(...)
      else
        vim.print(...)
      end
    end

    ---@diagnostic disable-next-line: duplicate-set-field
    _G.bt = function()
      if Snacks and Snacks.debug then
        Snacks.debug.backtrace()
      else
        vim.print(debug.traceback())
      end
    end

    -- Defer the rest of initialization to VeryLazy event
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        -- Set up debug utilities
        vim.print = _G.dd

        -- Defer toggle mapping setup to improve startup time
        vim.defer_fn(function()
          -- Create a batch of toggle registrations for better performance
          local toggles = {
            { option = "spell", opts = { name = "Spelling" }, key = "<leader>os" },
            { option = "wrap", opts = { name = "Wrap" }, key = "<leader>ow" },
            { option = "relativenumber", opts = { name = "Relative Number" }, key = "<leader>oL" },
            { type = "diagnostics", key = "<leader>od" },
            { type = "line_number", key = "<leader>ol" },
            {
              option = "conceallevel",
              opts = { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 },
              key = "<leader>oc",
            },
            { type = "treesitter", key = "<leader>oT" },
            {
              option = "background",
              opts = { off = "light", on = "dark", name = "Dark Background" },
              key = "<leader>ob",
            },
            { type = "inlay_hints", key = "<leader>oh" },
            { type = "indent", key = "<leader>og" },
            { type = "dim", key = "<leader>oD" },
          }

          -- Register toggles in batches with small pauses to avoid UI freezes
          for i, toggle in ipairs(toggles) do
            if toggle.option then
              Snacks.toggle.option(toggle.option, toggle.opts):map(toggle.key)
            else
              Snacks.toggle[toggle.type]():map(toggle.key)
            end

            -- Add small pauses every few toggles
            if i % 4 == 0 and i < #toggles then
              vim.defer_fn(function() end, 1)
            end
          end
        end, 50) -- Small delay for toggle registration to allow other init to complete
      end,
    })
  end,
}
