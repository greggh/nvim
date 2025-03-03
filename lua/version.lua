---@mod version Version information for Neovim configuration
---@brief [[
--- Defines the semantic version of the Neovim configuration.
--- Used for display and compatibility checking.
---@brief ]]

local M = {
  major = 0,
  minor = 4,
  patch = 1,
}

--- Returns the formatted version string
--- @return string Version string in format "major.minor.patch"
function M.string()
  return string.format("%d.%d.%d", M.major, M.minor, M.patch)
end

--- Prints the current version of the configuration
function M.print_version()
  vim.notify("Neovim config version: " .. M.string(), vim.log.levels.INFO)
end

return M
