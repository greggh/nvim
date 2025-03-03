return {
  "uga-rosa/ccc.nvim",
  name = "ccc",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("ccc").setup({
      -- Set a default color to avoid nil errors
      default_color = "#ffffff",

      highlighter = {
        auto_enable = true,
        lsp = true,
        max_line_len = 300,
        max_byte_len = 5000,
        filetypes = {},
        exclude_filetypes = {},
        always_update = false,
      },
      recognize = {
        input = true,
        output = true,
        names = {
          rgb_fn = true,
          rgba_fn = true,
          hsl_fn = true,
          hsla_fn = true,
          hex = true,
          css_fn = true,
          css_var = false,
          tailwind = {
            enable = false,
            pattern = "^tw%-[%w-_:]*", -- e.g. "tw-xxx:xxxx"
            attr = "class",
          },
        },
      },
      inputs = {
        -- Using all available input modules
        require("ccc.input.rgb"),
        require("ccc.input.hsl"),
        require("ccc.input.hsv"),
        require("ccc.input.hwb"),
        require("ccc.input.lab"),
        require("ccc.input.lch"),
        require("ccc.input.cmyk"),
        require("ccc.input.hsluv"),
        require("ccc.input.okhsl"),
        require("ccc.input.okhsv"),
        require("ccc.input.oklab"),
        require("ccc.input.oklch"),
        require("ccc.input.xyz"),
      },
      outputs = {
        -- Using all available output modules
        require("ccc.output.hex"),
        require("ccc.output.hex_short"),
        require("ccc.output.css_rgb"),
        require("ccc.output.css_rgba"),
        require("ccc.output.css_hsl"),
        require("ccc.output.css_hwb"),
        require("ccc.output.css_lab"),
        require("ccc.output.css_lch"),
        require("ccc.output.css_oklab"),
        require("ccc.output.css_oklch"),
        require("ccc.output.float"),
      },
      convert = {
        { input = { "rgb" }, output = { "hex", "hsl", "hsv" } },
        { input = { "hsl" }, output = { "rgb", "hex", "hsv" } },
        { input = { "hsv" }, output = { "rgb", "hex", "hsl" } },
        { input = { "cmyk" }, output = { "rgb", "hex" } },
        { input = { "hwb" }, output = { "rgb", "hex" } },
        { input = { "lab" }, output = { "xyz", "rgb", "hex" } },
        { input = { "lch" }, output = { "lab", "rgb", "hex" } },
        { input = { "xyz" }, output = { "lab", "rgb", "hex" } },
        { input = { "oklab" }, output = { "rgb", "hex" } },
        { input = { "oklch" }, output = { "oklab", "rgb", "hex" } },
      },
      highlight = {
        enable = true,
        duration = 100,
      },
      picker = {
        use_picker = true,
      },
    })
  end,
}
