local bind = require("utils.keymap-bind")
local map_cr = bind.map_cr
local map_cu = bind.map_cu
local map_cmd = bind.map_cmd
local map_callback = bind.map_callback

local builtin_map = {
  -- Builtin: save & quit
  ["n|<leader>qs"] = map_cu("write"):with_noremap():with_silent():with_desc("edit: Save file"),
  ["n|<leader>qq"] = map_cr("wq"):with_desc("edit: Save file and quit"),
  ["n|<leader>qf"] = map_cr("qall!"):with_desc("edit: Force quit all (no save)"),
  ["n|<leader>qx"] = map_cr("wqall"):with_desc("edit: Save all and quit"),
  ["n|<C-s>"] = map_cu("write"):with_noremap():with_silent():with_desc("edit: Save file"),
  ["n|<C-q>"] = map_cr("wq"):with_desc("edit: Save file and quit"),
  ["n|<A-S-q>"] = map_cr("qall!"):with_desc("edit: Force quit"),
  ["n|<A-q>"] = map_cr("wqall"):with_desc("edit: Save file and quit"),
  ["n|<leader>qz"] = map_cr("quitall!"):with_desc("edit: Force quit"),

  -- Builtin: insert mode
  ["i|<C-u>"] = map_cmd("<C-G>u<C-U>"):with_noremap():with_desc("edit: Delete previous block"),
  ["i|<C-b>"] = map_cmd("<Left>"):with_noremap():with_desc("edit: Move cursor to left"),
  ["i|<C-a>"] = map_cmd("<ESC>^i"):with_noremap():with_desc("edit: Move cursor to line start"),
  ["i|<C-s>"] = map_cmd("<Esc>:w<CR>"):with_desc("edit: Save file"),
  ["i|<C-q>"] = map_cmd("<Esc>:wq<CR>"):with_desc("edit: Save file and quit"),

  -- Builtin: command mode
  ["c|<C-b>"] = map_cmd("<Left>"):with_noremap():with_desc("edit: Left"),
  ["c|<C-f>"] = map_cmd("<Right>"):with_noremap():with_desc("edit: Right"),
  ["c|<C-a>"] = map_cmd("<Home>"):with_noremap():with_desc("edit: Home"),
  ["c|<C-e>"] = map_cmd("<End>"):with_noremap():with_desc("edit: End"),
  ["c|<C-d>"] = map_cmd("<Del>"):with_noremap():with_desc("edit: Delete"),
  ["c|<C-h>"] = map_cmd("<BS>"):with_noremap():with_desc("edit: Backspace"),
  ["c|<C-t>"] = map_cmd([[<C-R>=expand("%:p:h") . "/" <CR>]])
    :with_noremap()
    :with_desc("edit: Complete path of current file"),

  -- Builtin: visual mode
  ["v|J"] = map_cmd(":m '>+1<CR>gv=gv"):with_desc("edit: Move this line down"),
  ["v|K"] = map_cmd(":m '<-2<CR>gv=gv"):with_desc("edit: Move this line up"),
  ["v|<"] = map_cmd("<gv"):with_desc("edit: Decrease indent"),
  ["v|>"] = map_cmd(">gv"):with_desc("edit: Increase indent"),

  -- Builtin: suckless
  ["n|Y"] = map_cmd("y$"):with_desc("edit: Yank text to EOL"),
  ["n|D"] = map_cmd("d$"):with_desc("edit: Delete text to EOL"),
  ["n|n"] = map_cmd("nzzzv"):with_noremap():with_desc("edit: Next search result"),
  ["n|N"] = map_cmd("Nzzzv"):with_noremap():with_desc("edit: Prev search result"),
  ["n|J"] = map_cmd("mzJ`z"):with_noremap():with_desc("edit: Join next line"),
  ["n|<S-Tab>"] = map_cr("normal za"):with_noremap():with_silent():with_desc("edit: Toggle code fold"),
  ["n|<leader>o"] = map_cr("setlocal spell! spelllang=en_us"):with_desc("edit: Toggle spell check"),

  -- Builtin: terminal
  ["t|<C-w>h"] = map_cmd("<Cmd>wincmd h<CR>"):with_silent():with_noremap():with_desc("window: Focus left"),
  ["t|<C-w>l"] = map_cmd("<Cmd>wincmd l<CR>"):with_silent():with_noremap():with_desc("window: Focus right"),
  ["t|<C-w>j"] = map_cmd("<Cmd>wincmd j<CR>"):with_silent():with_noremap():with_desc("window: Focus down"),
  ["t|<C-w>k"] = map_cmd("<Cmd>wincmd k<CR>"):with_silent():with_noremap():with_desc("window: Focus up"),

  -- Builtin: tab
  ["n|<leader>wtn"] = map_cr("tabnew"):with_noremap():with_silent():with_desc("tab: Create a new tab"),
  ["n|<leader>wth"] = map_cr("tabnext"):with_noremap():with_silent():with_desc("tab: Move to next tab"),
  ["n|<leader>wtl"] = map_cr("tabprevious"):with_noremap():with_silent():with_desc("tab: Move to previous tab"),
  ["n|<leader>wtc"] = map_cr("tabonly"):with_noremap():with_silent():with_desc("tab: Only keep current tab"),
}

