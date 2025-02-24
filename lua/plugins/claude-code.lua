-- Instead of using a local plugin, we'll just initialize our Claude Code functionality
-- directly from this plugin file

return {
  "claude-integration",
  lazy = false,
  init = function()
    -- Initialize the file change detection system
    require("utils.claude").setup()
  end
}

