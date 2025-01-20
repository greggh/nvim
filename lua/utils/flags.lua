local M = {}

local default_flags = {}
local show_icons = false
local path = vim.fn.stdpath("data") .. "/flags"

local function read_flags(file)
  local flags = {}
  local f, err = io.open(file, "r")
  if not f then
    vim.notify("Error opening file: " .. err, vim.log.levels.ERROR)
    return flags
  end
  for line in f:lines() do
    for k, v in string.gmatch(line, "(%w+)%s*=%s*(%w+)") do
      flags[k] = v == "true"
    end
  end
  f:close()
  return flags
end

local function write_flags(file, flags)
  local f, err = io.open(file, "w")
  if not f then
    vim.notify("Error opening file: " .. err, vim.log.levels.ERROR)
    return
  end
  for k, v in pairs(flags) do
    f:write(string.format("%s = %s\n", k, tostring(v)))
  end
  f:close()
end

function M.get_flags(flag_to_check)
  local flags = vim.fn.filereadable(path) == 1 and read_flags(path) or {}

  if flags[flag_to_check] == nil then
    flags[flag_to_check] = default_flags[flag_to_check] or false
    write_flags(path, flags)
  end

  return flags[flag_to_check]
end

local function set_flags(flag, value)
  local flags = vim.fn.filereadable(path) == 1 and read_flags(path) or {}
  flags[flag] = value
  write_flags(path, flags)
end

local function get_all_flags()
  local flags = vim.fn.filereadable(path) == 1 and read_flags(path) or {}

  for k, v in pairs(default_flags) do
    if flags[k] == nil then
      flags[k] = v
    end
  end

  return flags
end

local function toggle_flags_ui()
  local all_flags = get_all_flags()
  local items = {}

  for flag, value in pairs(all_flags) do
    local icon = value and " " or " "
    local label = show_icons and (icon .. " " .. flag) or (flag .. " (" .. (value and "enabled" or "disabled") .. ")")
    table.insert(items, {
      label = label,
      flag = flag,
      value = value,
    })
  end

  vim.ui.select(items, {
    prompt = "Select a flag to toggle:",
    format_item = function(item)
      return item.label
    end,
  }, function(choice)
    if choice then
      set_flags(choice.flag, not choice.value)
      vim.notify(choice.flag .. " " .. (not choice.value and "enabled" or "disabled"), vim.log.levels.INFO)
      toggle_flags_ui()
    end
  end)
end

local function generate_flags_fn()
  vim.api.nvim_create_user_command("Flags", function()
    toggle_flags_ui()
  end, {})
end

function M.setup(opts)
  default_flags = opts.flags or {}
  path = opts.path or path
  show_icons = opts.icons or false
  if opts.keys then
    for _, key in ipairs(opts.keys) do
      vim.api.nvim_set_keymap(key.mode, key.lhs, key.rhs, key.opts or {})
    end
  end
  generate_flags_fn()
end

return M
