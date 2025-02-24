-- Claude Code terminal toggle utility
local M = {}

-- Toggle the Claude Code terminal window
function M.toggle_claude_code()
  -- Check if Claude Code is already running
  local claude_bufnr = vim.fn.bufnr("claude-code")
  if claude_bufnr ~= -1 and vim.api.nvim_buf_is_valid(claude_bufnr) then
    -- Check if there's a window displaying Claude Code buffer
    local win_ids = vim.fn.win_findbuf(claude_bufnr)
    if #win_ids > 0 then
      -- Claude Code is visible, close the window
      for _, win_id in ipairs(win_ids) do
        vim.api.nvim_win_close(win_id, true)
      end
    else
      -- Claude Code buffer exists but is not visible, open it in a split
      vim.cmd("botright split")
      vim.cmd("resize " .. math.floor(vim.o.lines * 0.3))
      vim.cmd("buffer " .. claude_bufnr)
      vim.cmd("startinsert")
    end
  else
    -- Claude Code is not running, start it in a new split
    vim.cmd("botright split")
    vim.cmd("resize " .. math.floor(vim.o.lines * 0.3))
    vim.cmd("terminal claude")
    vim.cmd("setlocal bufhidden=hide")
    vim.cmd("file claude-code")
    vim.cmd("setlocal nonumber norelativenumber")
    vim.cmd("setlocal signcolumn=no")
    -- Automatically enter insert mode in terminal
    vim.cmd("startinsert")
  end
end

return M