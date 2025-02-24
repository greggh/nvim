return {
  "local/claude-code",
  lazy = false,
  config = function()
    -- Setup function for claude-code plugin
    -- Initialize the file change detection system
    require("utils.claude").setup()
  end,
}

