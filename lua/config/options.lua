------------------------------------
-- OPTIONS
------------------------------------
vim.g.mapleader = " "
vim.g.maplocalleader = " "
------------------------------------
vim.g.dashboard_header = require("utils.ui").headers.anonymous
vim.g.ai = require("utils.flags").get_flags("ai") or false
vim.g.debugger = require("utils.flags").get_flags("debugger") or false
vim.g.suggestions = require("utils.flags").get_flags("suggestions") or false
vim.g.tests = require("utils.flags").get_flags("tests") or false
vim.g.ide_view_open = false
vim.g.current_session = nil
vim.g.ignore_filetypes = {
  "qf",
  "Avante",
  "netrw",
  "NvimTree",
  "lazy",
  "mason",
  "grug-far",
  "lazydo",
  "lazygit",
  "minifiles",
  "snacks_dashboard",
  "snacks_terminal",
  "snacks_picker_input",
  "yazi",
  "trouble",
  "Trouble",
  "diffview",
  "checkhealth",
  "dapui",
  "lspinfo",
  "noice",
  "minifiles",
  "notify",
  "prompt",
}
------------------------------------
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.shortmess:append({ c = true })
vim.o.autochdir = true
vim.o.backup = false
vim.o.breakindent = true
vim.o.cmdheight = 1
vim.o.colorcolumn = ""
vim.o.completeopt = "menu,menuone,noselect"
vim.o.cursorline = true
vim.o.expandtab = true
vim.o.hidden = true
vim.o.hlsearch = false
vim.o.ignorecase = true
vim.o.inccommand = "split"
vim.o.incsearch = true
vim.o.laststatus = 13
vim.o.list = true
vim.o.mouse = "a"
vim.o.number = true
vim.o.relativenumber = true
vim.o.scrolloff = 999
vim.o.shiftround = true
vim.o.shiftwidth = 2
vim.o.showmode = false
vim.o.showtabline = 0
vim.o.sidescrolloff = 999
vim.o.smartcase = true
vim.o.smartindent = true
vim.o.softtabstop = 2
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.swapfile = false
vim.o.tabstop = 2
vim.o.termguicolors = true
vim.o.timeoutlen = 300
vim.o.updatetime = 250
vim.o.autoread = true
vim.o.wrap = false
-- Folding configuration using Treesitter
vim.o.foldmethod = "expr"
vim.o.foldexpr = "nvim_treesitter#foldexpr()"
vim.o.foldlevelstart = 99  -- Start with all folds open

-- Modern Neovim 0.10+ features
vim.o.splitkeep = "screen"      -- Maintain window view on splits
vim.o.smoothscroll = true       -- Smooth scrolling for half-page jumps
vim.o.exrc = true               -- Per-project configuration
vim.o.mousemoveevent = true     -- Enable mouse move events
vim.o.cmdheight = 0             -- Hide cmdline when not in use for more space

-- Better gutter configuration
vim.o.signcolumn = "auto:2"
vim.o.statuscolumn = "%=%{v:virtnum < 1 ? (v:relnum ? v:relnum : v:lnum) : ''}%=%s"

-- Enable modern diff algorithm
vim.opt.diffopt:append({ "algorithm:histogram", "indent-heuristic" })
------------------------------------
vim.schedule(function()
  vim.o.clipboard = vim.env.SSH_TTY and "" or "unnamedplus"
end)
------------------------------------
