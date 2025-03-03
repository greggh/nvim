local git = require("utils.git")

return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-tree/nvim-web-devicons",
  },
  keys = {
    {
      "<leader>ff",
      function()
        if git.is_git_repo() then
          require("telescope.builtin").git_files({ cwd = git.get_workspace_root() })
        else
          require("telescope.builtin").find_files({ cwd = git.get_workspace_root() })
        end
      end,
      desc = "Find files",
    },
    {
      "<leader>fg",
      function()
        require("telescope.builtin").live_grep({ cwd = git.get_workspace_root() })
      end,
      desc = "Live grep",
    },
    {
      "<leader>fr",
      function()
        require("telescope.builtin").oldfiles()
      end,
      desc = "Recent files",
    },
    {
      "<leader>fb",
      function()
        require("telescope.builtin").current_buffer_fuzzy_find()
      end,
      desc = "Search current buffer",
    },
    {
      "<leader><leader>",
      function()
        require("telescope.builtin").buffers()
      end,
      desc = "List buffers",
    },
    {
      "<leader>fh",
      function()
        require("telescope.builtin").help_tags()
      end,
      desc = "Help tags",
    },
    {
      "<leader>cc",
      function()
        require("telescope.builtin").find_files({ cwd = vim.fn.stdpath("config") })
      end,
      desc = "Search config files",
    },
    {
      "<leader>fu",
      function()
        require("telescope.builtin").resume()
      end,
      desc = "Resume last picker",
    },
    {
      "<leader>fl",
      function()
        require("telescope.builtin").current_buffer_fuzzy_find()
      end,
      desc = "Search lines in current buffer",
    },
    -- Additional Telescope-specific pickers
    {
      "<leader>fc",
      function()
        require("telescope.builtin").commands()
      end,
      desc = "List commands",
    },
    {
      "<leader>fs",
      function()
        require("telescope.builtin").lsp_document_symbols()
      end,
      desc = "Document symbols",
    },
    {
      "<leader>fP",
      function()
        require("telescope.builtin").builtin()
      end,
      desc = "List pickers",
    },
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")

    telescope.setup({
      defaults = {
        mappings = {
          i = {
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
            ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
            ["<Esc>"] = actions.close,
            ["<C-u>"] = false,
            ["<C-d>"] = false,
          },
        },
        file_ignore_patterns = {
          "node_modules",
          ".git/",
          "vendor/",
          ".cache",
          "%.o",
          "%.a",
          "%.out",
          "%.class",
          "%.pdf",
          "%.mkv",
          "%.mp4",
          "%.zip",
        },
        path_display = { "smart" },
        dynamic_preview_title = true,
        layout_strategy = "flex",
        layout_config = {
          horizontal = {
            preview_width = 0.6,
          },
          vertical = {
            mirror = false,
          },
          width = 0.87,
          height = 0.80,
        },
      },
      pickers = {
        find_files = {
          theme = "ivy",
          previewer = true,
          hidden = true,
        },
        git_files = {
          theme = "ivy",
          previewer = true,
        },
        buffers = {
          theme = "ivy",
          previewer = true,
          sort_lastused = true,
          sort_mru = true,
        },
      },
      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = "smart_case",
        },
      },
    })

    -- Load extensions
    telescope.load_extension("fzf")
  end,
}