bind.nvim_load_mapping(builtin_map)

local plug_map = {
  -- Plugin: avante
  -- Avante's keybindings are built into the plugin itself or in avante-prompts.lua

  -- Plugin: arrow
  ["n|<leader>m"] = map_cmd("<CMD>Arrow open<CR>"):with_noremap():with_silent():with_desc("Arrow: Open"),

  -- Plugin: snacks
  ["n|<leader>e"] = map_callback(function()
      ---@diagnostic disable-next-line: missing-fields
      Snacks.explorer({ cwd = vim.fs.root(0, { ".git" }) })
    end)
    :with_noremap()
    :with_silent()
    :with_desc("Picker: Explorer"),

  -- Plugin: yazi
  ["n|<leader>f/"] = map_cmd("<CMD>Yazi<CR>"):with_noremap():with_silent():with_desc("Yazi: Current file"),
  ["n|<leader>f-"] = map_cmd("<CMD>Yazi cwd<CR>")
    :with_noremap()
    :with_silent()
    :with_desc("Yazi: nvim working directory"),
  ["n|<leader>f\\"] = map_cmd("<CMD>Yazi toggle<CR>")
    :with_noremap()
    :with_silent()
    :with_desc("Yazi: Resume last session"),

  -- Plugin: lazy
  ["n|<leader>pl"] = map_cmd("<CMD>Lazy sync<CR>"):with_noremap():with_silent():with_desc("✓ Lazy: Sync"),

  -- Plugin: Mason
  ["n|<leader>pm"] = map_cmd("<CMD>Mason<CR>"):with_noremap():with_silent():with_desc("Mason: Toggle"),

  -- Plugin: flags
  ["n|<leader>F"] = map_cmd("<CMD>Flags<CR>"):with_noremap():with_silent():with_desc("Flags"),

  -- Plugin: buffer
  ["n|<leader><tab>"] = map_cmd("<CMD>b#<CR>"):with_noremap():with_silent():with_desc("Buffer: Switch back & forth"),
  ["n|<leader>b["] = map_cmd("<CMD>bp<CR>"):with_noremap():with_silent():with_desc("Buffer: Previous"),
  ["n|<leader>b]"] = map_cmd("<CMD>bn<CR>"):with_noremap():with_silent():with_desc("Buffer: Next"),

  -- Plugin: move lines
  ["n|<c-a-j>"] = map_cmd("<CMD>m .+1<CR>=="):with_noremap():with_silent():with_desc("Move: Line down"),
  ["n|<c-a-k>"] = map_cmd("<CMD>m .-2<CR>=="):with_noremap():with_silent():with_desc("Move: Line up"),
  ["i|<c-a-j>"] = map_cmd("<Esc><CMD>m .+1<CR>==gi"):with_noremap():with_silent():with_desc("Move: Line down"),
  ["i|<c-a-k>"] = map_cmd("<Esc><CMD>m .-2<CR>==gi"):with_noremap():with_silent():with_desc("Move: Line up"),
  ["v|<c-a-j>"] = map_cmd("<ESC><CMD>'<,'>m '>+1<CR>gv=gv"):with_noremap():with_silent():with_desc("Move: Line down"),
  ["v|<c-a-k>"] = map_cmd("<ESC><CMD>'<,'>m '<-2<CR>gv=gv"):with_noremap():with_silent():with_desc("Move: Line up"),

  -- Plugin: ccc
  ["n|<leader>cp"] = map_cmd("<CMD>CccPick<CR>"):with_noremap():with_silent():with_desc("Color Picker"),
  ["i|<C-c>"] = map_cmd("<CMD>CccPick<CR>"):with_noremap():with_silent():with_desc("Color Picker"),

  -- Plugin Lazygit
  ["n|<leader>gg"] = map_callback(function()
      if require("utils.git").is_git_repo() then
        ---@diagnostic disable-next-line: missing-fields
        Snacks.lazygit({ cwd = require("utils.git").get_git_root() })
      elseif vim.bo.filetype == "snacks_dashboard" then
        ---@diagnostic disable-next-line: missing-fields, assign-type-mismatch
        Snacks.lazygit({ cwd = vim.fn.stdpath("config") })
      else
        print("You're not in a git repository")
      end
    end)
    :with_noremap()
    :with_silent()
    :with_desc("Lazygit"),

  ["n|<leader>gl"] = map_callback(function()
      if require("utils.git").is_git_repo() then
        ---@diagnostic disable-next-line: missing-fields
        Snacks.lazygit.log({ cwd = require("utils.git").get_git_root() })
      elseif vim.bo.filetype == "snacks_dashboard" then
        ---@diagnostic disable-next-line: missing-fields, assign-type-mismatch
        Snacks.lazygit.log({ cwd = vim.fn.stdpath("config") })
      else
        print("You're not in a git repository")
      end
    end)
    :with_noremap()
    :with_silent()
    :with_desc("Lazygit log"),

  -- Plugin: smart-splits.nvim
  ["n|<A-h>"] = map_cu("SmartResizeLeft"):with_silent():with_noremap():with_desc("window: Resize -3 left"),
  ["n|<A-j>"] = map_cu("SmartResizeDown"):with_silent():with_noremap():with_desc("window: Resize -3 down"),
  ["n|<A-k>"] = map_cu("SmartResizeUp"):with_silent():with_noremap():with_desc("window: Resize +3 up"),
  ["n|<A-l>"] = map_cu("SmartResizeRight"):with_silent():with_noremap():with_desc("window: Resize +3 right"),
  ["n|<C-h>"] = map_cu("SmartCursorMoveLeft"):with_silent():with_noremap():with_desc("window: Focus left"),
  ["n|<C-j>"] = map_cu("SmartCursorMoveDown"):with_silent():with_noremap():with_desc("window: Focus down"),
  ["n|<C-k>"] = map_cu("SmartCursorMoveUp"):with_silent():with_noremap():with_desc("window: Focus up"),
  ["n|<C-l>"] = map_cu("SmartCursorMoveRight"):with_silent():with_noremap():with_desc("window: Focus right"),
  ["n|<leader>wh"] = map_cu("SmartSwapLeft"):with_silent():with_noremap():with_desc("window: Move window left"),
  ["n|<leader>wj"] = map_cu("SmartSwapDown"):with_silent():with_noremap():with_desc("window: Move window down"),
  ["n|<leader>wk"] = map_cu("SmartSwapUp"):with_silent():with_noremap():with_desc("window: Move window up"),
  ["n|<leader>wl"] = map_cu("SmartSwapRight"):with_silent():with_noremap():with_desc("window: Move window right"),

  -- Plugin: boole.nvim
  ["n|<C-n>"] = map_cmd("<CMD>Boole increment<CR>"):with_noremap():with_silent():with_desc("Boole: Increment"),
  ["n|<C-m>"] = map_cmd("<CMD>Boole decrement<CR>"):with_noremap():with_silent():with_desc("Boole: Decrement"),

  -- Plugin: flash
  ["nxo|s"] = map_cmd("<CMD>lua require('flash').jump()<CR>"):with_noremap():with_silent():with_desc("Flash"),

  -- Plugin: gitsigns
  ["n|<leader>gb"] = map_cmd("<CMD>Gitsigns toggle_current_line_blame<CR>")
    :with_noremap()
    :with_silent()
    :with_desc("Gitsigns: Toggle current line blame"),
  ["n|<leader>gs"] = map_cmd("<CMD>Gitsigns stage_hunk<CR>")
    :with_noremap()
    :with_silent()
    :with_desc("Gitsigns: Stage hunk"),
  ["n|<leader>gu"] = map_cmd("<CMD>Gitsigns undo_stage_hunk<CR>")
    :with_noremap()
    :with_silent()
    :with_desc("Gitsigns: Undo stage hunk"),
  ["n|<leader>gt"] = map_cmd("<CMD>Gitsigns toggle_signs<CR>")
    :with_noremap()
    :with_silent()
    :with_desc("Gitsigns: Toggle signs"),
  ["n|<leader>gi"] = map_cmd("<CMD>Gitsigns preview_hunk_inline<CR>")
    :with_noremap()
    :with_silent()
    :with_desc("Gitsigns: Preview hunk inline"),
  ["n|<leader>gr"] = map_cmd("<CMD>Gitsigns reset_hunk<CR>")
    :with_noremap()
    :with_silent()
    :with_desc("Gitsigns: Reset hunk"),
  ["n|<leader>gR"] = map_cmd("<CMD>Gitsigns reset_buffer<CR>")
    :with_noremap()
    :with_silent()
    :with_desc("Gitsigns: Reset buffer"),
  ["n|<leader>gp"] = map_cmd("<CMD>Gitsigns preview_hunk<CR>")
    :with_noremap()
    :with_silent()
    :with_desc("Gitsigns: Preview hunk"),
  ["n|<leader>g]"] = map_cmd("<CMD>Gitsigns next_hunk<CR>")
    :with_noremap()
    :with_silent()
    :with_desc("Gitsigns: Next hunk"),
  ["n|<leader>g["] = map_cmd("<CMD>Gitsigns prev_hunk<CR>")
    :with_noremap()
    :with_silent()
    :with_desc("Gitsigns: Prev hunk"),

  -- Plugin: diffview.nvim
  ["n|<leader>gh"] = map_cmd("<CMD>DiffviewFileHistory<CR>")
    :with_noremap()
    :with_silent()
    :with_desc("Diff branch history"),
  ["n|<leader>gd"] = map_cmd("<CMD>DiffviewFileHistory --follow %<CR>")
    :with_noremap()
    :with_silent()
    :with_desc("Diff file"),
  ["v|<leader>gd"] = map_cmd("<ESC><CMD>'<,'>DiffviewFileHistory --follow<CR>")
    :with_noremap()
    :with_silent()
    :with_desc("Diff Selection"),
  ["n|<leader>gv"] = map_callback(function()
      local lib = require("diffview.lib")
      local view = lib.get_current_view()
      if view then
        vim.cmd.DiffviewClose()
      else
        vim.cmd.DiffviewOpen()
      end
    end)
    :with_noremap()
    :with_silent()
    :with_desc("Diff view"),
  ["n|<leader>gx"] = map_cmd("<CMD>ClipboardDiff<CR>"):with_noremap():with_silent():with_desc("Diff clipboard"),
  ["v|<leader>gx"] = map_cmd("<ESC><CMD>ClipboardDiffSelection<CR>")
    :with_noremap()
    :with_silent()
    :with_desc("Diff clipboard Selection"),

  -- Plugin: auto-save.nvim
  ["n|<leader>oa"] = map_cmd("<CMD>ASToggle<CR>"):with_noremap():with_silent():with_desc("Toggle auto save"),

  -- Plugin: grug-far.nvim
  ["n|<leader>r"] = map_callback(function()
      require("grug-far").open({ prefills = { paths = vim.fn.expand("%") } })
    end)
    :with_noremap()
    :with_silent()
    :with_desc("Search and replace"),
  ["v|<leader>r"] = map_callback(function()
      require("grug-far").with_visual_selection({ prefills = { paths = vim.fn.expand("%") } })
    end)
    :with_noremap()
    :with_silent()
    :with_desc("Search and replace selection"),

  -- Plugin: maximizer
  ["n|<C-w>m"] = map_cmd("<CMD>MaximizerToggle<CR>")
    :with_noremap()
    :with_silent()
    :with_desc("Maximize/minimize a split"),

  -- Plugin: mini-sessions
  ["n|<leader>sl"] = map_callback(function()
      require("utils.mini.sessions").select_session()
    end)
    :with_noremap()
    :with_silent()
    :with_desc("Load session"),
  ["n|<leader>ss"] = map_callback(function()
      require("utils.mini.sessions").new_session()
    end)
    :with_noremap()
    :with_silent()
    :with_desc("Save session"),
  ["n|<leader>s<backspace>"] = map_callback(function()
      require("utils.mini.sessions").restore_session()
    end)
    :with_noremap()
    :with_silent()
    :with_desc("Load last session"),
  ["n|<leader>sw"] = map_callback(function()
      if vim.g.current_session then
        vim.notify("Current session: " .. vim.g.current_session, vim.log.levels.INFO)
      else
        vim.notify("No current session", vim.log.levels.WARN)
      end
    end)
    :with_noremap()
    :with_silent()
    :with_desc("Current session"),

  -- Plugin: mini-surround
  ["n|ua"] = map_callback(function()
      require("mini.surround").add("normal")
    end)
    :with_noremap()
    :with_silent()
    :with_desc("Surround: Add"),
  ["n|ud"] = map_callback(function()
      require("mini.surround").delete()
    end)
    :with_noremap()
    :with_silent()
    :with_desc("Surround: Delete"),
  ["n|ur"] = map_callback(function()
      require("mini.surround").replace()
    end)
    :with_noremap()
    :with_silent()
    :with_desc("Surround: Replace"),

  -- Plugin: outline
  ["n|<leader>lo"] = map_cmd("<CMD>Outline<CR>"):with_noremap():with_silent():with_desc("Toggle Outline"),

  -- Plugin: Suda
  ["n|<leader>qS"] = map_cmd("<CMD>Suda w<CR>"):with_noremap():with_silent():with_desc("Suda: Write"),
  ["n|<leader>qv"] = map_cmd("<CMD>Suda wq<CR>"):with_noremap():with_silent():with_desc("Suda: Write and quit"),
  ["n|<leader>qa"] = map_cmd("<CMD>Suda wqa<CR>"):with_noremap():with_silent():with_desc("Suda: Write and quit all"),

  -- Plugin: neotest
  ["n|<leader>tl"] = map_callback(function()
      require("neotest").run.run_last()
    end)
    :with_noremap()
    :with_silent()
    :with_desc("Run Last (Neotest)"),
  ["n|<leader>to"] = map_callback(function()
      require("neotest").output.open({ enter = true, auto_close = true })
    end)
    :with_noremap()
    :with_silent()
    :with_desc("Show Output (Neotest)"),
  ["n|<leader>tO"] = map_callback(function()
      require("neotest").output_panel.toggle()
    end)
    :with_noremap()
    :with_silent()
    :with_desc("Toggle Output Panel (Neotest)"),
  ["n|<leader>tr"] = map_callback(function()
      require("neotest").run.run()
    end)
    :with_noremap()
    :with_silent()
    :with_desc("Run Nearest (Neotest)"),
  ["n|<leader>ts"] = map_callback(function()
      require("neotest").summary.toggle()
    end)
    :with_noremap()
    :with_silent()
    :with_desc("Toggle Summary (Neotest)"),
  ["n|<leader>tS"] = map_callback(function()
      require("neotest").run.stop()
    end)
    :with_noremap()
    :with_silent()
    :with_desc("Stop (Neotest)"),
  ["n|<leader>tt"] = map_callback(function()
      require("neotest").run.run(vim.fn.expand("%"))
    end)
    :with_noremap()
    :with_silent()
    :with_desc("Run File (Neotest)"),
  ["n|<leader>tT"] = map_callback(function()
      require("neotest").run.run(require("utils.git").get_workspace_root())
    end)
    :with_noremap()
    :with_silent()
    :with_desc("Run All Test Files (Neotest)"),
  ["n|<leader>tw"] = map_callback(function()
      require("neotest").watch.toggle(vim.fn.expand("%"))
    end)
    :with_noremap()
    :with_silent()
    :with_desc("Toggle Watch (Neotest)"),

  -- Plugin: todo-comments
  ["n|<leader>xc"] = map_callback(function()
      ---@diagnostic disable-next-line: undefined-field
      Snacks.picker.todo_comments()
    end)
    :with_noremap()
    :with_silent()
    :with_desc("Todo Comments: show TODO"),

  -- Plugin: treewalker
  ["n|<a-s-j>"] = map_cmd("<CMD>Treewalker Down<CR>"):with_noremap():with_silent():with_desc("Treewalker Down"),
  ["n|<a-s-k>"] = map_cmd("<CMD>Treewalker Up<CR>"):with_noremap():with_silent():with_desc("Treewalker Up"),
  ["n|<a-s-h>"] = map_cmd("<CMD>Treewalker Left<CR>"):with_noremap():with_silent():with_desc("Treewalker Left"),
  ["n|<a-s-l>"] = map_cmd("<CMD>Treewalker Right<CR>"):with_noremap():with_silent():with_desc("Treewalker Right"),

  -- Plugin: Trouble
  ["n|<leader>xw"] = map_cmd("<CMD>Trouble diagnostics toggle<CR>")
    :with_noremap()
    :with_silent()
    :with_desc("Trouble: workspace diagnostics"),
  ["n|<leader>xx"] = map_cmd("<CMD>Trouble diagnostics toggle filter.buf=0<CR>")
    :with_noremap()
    :with_silent()
    :with_desc("Trouble: document diagnostics"),
  ["n|<leader>xq"] = map_cmd("<CMD>Trouble quickfix toggle<CR>")
    :with_noremap()
    :with_silent()
    :with_desc("Trouble: quickfix list"),
  ["n|<c-q>"] = map_cmd("<CMD>Trouble quickfix toggle<CR>")
    :with_noremap()
    :with_silent()
    :with_desc("Trouble: quickfix list"),
  ["n|<leader>xl"] = map_cmd("<CMD>Trouble loclist toggle<CR>")
    :with_noremap()
    :with_silent()
    :with_desc("Trouble: location list"),
  ["n|<leader>xt"] = map_cmd("<CMD>Trouble todo toggle<CR>"):with_noremap():with_silent():with_desc("Trouble: TODO"),
  ["n|<leader>xs"] = map_cmd("<CMD>Trouble symbols toggle win.position=right<CR>")
    :with_noremap()
    :with_silent()
    :with_desc("Trouble: Symbols"),
  ["n|<leader>xp"] = map_cmd("<CMD>Trouble lsp toggle win.position=right<CR>")
    :with_noremap()
    :with_silent()
    :with_desc("Trouble: LSP"),

  -- Pligin: actions-preview
  ["nv|<leader>ca"] = map_callback(function()
      require("actions-preview").code_actions()
    end)
    :with_noremap()
    :with_silent()
    :with_desc("Code Actions"),

  -- Plugin: snacks rename
  ["n|<leader>fR"] = map_callback(function()
      Snacks.rename.rename_file()
    end)
    :with_noremap()
    :with_silent()
    :with_desc("Rename file"),
}

