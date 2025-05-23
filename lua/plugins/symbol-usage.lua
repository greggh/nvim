local function text_format(symbol)
  local function h(name)
    return vim.api.nvim_get_hl(0, { name = name })
  end

  vim.api.nvim_set_hl(0, "SymbolUsageRounding", { fg = h("CursorLine").bg, italic = true })
  vim.api.nvim_set_hl(0, "SymbolUsageContent", { bg = h("CursorLine").bg, fg = h("Comment").fg, italic = true })
  vim.api.nvim_set_hl(0, "SymbolUsageRef", { fg = h("Function").fg, bg = h("CursorLine").bg, italic = true })
  vim.api.nvim_set_hl(0, "SymbolUsageDef", { fg = h("Type").fg, bg = h("CursorLine").bg, italic = true })
  vim.api.nvim_set_hl(0, "SymbolUsageImpl", { fg = h("@keyword").fg, bg = h("CursorLine").bg, italic = true })

  local res = {}

  local round_start = { "", "SymbolUsageRounding" }
  local round_end = { "", "SymbolUsageRounding" }

  local stacked_functions_content = symbol.stacked_count > 0 and ("+%s"):format(symbol.stacked_count) or ""

  if symbol.references then
    local usage = symbol.references <= 1 and "usage" or "usages"
    local num = symbol.references == 0 and "no" or symbol.references
    table.insert(res, round_start)
    table.insert(res, { "󰌹 ", "SymbolUsageRef" })
    table.insert(res, { ("%s %s"):format(num, usage), "SymbolUsageContent" })
    table.insert(res, round_end)
  end

  if symbol.definition then
    if #res > 0 then
      table.insert(res, { " ", "NonText" })
    end
    table.insert(res, round_start)
    table.insert(res, { "󰳽 ", "SymbolUsageDef" })
    table.insert(res, { symbol.definition .. " defs", "SymbolUsageContent" })
    table.insert(res, round_end)
  end

  if symbol.implementation then
    if #res > 0 then
      table.insert(res, { " ", "NonText" })
    end
    table.insert(res, round_start)
    table.insert(res, { "󰡱 ", "SymbolUsageImpl" })
    table.insert(res, { symbol.implementation .. " impls", "SymbolUsageContent" })
    table.insert(res, round_end)
  end

  if stacked_functions_content ~= "" then
    if #res > 0 then
      table.insert(res, { " ", "NonText" })
    end
    table.insert(res, round_start)
    table.insert(res, { " ", "SymbolUsageImpl" })
    table.insert(res, { stacked_functions_content, "SymbolUsageContent" })
    table.insert(res, round_end)
  end

  return res
end

return {
  "Wansmer/symbol-usage.nvim",
  event = { "LspAttach" },
  config = function()
    ---@diagnostic disable-next-line: missing-fields
    require("symbol-usage").setup({
      text_format = text_format,
      definition = { enabled = false },
      implementation = { enabled = false },
      references = { enabled = true, include_declaration = false },
      vt_position = "end_of_line",
      disable_relative_path = false,
      disable_file_types = vim.g.ignore_filetypes,
      symbols = {
        parameter = { enabled = false },
        class = { enabled = true },
        method = { enabled = true },
        function_declaration = { enabled = true },
        function_expression = { enabled = false },
        field = { enabled = false },
        enum = { enabled = false },
      },
      request_pending_text = "Calculating..",
      get_definition = function(params)
        return vim.lsp.buf.definition(params)
      end,
      get_references = function(params)
        return vim.lsp.buf.references(params)
      end,
      get_implementation = function(params)
        return vim.lsp.buf.implementation(params)
      end,
    })
  end,
}
