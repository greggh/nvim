-- Claude Code Plugin
-- A plugin for integrating Claude Code AI assistant with Neovim

local M = {}

function M.setup(opts)
  -- Initialize the auto-refresh functionality for files modified by Claude
  require("utils.claude").setup()
end

return M