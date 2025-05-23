local autosave_group = vim.api.nvim_create_augroup("autosave", {})

local setup_autosave_autocmds = function()
  vim.api.nvim_create_autocmd("User", {
    pattern = "AutoSaveEnable",
    group = autosave_group,
    callback = function(_)
      vim.notify("AutoSave enabled", vim.log.levels.INFO)
    end,
  })

  vim.api.nvim_create_autocmd("User", {
    pattern = "AutoSaveDisable",
    group = autosave_group,
    callback = function(_)
      vim.notify("AutoSave disabled", vim.log.levels.INFO)
    end,
  })
end

return {
  "okuuva/auto-save.nvim",
  lazy = false,
  config = function()
    require("auto-save").setup({
      enabled = true, -- start auto-save when the plugin is loaded
      trigger_events = { -- See :h events
        immediate_save = { "BufLeave", "FocusLost" }, -- events for immediate save
        defer_save = { "InsertLeave", "TextChanged" }, -- events for deferred save
        cancel_deferred_save = { "InsertEnter" }, -- events that cancel deferred save
      },
      condition = function(buf)
        local bufVar = function(type)
          return vim.fn.getbufvar(buf, type)
        end

        -- don't save for special-buffers
        if bufVar("&buftype") ~= "" then
          return false
        end

        -- don't save for EXCLUDED_FILETYPES
        if vim.list_contains(vim.g.ignore_filetypes, bufVar("&filetype")) then
          return false
        end

        return true
      end,
      write_all_buffers = false, -- write all buffers when the current one meets `condition`
      noautocmd = false, -- do not execute autocmds when saving
      lockmarks = false, -- lock marks when saving, see `:h lockmarks` for more details
      debounce_delay = 1000, -- delay after which a pending save is executed
      -- log debug messages to 'auto-save.log' file in neovim cache directory, set to `true` to enable
      debug = false,

      vim.api.nvim_create_autocmd("VimEnter", {
        callback = setup_autosave_autocmds,
      }),

      vim.api.nvim_create_autocmd("User", {
        pattern = "AutoSaveWritePost",
        group = autosave_group,
        callback = function(opts)
          if opts.data.saved_buffer ~= nil then
            print("󰄳 auto-save: saved at " .. vim.fn.strftime("%H:%M:%S"))
          end
        end,
      }),
    })
  end,
}
