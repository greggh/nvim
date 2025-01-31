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

return M
