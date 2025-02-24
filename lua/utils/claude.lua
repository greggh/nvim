-- Claude Code terminal toggle utility
local M = {}

-- Setup autocommands for file change detection
function M.setup()
  local augroup = vim.api.nvim_create_augroup("ClaudeCodeFileRefresh", { clear = true })
  
  -- Create an autocommand that checks for file changes more frequently
  vim.api.nvim_create_autocmd({ 
    "CursorHold", "CursorHoldI", "FocusGained", "BufEnter", 
    "InsertLeave", "TextChanged", "TermLeave", "TermEnter", "BufWinEnter"
  }, {
    group = augroup,
    pattern = "*",
    callback = function()
      if vim.fn.filereadable(vim.fn.expand("%")) == 1 then
        vim.cmd("checktime")
      end
    end,
    desc = "Check for file changes on disk",
  })

  -- Create a timer to check for file changes periodically (every 1 second)
  local timer = vim.loop.new_timer()
  if timer then
    timer:start(0, 1000, vim.schedule_wrap(function()
      -- Only check time if there's an active Claude Code terminal
      local claude_bufnr = vim.fn.bufnr("claude-code")
      if claude_bufnr ~= -1 and vim.api.nvim_buf_is_valid(claude_bufnr) and 
         #vim.fn.win_findbuf(claude_bufnr) > 0 then
        vim.cmd("silent! checktime")
      end
    end))
  end
  
  -- Create an autocommand that prompts the user when a file has been changed externally
  vim.api.nvim_create_autocmd("FileChangedShellPost", {
    group = augroup,
    pattern = "*",
    callback = function()
      vim.notify("File changed on disk. Buffer reloaded.", vim.log.levels.INFO)
    end,
    desc = "Notify when a file is changed externally",
  })
  
  -- Set a shorter updatetime while Claude Code is open
  local saved_updatetime = vim.o.updatetime
  
  -- When Claude Code opens, set a shorter updatetime
  vim.api.nvim_create_autocmd("TermOpen", {
    group = augroup,
    pattern = "*",
    callback = function()
      local buf = vim.api.nvim_get_current_buf()
      local buf_name = vim.api.nvim_buf_get_name(buf)
      if buf_name:match("claude%-code$") then
        saved_updatetime = vim.o.updatetime
        vim.o.updatetime = 100  -- 100ms for faster checks
      end
    end,
    desc = "Set shorter updatetime when Claude Code is open",
  })
  
  -- When Claude Code closes, restore normal updatetime
  vim.api.nvim_create_autocmd("TermClose", {
    group = augroup,
    pattern = "*",
    callback = function()
      local buf_name = vim.api.nvim_buf_get_name(0)
      if buf_name:match("claude%-code$") then
        vim.o.updatetime = saved_updatetime
      end
    end,
    desc = "Restore normal updatetime when Claude Code is closed",
  })
end

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