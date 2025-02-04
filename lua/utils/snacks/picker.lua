local M = {}

local snacks = require("snacks")

M.status = {
  is_grep = nil,
  is_git = nil,
}

function M.switch_grep_files(picker, _)
  local cwd = picker.input.filter.cwd

  picker:close()

  if M.status.is_grep then
    local pattern = picker.input.filter.search or picker.input.filter.pattern
    if M.status.is_git then
      ---@diagnostic disable-next-line: missing-fields
      snacks.picker.git_files({ cwd = cwd, pattern = pattern })
    else
      ---@diagnostic disable-next-line: missing-fields
      snacks.picker.files({ cwd = cwd, pattern = pattern })
    end
    M.status = {
      is_grep = false,
      is_git = M.status.is_git,
    }
    return
  else
    local pattern = picker.input.filter.pattern or picker.input.filter.search
    ---@diagnostic disable-next-line: missing-fields
    snacks.picker.grep({ cwd = cwd, search = pattern })
    M.status = {
      is_grep = true,
      is_git = M.status.is_git,
    }
  end
end

return M
