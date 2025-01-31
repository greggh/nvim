------------------------------------
-- KEYMAPS
------------------------------------
local keymap = vim.api.nvim_set_keymap

-- QUIT
keymap("n", "ZQ", "<CMD>quitall!<CR>", { noremap = true, silent = true, desc = "Quit all" })
keymap("n", "<A-q>", "<CMD>wqall<CR>", { noremap = true, silent = true, desc = "Quit all (and save)" })

-- LAZY
keymap("n", "<leader>.", "<CMD>Lazy sync<CR>", { noremap = true, silent = true, desc = "Lazy sync" })

-- FLAGS
keymap("n", "<leader>F", "<CMD>Flags<CR>", { noremap = true, silent = true, desc = "Flags" })

-- PASTE YANK, NOT DELETED
keymap("n", "<leader>p", '"*p', { noremap = true, silent = true, desc = "Paste after from computer" })
keymap("n", "<leader>P", '"*P', { noremap = true, silent = true, desc = "Paste before from computer" })

-- BUFFERS
keymap("n", "<leader><tab>", "<CMD>b#<CR>", { noremap = true, silent = true, desc = "Buffer switch back & forth" })
keymap("n", "[b", "<CMD>bp<CR>", { noremap = true, silent = true, desc = "Buffer previous" })
keymap("n", "]b", "<CMD>bn<CR>", { noremap = true, silent = true, desc = "Buffer next" })

-- MOVE LINES
keymap("n", "<c-a-j>", "<CMD>m .+1<CR>==", { noremap = true, silent = true, desc = "Move line down" })
keymap("n", "<c-a-k>", "<CMD>m .-2<CR>==", { noremap = true, silent = true, desc = "Move line up" })
keymap("i", "<c-a-j>", "<Esc><CMD>m .+1<CR>==gi", { noremap = true, silent = true, desc = "Move line down" })
keymap("i", "<c-a-k>", "<Esc><CMD>m .-2<CR>==gi", { noremap = true, silent = true, desc = "Move line up" })
keymap("v", "<c-a-j>", "<ESC><CMD>'<,'>m '>+1<CR>gv=gv", { noremap = true, silent = true, desc = "Move line down" })
keymap("v", "<c-a-k>", "<ESC><CMD>'<,'>m '<-2<CR>gv=gv", { noremap = true, silent = true, desc = "Move line up" })

-- NvimTree
keymap("n", "<C-n>", "<CMD>NvimTreeToggle<CR>", { noremap = true, silent = true, desc = "NvimTree toggle" })
keymap("i", "<C-n>", "<CMD>NvimTreeToggle<CR>", { noremap = true, silent = true, desc = "NvimTree toggle" })
keymap("v", "<C-n>", "<CMD>NvimTreeToggle<CR>", { noremap = true, silent = true, desc = "NvimTree toggle" })

-- Toggle IDE view
keymap(
  "n",
  "<C-a>",
  '<CMD>lua require("utils.ui").ToggleIDEView()<CR>',
  { noremap = true, silent = true, desc = "Toggle IDE view" }
)
-- Populate workspace diagnostics for entire project
keymap("n", "<leader>xd", "", {
  noremap = true,
  callback = function()
    for _, client in ipairs(vim.lsp.get_clients()) do
      require("workspace-diagnostics").populate_workspace_diagnostics(client, 0)
    end
  end,
  desc = "Populate workspace diagnostics",
})