bind.nvim_load_mapping(plug_map)

local misc_map = {
  -- Misc: toggle IDE view
  ["n|<C-a>"] = map_cmd("<CMD>lua require('utils.ui').ToggleIDEView()<CR>")
    :with_noremap()
    :with_silent()
    :with_desc("Toggle IDE view"),

  -- Misc: populate workspace diagnostics
  ["n|<leader>xd"] = map_callback(function()
      for _, client in ipairs(vim.lsp.get_clients()) do
        require("workspace-diagnostics").populate_workspace_diagnostics(client, 0)
      end
    end)
    :with_noremap()
    :with_silent()
    :with_desc("Populate workspace diagnostics"),
}

bind.nvim_load_mapping(misc_map)

local wk = require("which-key")

-- basic
wk.add({ mode = "n" }, {
  { "ccb", desc = "Togggle block comment" },
  { "ccc", desc = "Toggle line comment" },
  { "cbc", desc = "Toggle comment" },
})

wk.add({ mode = "x" }, {
  { "cc", desc = "Toggle line comment" },
  { "cb", desc = "Togggle block comment" },
})

-- extra
wk.add({ mode = "n" }, {
  { "ccA", desc = "Comment end of line" },
  { "cco", desc = "Comment next line" },
  { "ccO", desc = "Comment prev line" },
})

