return {
  "hedyhli/outline.nvim",
  lazy = true,
  cmd = { "Outline", "OutlineOpen" },
  opts = {
    outline_window = {
      auto_close = true,
    },
    symbol_folding = {
      autofold_depth = 1, -- 1 or false
      auto_unfold = {
        hovered = true,
      },
    },
    symbols = {
      icons = {
        Array = { icon = "󰅪", hl = "Constant" },
        Boolean = { icon = "", hl = "Boolean" },
        Class = { icon = "", hl = "Type" },
        Component = { icon = "󰅴", hl = "Function" },
        Constant = { icon = "", hl = "Constant" },
        Constructor = { icon = "", hl = "Special" },
        Enum = { icon = "", hl = "Type" },
        EnumMember = { icon = "", hl = "Identifier" },
        Event = { icon = "🗲", hl = "Type" },
        Field = { icon = "󰆨", hl = "Identifier" },
        File = { icon = "󰈔", hl = "Identifier" },
        Fragment = { icon = "󰅴", hl = "Constant" },
        Function = { icon = "󰡱", hl = "Function" },
        Interface = { icon = "", hl = "Type" },
        Key = { icon = "󰌋", hl = "Type" },
        Macro = { icon = " ", hl = "Function" },
        Method = { icon = "", hl = "Function" },
        Module = { icon = "󰆧", hl = "Include" },
        Namespace = { icon = "󰌗", hl = "Include" },
        Null = { icon = "NULL", hl = "Type" },
        Number = { icon = "#", hl = "Number" },
        Object = { icon = "", hl = "Type" },
        Operator = { icon = "󰆕", hl = "Identifier" },
        Package = { icon = "", hl = "Include" },
        Parameter = { icon = " ", hl = "Identifier" },
        Property = { icon = "", hl = "Identifier" },
        StaticMethod = { icon = " ", hl = "Function" },
        String = { icon = "", hl = "String" },
        Struct = { icon = "", hl = "Structure" },
        TypeAlias = { icon = " ", hl = "Type" },
        TypeParameter = { icon = "󰊄", hl = "Identifier" },
        Variable = { icon = "󰫧", hl = "Constant" },
      },
    },
  },
  config = function(_, opts)
    require("outline").setup(opts)
  end,
}
