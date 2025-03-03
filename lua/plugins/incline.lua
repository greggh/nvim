return {
  "b0o/incline.nvim",
  event = { "BufReadPre" },
  priority = 1200,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local helpers = require("incline.helpers")
    local devicons = require("nvim-web-devicons")
    require("incline").setup({
      window = {
        padding = 0,
        margin = { horizontal = 0 },
        zindex = 50,
        placement = { horizontal = "right", vertical = "top" },
      },
      hide = {
        cursorline = false,
        focused_win = false,
        only_win = false,
      },
      render = function(props)
        local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
        if filename == "" then
          filename = "[No Name]"
        end
        local ft_icon, ft_color = devicons.get_icon_color(filename)
        local modified = vim.bo[props.buf].modified
        return {
          ft_icon and { " ", ft_icon, " ", guibg = ft_color, guifg = helpers.contrast_color(ft_color) } or "",
          " ",
          { filename, gui = modified and "bold,italic" or "bold" },
          modified and " ● " or " ",
          guibg = "#1e1e2e", -- default: #44406e
        }
      end,
    })
  end,
}