-- extended
wk.add({ mode = "n" }, {
  { "c>", desc = "Comment region" },
  { "c<lt>", desc = "Uncomment region" },
  { "c<lt>c", desc = "Remove line comment" },
  { "c<lt>b", desc = "Remove block comment" },
  { "c>c", desc = "Add line comment" },
  { "c>b", desc = "Add block comment" },
})

wk.add({ mode = "x" }, {
  { "c>", desc = "Comment region" },
  { "c<lt>", desc = "Uncomment region" },
})

-- Add icons to everything in Whick-key

wk.add({
  mode = "n",
  { "<leader>m", desc = "Arrow: Open", icon = "󰁕" },
  { "<leader>e", desc = "Picker: Explorer", icon = "" },
  { "<leader>f/", desc = "Yazi: Current file", icon = "" },
  { "<leader>f-", desc = "Yazi: nvim working directory", icon = "󰘦" },
  { "<leader>f\\", desc = "Yazi: Resume last session", icon = "↺" },
  { "<leader>pl", desc = "✓ Lazy: Sync", icon = "󰒲" },
  { "<leader>pm", desc = "Mason: Toggle", icon = "" },
  { "<leader>F", desc = "Flags", icon = "⚐" },
  { "<leader><tab>", desc = "Buffer: Switch back & forth", icon = "" },
  { "<leader>b[", desc = "Buffer: Previous", icon = "<-" },
  { "<leader>b]", desc = "Buffer: Next", icon = "->" },
  { "<leader>cp", desc = "Color Picker", icon = "󰏘" },
  { "<leader>gb", desc = "Gitsigns: Toggle current line blame", icon = "" },
  { "<leader>gs", desc = "Gitsigns: Stage hunk", icon = "" },
  { "<leader>gu", desc = "Gitsigns: Undo stage hunk", icon = "" },
  { "<leader>gt", desc = "Gitsigns: Toggle signs", icon = "" },
  { "<leader>gi", desc = "Gitsigns: Preview hunk inline", icon = "" },
  { "<leader>gr", desc = "Gitsigns: Reset hunk", icon = "" },
  { "<leader>gR", desc = "Gitigns: Reset buffer", icon = "" },
  { "<leader>gp", desc = "Gitsigns: Preview hunk", icon = "" },
  { "<leader>g]", desc = "Gitsigns: Next hunk", icon = "" },
  { "<leader>g[", desc = "Gitsigns: Prev hunk", icon = "" },
  { "<leader>gg", desc = "Lazygit", icon = "󰒲" },
  { "<leader>gl", desc = "Lazygit log", icon = "" },
  { "<leader>gx", desc = "Diff clipboard", icon = "📋" },
  { "<leader>gv", desc = "Diff view", icon = "" },
  { "<leader>oa", desc = "Toggle auto save", icon = "󰑖" },
  { "<leader>r", desc = "Search and replace", icon = "" },
  { "<leader>s<backspace>", desc = "Load last session", icon = "󰙠" },
  { "<leader>sl", desc = "Load session", icon = "" },
  { "<leader>ss", desc = "Save session", icon = "" },
  { "<leader>sw", desc = "Current session", icon = "" },
  { "<leader>tS", desc = "Stop (Neotest)", icon = "󰝤" },
  { "<leader>tT", desc = "TODO (Neotest)", icon = "" },
  { "<leader>ta", desc = "Code Actions", icon = "" },
  { "<leader>tl", desc = "Run Last (Neotest)", icon = "" },
  { "<leader>to", desc = "Show Output (Neotest)", icon = "" },
  { "<leader>tO", desc = "Toggle Output Panel (Neotest)", icon = "" },
  { "<leader>tr", desc = "Run Nearest (Neotest)", icon = "" },
  { "<leader>ts", desc = "Toggle Summary (Neotest)", icon = "" },
  { "<leader>tt", desc = "Run File (Neotest)", icon = "" },
  { "<leader>tw", desc = "Toggle Watch (Neotest)", icon = "" },
  { "<leader>xq", desc = "Trouble: quickfix list", icon = "" },
  { "<leader>xd", desc = "Populate workspace diagnostics", icon = "" },
  { "<leader>xl", desc = "Trouble: location list", icon = "󰀹" },
  { "<leader>xp", desc = "Trouble: LSP", icon = "󱜙" },
  { "<leader>xs", desc = "Trouble: Symbols", icon = "" },
  { "<leader>xw", desc = "Trouble: workspace diagnostics", icon = "" },
  { "<leader>xx", desc = "Trouble: document diagnostics", icon = "" },
  { "<leader>xt", desc = "Trouble: TODO", icon = "" },
  { "<leader>xc", desc = "Todo Comments: show TODO", icon = "" },
  { "<leader>ua", desc = "Surround: Add", icon = "" },
  { "<leader>ud", desc = "Surround: Delete", icon = "" },
  { "<leader>ur", desc = "Surround: Replace", icon = "󰏫" },
  { "<leader>qz", desc = "Force quit", icon = "󰝥" },
  { "<leader>qf", desc = "Force quit all (no save)", icon = "" },
  { "<leader>qx", desc = "Save all and quit", icon = "" },
  { "<leader>qq", desc = "Save file and quit", icon = "" },
  { "<leader>qs", desc = "Save file", icon = "" },
  { "<leader>qS", desc = "Suda: Write", icon = "󰌋" },
  { "<leader>qv", desc = "Suda: Write and quit", icon = "󰌋" },
  { "<leader>qa", desc = "Suda: Write and quit all", icon = "󱕴" },
  { "<leader>wh", desc = "Move window left", icon = "←" },
  { "<leader>wj", desc = "Move window down", icon = "↓" },
  { "<leader>wk", desc = "Move window up", icon = "↑" },
  { "<leader>wl", desc = "Move window right", icon = "→" },
  { "<leader>lo", desc = "Toggle Outline", icon = "󰌗" },
  { "<leader>ca", desc = "Code Actions", icon = "" },
  { "<leader>fR", desc = "Rename file", icon = "󰬶" },
  { "<leader>wtn", desc = "Create a new tab", icon = "+" },
  { "<leader>wth", desc = "Move to next tab", icon = "" },
  { "<leader>wtl", desc = "Move to previous tab", icon = "" },
  { "<leader>wtc", desc = "Only keep current tab", icon = "" },
})

