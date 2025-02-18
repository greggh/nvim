---@diagnostic disable: missing-fields

if vim.g.tests == false then
  return {}
end

local function count_failed_results(results, tree)
  local failed = 0
  for pos_id, result in pairs(results) do
    if result.status == "failed" and tree:get_key(pos_id) then
      failed = failed + 1
    end
  end
  return failed
end

local function refresh_trouble(failed)
  local trouble = require("trouble")
  if trouble.is_open() then
    trouble.refresh()
    if failed == 0 then
      trouble.close()
    end
  end
end

return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      { "nvim-neotest/nvim-nio" },
      { "nvim-neotest/neotest-plenary" },
      { "nvim-neotest/neotest-jest" },
      { "marilari88/neotest-vitest" },
      { "nvim-neotest/neotest-python" },
      { "fredrikaverpil/neotest-golang" },
      { "V13Axel/neotest-pest" },
      { "rouge8/neotest-rust" },
    },
    -- stylua: ignore
    config = function()
      local neotest_ns = vim.api.nvim_create_namespace("neotest")
      vim.diagnostic.config({
        virtual_text = {
          format = function(diagnostic)
            local message = diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
            return message
          end,
        },
      }, neotest_ns)

      require("neotest").setup({
        adapters = {
          require("neotest-plenary"),
          require("neotest-jest"),
          require("neotest-vitest"),
          require("neotest-python"),
          require("neotest-golang"),
          require("neotest-pest"),
          require("neotest-rust"),
        },
        status = { virtual_text = true },
        output = { open_on_run = false },
        quickfix = {
          open = function()
            require("trouble").open({
              mode = "quickfix",
              auto_preview = false,
              focus = false,
              multiline = false,
            })
          end,
        },
        consumers = {
          trouble = function(client)
            client.listeners.results = function(adapter_id, results, partial)
              if partial then
                return
              end

              local tree = assert(client:get_position(nil, { adapter = adapter_id }))
              local failed = count_failed_results(results, tree)

              vim.schedule(function()
                refresh_trouble(failed)
              end)
            end
            return {}
          end,
        },
      })
    end,
  },
}
