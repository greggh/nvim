if not vim.g.ai then
  return {}
end

local plugins = {}

if vim.g.ai == "copilot" then
  table.insert(plugins, require("plugins.ai.copilot"))
elseif vim.g.suggestions then
  table.insert(plugins, require("plugins.ai.neocodeium"))
end

table.insert(plugins, require("plugins.ai.avante"))
table.insert(plugins, require("plugins.ai.squire"))

return plugins