local readme_map = {
  ["n|<leader>pr"] = map_callback(function()
      local plugins = require("lazy.core.config").plugins
      local file_content = {
        "<h1>",
        '  <img src="https://raw.githubusercontent.com/neovim/neovim.github.io/master/logos/neovim-logo-300x87.png" alt="Neovim">',
        "</h1>",
        "",
        '<a href="https://dotfyle.com/greggh/nvim"><img src="https://dotfyle.com/greggh/nvim/badges/plugins?style=flat" /></a>',
        '<a href="https://dotfyle.com/greggh/nvim"><img src="https://dotfyle.com/greggh/nvim/badges/leaderkey?style=flat" /></a>',
        '<a href="https://dotfyle.com/greggh/nvim"><img src="https://dotfyle.com/greggh/nvim/badges/plugin-manager?style=flat" /></a>',
        "",
        "![image](assets/readme/neovim.png)",
        "",
        "## ⚡️ Requirements",
        "",
        "- [Nerd Font](https://www.nerdfonts.com/)",
        "- [lazygit](https://github.com/jesseduffield/lazygit)",
        "- [ripgrep](https://github.com/BurntSushi/ripgrep)",
        "- [fd](https://github.com/sharkdp/fd)",
        "",
        "## Install Instructions",
        "",
        " > Install requires Neovim 0.10+. Always review the code before installing a configuration.",
        "",
        "Clone the repository and install the plugins:",
        "",
        "```sh",
        "git clone git@github.com:greggh/nvim ~/.config/greggh/nvim",
        "```",
        "",
        "Open Neovim with this config:",
        "",
        "```sh",
        "NVIM_APPNAME=greggh/nvim/ nvim",
        "```",
        "",
        "## 💤 Plugin manager",
        "",
        "- [lazy.nvim](https://github.com/folke/lazy.nvim)",
        "",
        "## 🔌 Plugins",
        "",
      }
      local plugins_md = {}
      for plugin, spec in pairs(plugins) do
        if spec.url then
          table.insert(plugins_md, ("- [%s](%s)"):format(plugin, spec.url:gsub("%.git$", "")))
        end
      end
      table.sort(plugins_md, function(a, b)
        return a:lower() < b:lower()
      end)

      for _, p in ipairs(plugins_md) do
        table.insert(file_content, p)
      end

      table.insert(file_content, "")

      local file, err = io.open(vim.fn.stdpath("config") .. "/README.md", "w")
      if not file then
        error(err)
      end
      file:write(table.concat(file_content, "\n"))
      file:close()
      vim.notify("README.md succesfully generated", vim.log.levels.INFO, {})
    end)
    :with_noremap()
    :with_silent()
    :with_desc("Code Actions"),
}

bind.nvim_load_mapping(readme_map)
