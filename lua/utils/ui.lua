local M = {}

M.headers = {
  anonymous = "anonymous.cat",
  eagle = "eagle.cat",
  neovim = "neovim.cat",
  hack = "hack.cat",
}

local function get_header(header)
  return vim.fn.readfile(vim.fn.stdpath("config") .. "/assets/dashboard/" .. header)
end

function M.get_dashboard_header(header)
  return table.concat(get_header(header), "\n")
end

function M.ToggleIDEView()
  local trouble = require("trouble")
  local edgy = require("edgy")

  if vim.g.ide_view_open then
    trouble.close("diagnostics")
    Snacks.explorer.open()
    edgy.close("right")
    vim.g.ide_view_open = false
  else
    for _, client in ipairs(vim.lsp.get_clients()) do
      require("workspace-diagnostics").populate_workspace_diagnostics(client, 0)
    end
    trouble.open("diagnostics")
    Snacks.explorer.open()
    edgy.open("right")
    vim.g.ide_view_open = true
  end
end

-- Toggle fold level for better code navigation
M.toggle_fold_level = function(level)
  if vim.o.foldlevel == level then
    vim.o.foldlevel = 99  -- Open all folds
  else
    vim.o.foldlevel = level
  end
end

-- Maximize current split window
M.maximize_current_split = function()
  local current_winnr = vim.fn.winnr()
  local windows = vim.api.nvim_list_wins()
  
  if #windows <= 1 then return end
  
  -- Store original layout
  if not vim.g.original_win_layout then
    vim.g.original_win_layout = vim.fn.winrestcmd()
    vim.g.maximized_window = true
    vim.cmd("only")
  else
    -- Restore original layout
    vim.cmd(vim.g.original_win_layout)
    vim.g.original_win_layout = nil
    vim.g.maximized_window = false
  end
end

-- UI status feedback using Noice's pretty notifications
M.notify_operation_status = function(operation, status, details)
  local icons = {
    success = " ",
    error = " ",
    info = " ",
    warning = " "
  }
  
  local icon = icons[status] or icons.info
  local title = operation
  local message = details or ""
  
  local level = ({
    success = vim.log.levels.INFO,
    error = vim.log.levels.ERROR,
    info = vim.log.levels.INFO,
    warning = vim.log.levels.WARN
  })[status] or vim.log.levels.INFO
  
  -- Check if Noice is available
  local has_noice, noice = pcall(require, "noice.notify")
  if has_noice then
    noice.notify(message, level, {
      title = icon .. " " .. title,
      replace = true,
      render = "compact",
      timeout = 3000,
      animate = true,
    })
  else
    -- Fallback to regular notification
    vim.notify(icon .. " " .. title .. (message ~= "" and (": " .. message) or ""), level)
  end
end

return M
