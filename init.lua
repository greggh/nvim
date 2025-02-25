-- Track startup time
local startup_time = os.clock()

require("config.flags")
require("config.options")
require("config.lazy")
require("config.keymaps")
require("config.autocmd")

-- Report startup time when NVIM_PROFILE is set
if os.getenv("NVIM_PROFILE") then
  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
      local end_time = os.clock()
      print(string.format("Startup Time: %.2f ms", (end_time - startup_time) * 1000))
    end,
  })
end
