return {
  "nvim-treesitter/nvim-treesitter",
  dependencies = {
    "windwp/nvim-ts-autotag",
    "nvim-treesitter/nvim-treesitter-context",
    "nvim-treesitter/nvim-treesitter-textobjects",
  },
  event = { "BufReadPre", "BufNewFile" },
  build = ":TSUpdate",
  config = function()
    local treesitter = require("nvim-treesitter.configs")
    local autotag = require("nvim-ts-autotag")
    local context = require("treesitter-context")

    ---@diagnostic disable-next-line: missing-fields
    treesitter.setup({
      auto_install = true,
      ensure_installed = {
        "regex", "diff", "python", "toml", "json", "rst", 
        "ninja", "markdown", "markdown_inline",
        -- Add parsers for web development
        "javascript", "typescript", "tsx", "html", "css",
        -- Add Lua since you're writing Neovim config
        "lua", "vim", "vimdoc",
        -- Add bash for shell scripting
        "bash"
      },
      highlight = { 
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      indent = { enable = true },
      incremental_selection = { 
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = "<nop>",
          node_decremental = "<bs>",
        },
      },
      textobjects = {
        enable = true,
        select = {
          enable = true,
          lookahead = true, -- Automatically jump forward to textobj
          keymaps = {
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
            ["aa"] = "@parameter.outer",
            ["ia"] = "@parameter.inner",
          },
        },
        move = {
          enable = true,
          set_jumps = true, -- Track jumps in jumplist
          goto_next_start = {
            ["]f"] = "@function.outer",
            ["]c"] = "@class.outer",
            ["]a"] = "@parameter.outer",
          },
          goto_previous_start = {
            ["[f"] = "@function.outer",
            ["[c"] = "@class.outer",
            ["[a"] = "@parameter.outer",
          },
        },
      },
    })

    ---@diagnostic disable-next-line: missing-fields
    autotag.setup({
      opts = {
        enable_close = true, -- Auto close tags
        enable_rename = true, -- Auto rename pairs of tags
        enable_close_on_slash = false, -- Auto close on trailing </
      },
    })

    context.setup({
      enable = true,
      mode = "cursor", -- 'cursor' 'topline'
      max_lines = 3,
      trim_scope = "outer", -- Reduce context noise
      throttle = true, -- Better performance with large files
    })
  end,
}
