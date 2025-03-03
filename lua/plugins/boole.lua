return {
  "nat-418/boole.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    ---@diagnostic disable-next-line: missing-fields
    require("boole").setup({
      mappings = {}, -- mappings are defined in keymaps.lua
      -- User defined loops
      additions = {
        { "true", "false" },
        { "yes", "no" },
        { "on", "off" },
        { "enable", "disable" },
        { "enabled", "disabled" },
        { "success", "error" },
        { "open", "close" },
        { "show", "hide" },
        { "visible", "hidden" },
        { "before", "after" },
        { "from", "to" },
        { "in", "out" },
        { "up", "down" },
        { "left", "right" },
        { "first", "last" },
      },
      allow_caps_additions = {
        { "enable", "disable" },
        { "true", "false" },
        { "yes", "no" },
        { "on", "off" },
        -- enable → disable
        -- Enable → Disable
        -- ENABLE → DISABLE
      },
    })
  end,
}
