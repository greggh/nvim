return {
  "Bekaboo/dropbar.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("dropbar").setup({
      icons = {
        kinds = {
          -- Fix: Use string value instead of table for file_icon and folder_icon
          File = "󰈙",
          Module = "",
          Namespace = "󰅪",
          Package = "",
          Class = "󰆧",
          Method = "󰊕",
          Property = "",
          Field = "",
          Constructor = "",
          Enum = "",
          Interface = "",
          Function = "",
          Variable = "󰫧",
          Constant = "󰏿",
          String = "",
          Number = "󰎠",
          Boolean = "󰨙",
          Array = "󱡠",
          Object = "",
          Key = "󰌆",
          Null = "󰟢",
          EnumMember = "",
          Struct = "󰆼",
          Event = "",
          Operator = "󰆕",
          TypeParameter = "󰆩",
        },
        -- Add these options at the same level as kinds
        file_icon = {
          enable = true,
        },
        folder_icon = {
          enable = true,
        },
      },
      bar = {
        hover = true,
        pick = {
          pivots = "abcdefghijklmnopqrstuvwxyz",
        },
      },
      menu = {
        -- When on, automatically update the menu content when the drop bar is updated.
        quick_navigation = true,
        entry = {
          padding = { left = 1, right = 1 },
        },
        win_configs = {
          border = "rounded",
          col = function(menu)
            return menu.prev_menu and menu.prev_menu._win_configs.width + menu.prev_menu._win_configs.col
              or menu.source.relative_col
          end,
        },
      },
    })
    -- Keymaps are defined in lua/config/keymaps.lua
  end,
}
