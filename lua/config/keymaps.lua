local bind = require("utils.keymap-bind")
local map_cr = bind.map_cr
local map_cu = bind.map_cu
local map_cmd = bind.map_cmd
local map_callback = bind.map_callback

-- We'll load Snacks when we need it rather than at startup
local Snacks
local has_loaded_snacks = false

local function get_snacks()
  if not has_loaded_snacks then
    has_loaded_snacks = true
    Snacks = require("snacks")
  end
  return Snacks
end

local builtin_map = {
  -- Command mode tab completion ["c|<tab>"] = map_cmd("<C-z>"):with_noremap():with_desc("edit: Command completion"),

  -- fix stupid typo
  ["n|q:"] = map_cr("q"):with_noremap():with_silent():with_desc("edit: Quit"),

  -- Paste replace visual selection without yanking: https://vim.fandom.com/wiki/Pasting_over_visual_selection
  ["v|p"] = map_cmd('"_dP'):with_noremap():with_silent():with_desc("edit: Paste replace visual selection"),

  -- Easy insertion of a trailing ; or , from insert mode
  ["i|;;"] = map_cmd("<Esc>A;"):with_noremap():with_silent():with_desc("edit: Insert trailing semicolon"),
  ["i|,,"] = map_cmd("<Esc>A,"):with_noremap():with_silent():with_desc("edit: Insert trailing comma"),

  -- Quickly clear search highlights
  ["n|<leader>k"] = map_cr("nohlsearch"):with_noremap():with_silent():with_desc("edit: Clear search highlights"),

  -- Builtin: save & quit
  ["n|<leader>qs"] = map_cu("write"):with_noremap():with_silent():with_desc("edit: Save file"),
  ["n|<leader>qq"] = map_cr("wq"):with_desc("edit: Save file and quit"),
  ["n|<leader>qf"] = map_cr("qall!"):with_desc("edit: Force quit all (no save)"),
  ["n|<leader>qx"] = map_cr("wqall"):with_desc("edit: Save all and quit"),
  ["n|<C-s>"] = map_cu("write"):with_noremap():with_silent():with_desc("edit: Save file"),
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
  -- ["i|/"] = map_cmd("<Nop>"):with_noremap():with_silent():with_desc(""),
  ["n|Y"] = map_cmd("y$"):with_desc("edit: Yank text to EOL"),
  ["n|D"] = map_cmd("d$"):with_desc("edit: Delete text to EOL"),
  ["n|n"] = map_cmd("nzzzv"):with_noremap():with_desc("edit: Next search result"),
  ["n|N"] = map_cmd("Nzzzv"):with_noremap():with_desc("edit: Prev search result"),
  ["n|J"] = map_cmd("mzJ`z"):with_noremap():with_desc("edit: Join next line"),
  ["n|<S-Tab>"] = map_cr("normal za"):with_noremap():with_silent():with_desc("edit: Toggle code fold"),

  -- Builtin: terminal
  ["t|<C-w>h"] = map_cr("wincmd h"):with_silent():with_noremap():with_desc("window: Focus left"),
  ["t|<C-w>l"] = map_cr("wincmd l"):with_silent():with_noremap():with_desc("window: Focus right"),
  ["t|<C-w>j"] = map_cr("wincmd j"):with_silent():with_noremap():with_desc("window: Focus down"),
  ["t|<C-w>k"] = map_cr("wincmd k"):with_silent():with_noremap():with_desc("window: Focus up"),

  -- Builtin: tab
  ["n|<leader>wtn"] = map_cr("tabnew"):with_noremap():with_silent():with_desc("tab: Create a new tab"),
  ["n|<leader>wth"] = map_cr("tabnext"):with_noremap():with_silent():with_desc("tab: Move to next tab"),
  ["n|<leader>wtl"] = map_cr("tabprevious"):with_noremap():with_silent():with_desc("tab: Move to previous tab"),
  ["n|<leader>wtc"] = map_cr("tabonly"):with_noremap():with_silent():with_desc("tab: Only keep current tab"),
}

-- Load essential keymaps immediately (save and quit)
local essential_keymaps = {
  ["n|<leader>qs"] = builtin_map["n|<leader>qs"],
  ["n|<leader>qq"] = builtin_map["n|<leader>qq"],
  ["n|<C-s>"] = builtin_map["n|<C-s>"],
}
bind.nvim_load_mapping(essential_keymaps)

-- Defer loading of other builtin keymaps
vim.defer_fn(function()
  bind.nvim_load_mapping(builtin_map)
end, 10)

local plug_map = {
  -- Plugin: avante
  -- Avante's keybindings are built into the plugin itself or in avante-prompts.lua

  ["nt|<C-,>"] = map_cmd("<CMD>ClaudeCode<CR>"):with_noremap():with_silent():with_desc("Claude Code: Toggle"),

  -- Plugin: conform.nvim
  ["n|<leader>cf"] = map_callback(function()
      require("conform").format({ async = true, lsp_format = "fallback" })
    end)
    :with_noremap()
    :with_silent()
    :with_desc("Format buffer"),
  ["n|<leader>cF"] = map_callback(function()
      require("conform").format({ formatters = { "trim_whitespace", "trim_newlines" } })
    end)
    :with_noremap()
    :with_silent()
    :with_desc("Format buffer (whitespace only)"),

  -- Plugin: tide
  ["n|<leader>'"] = map_cr("lua require('tide.api').toggle_panel()")
    :with_noremap()
    :with_silent()
    :with_desc("Tide: Open"),

  -- Plugin: snacks
  ["n|<leader>e"] = map_callback(function()
      ---@diagnostic disable-next-line: missing-fields
      get_snacks().explorer({ cwd = vim.fs.root(0, { ".git" }) })
    end)
    :with_noremap()
    :with_silent()
    :with_desc("Picker: Explorer"),
  ["n|-"] = map_callback(function()
      require("utils.snacks.scratch").new_scratch()
    end)
    :with_noremap()
    :with_silent()
    :with_desc("Scratch: New Scratchpad"),
  ["n|_"] = map_callback(function()
      require("utils.snacks.scratch").select_scratch()
    end)
    :with_noremap()
    :with_silent()
    :with_desc("Scratch: Open Existing"),

  -- Plugin: yazi
  ["n|<leader>f/"] = map_cr("Yazi"):with_noremap():with_silent():with_desc("Yazi: Current file"),
  ["n|<leader>f-"] = map_cr("Yazi cwd")
    :with_noremap()
    :with_silent()
    :with_desc("Yazi: nvim working directory"),
  ["n|<leader>f\\"] = map_cr("Yazi toggle")
    :with_noremap()
    :with_silent()
    :with_desc("Yazi: Resume last session"),

  -- Plugin: lazy
  ["n|<leader>pl"] = map_cr("Lazy sync"):with_noremap():with_silent():with_desc("✓ Lazy: Sync"),

  -- Plugin: Mason
  ["n|<leader>pm"] = map_cr("Mason"):with_noremap():with_silent():with_desc("Mason: Toggle"),

  -- Plugin: flags
  ["n|<leader>F"] = map_cr("Flags"):with_noremap():with_silent():with_desc("Flags"),

  -- Plugin: buffer
  ["n|<leader><tab>"] = map_cr("b#"):with_noremap():with_silent():with_desc("Buffer: Switch back & forth"),
  ["n|<leader>b["] = map_cr("bp"):with_noremap():with_silent():with_desc("Buffer: Previous"),
  ["n|<leader>b]"] = map_cr("bn"):with_noremap():with_silent():with_desc("Buffer: Next"),

  -- Plugin: move lines
  ["n|<c-a-j>"] = map_cmd("<CMD>m .+1<CR>=="):with_noremap():with_silent():with_desc("Move: Line down"),
  ["n|<c-a-k>"] = map_cmd("<CMD>m .-2<CR>=="):with_noremap():with_silent():with_desc("Move: Line up"),
  ["i|<c-a-j>"] = map_cmd("<Esc><CMD>m .+1<CR>==gi"):with_noremap():with_silent():with_desc("Move: Line down"),
  ["i|<c-a-k>"] = map_cmd("<Esc><CMD>m .-2<CR>==gi"):with_noremap():with_silent():with_desc("Move: Line up"),
  ["v|<c-a-j>"] = map_cmd("<ESC><CMD>'<,'>m '>+1<CR>gv=gv"):with_noremap():with_silent():with_desc("Move: Line down"),
  ["v|<c-a-k>"] = map_cmd("<ESC><CMD>'<,'>m '<-2<CR>gv=gv"):with_noremap():with_silent():with_desc("Move: Line up"),

  -- Plugin: ccc
  ["n|<leader>cp"] = map_cr("CccPick"):with_noremap():with_silent():with_desc("Color Picker"),
  ["i|<C-c>"] = map_cr("CccPick"):with_noremap():with_silent():with_desc("Color Picker"),

  -- Plugin Lazygit
  ["n|<leader>gg"] = map_callback(function()
      local snacks = get_snacks()
      if require("utils.git").is_git_repo() then
        ---@diagnostic disable-next-line: missing-fields
        snacks.lazygit({ cwd = require("utils.git").get_git_root() })
      elseif vim.bo.filetype == "snacks_dashboard" then
        ---@diagnostic disable-next-line: missing-fields, assign-type-mismatch
        snacks.lazygit({ cwd = vim.fn.stdpath("config") })
      else
        print("You're not in a git repository")
      end
    end)
    :with_noremap()
    :with_silent()
    :with_desc("Lazygit"),

  ["n|<leader>gl"] = map_callback(function()
      local snacks = get_snacks()
      if require("utils.git").is_git_repo() then
        ---@diagnostic disable-next-line: missing-fields
        snacks.lazygit.log({ cwd = require("utils.git").get_git_root() })
      elseif vim.bo.filetype == "snacks_dashboard" then
        ---@diagnostic disable-next-line: missing-fields, assign-type-mismatch
        snacks.lazygit.log({ cwd = vim.fn.stdpath("config") })
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
  ["n|<C-h>"] = map_cu("wincmd h"):with_silent():with_noremap():with_desc("window: Focus left"),
  ["n|<C-j>"] = map_cu("wincmd j"):with_silent():with_noremap():with_desc("window: Focus down"),
  ["n|<C-k>"] = map_cu("wincmd k"):with_silent():with_noremap():with_desc("window: Focus up"),
  ["n|<C-l>"] = map_cu("wincmd l"):with_silent():with_noremap():with_desc("window: Focus right"),
  ["n|<leader>wh"] = map_cu("SmartSwapLeft"):with_silent():with_noremap():with_desc("window: Move window left"),
  ["n|<leader>wj"] = map_cu("SmartSwapDown"):with_silent():with_noremap():with_desc("window: Move window down"),
  ["n|<leader>wk"] = map_cu("SmartSwapUp"):with_silent():with_noremap():with_desc("window: Move window up"),
  ["n|<leader>wl"] = map_cu("SmartSwapRight"):with_silent():with_noremap():with_desc("window: Move window right"),

  -- Plugin: boole.nvim
  ["n|<C-n>"] = map_cr("Boole increment"):with_noremap():with_silent():with_desc("Boole: Increment"),
  ["n|<C-m>"] = map_cr("Boole decrement"):with_noremap():with_silent():with_desc("Boole: Decrement"),

  -- Plugin: flash
  ["nxo|s"] = map_cmd("<CMD>lua require('flash').jump()<CR>"):with_noremap():with_silent():with_desc("Flash"),

  -- Plugin: gitsigns
  ["n|<leader>gb"] = map_cr("Gitsigns toggle_current_line_blame")
    :with_noremap()
    :with_silent()
    :with_desc("Gitsigns: Toggle current line blame"),
  ["n|<leader>gs"] = map_cr("Gitsigns stage_hunk")
    :with_noremap()
    :with_silent()
    :with_desc("Gitsigns: Stage hunk"),
  ["n|<leader>gu"] = map_cr("Gitsigns undo_stage_hunk")
    :with_noremap()
    :with_silent()
    :with_desc("Gitsigns: Undo stage hunk"),
  ["n|<leader>gt"] = map_cr("Gitsigns toggle_signs")
    :with_noremap()
    :with_silent()
    :with_desc("Gitsigns: Toggle signs"),
  ["n|<leader>gi"] = map_cr("Gitsigns preview_hunk_inline")
    :with_noremap()
    :with_silent()
    :with_desc("Gitsigns: Preview hunk inline"),
  ["n|<leader>gr"] = map_cr("Gitsigns reset_hunk")
    :with_noremap()
    :with_silent()
    :with_desc("Gitsigns: Reset hunk"),
  ["n|<leader>gR"] = map_cr("Gitsigns reset_buffer")
    :with_noremap()
    :with_silent()
    :with_desc("Gitsigns: Reset buffer"),
  ["n|<leader>gp"] = map_cr("Gitsigns preview_hunk")
    :with_noremap()
    :with_silent()
    :with_desc("Gitsigns: Preview hunk"),
  ["n|<leader>g]"] = map_cr("Gitsigns next_hunk")
    :with_noremap()
    :with_silent()
    :with_desc("Gitsigns: Next hunk"),
  ["n|<leader>g["] = map_cr("Gitsigns prev_hunk")
    :with_noremap()
    :with_silent()
    :with_desc("Gitsigns: Prev hunk"),

  -- Plugin: diffview.nvim
  ["n|<leader>gh"] = map_cr("DiffviewFileHistory")
    :with_noremap()
    :with_silent()
    :with_desc("Diff branch history"),
  ["n|<leader>gd"] = map_cr("DiffviewFileHistory --follow %")
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
  ["n|<leader>gx"] = map_cr("ClipboardDiff"):with_noremap():with_silent():with_desc("Diff clipboard"),
  ["v|<leader>gx"] = map_cmd("<ESC><CMD>ClipboardDiffSelection<CR>")
    :with_noremap()
    :with_silent()
    :with_desc("Diff clipboard Selection"),

  -- Plugin: auto-save.nvim
  ["n|<leader>oa"] = map_cr("ASToggle"):with_noremap():with_silent():with_desc("Toggle auto save"),

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
  ["n|<leader>lo"] = map_cr("Outline"):with_noremap():with_silent():with_desc("Toggle Outline"),

  -- Plugin: Suda
  ["n|<leader>qS"] = map_cr("Suda w"):with_noremap():with_silent():with_desc("Suda: Write"),
  ["n|<leader>qv"] = map_cr("Suda wq"):with_noremap():with_silent():with_desc("Suda: Write and quit"),
  ["n|<leader>qa"] = map_cr("Suda wqa"):with_noremap():with_silent():with_desc("Suda: Write and quit all"),

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
      get_snacks().picker.todo_comments()
    end)
    :with_noremap()
    :with_silent()
    :with_desc("Todo Comments: show TODO"),

  -- Plugin: treewalker
  ["n|<a-s-j>"] = map_cr("Treewalker Down"):with_noremap():with_silent():with_desc("Treewalker Down"),
  ["n|<a-s-k>"] = map_cr("Treewalker Up"):with_noremap():with_silent():with_desc("Treewalker Up"),
  ["n|<a-s-h>"] = map_cr("Treewalker Left"):with_noremap():with_silent():with_desc("Treewalker Left"),
  ["n|<a-s-l>"] = map_cr("Treewalker Right"):with_noremap():with_silent():with_desc("Treewalker Right"),

  -- Plugin: Trouble
  ["n|<leader>xw"] = map_cr("Trouble diagnostics toggle")
    :with_noremap()
    :with_silent()
    :with_desc("Trouble: workspace diagnostics"),
  ["n|<leader>xx"] = map_cr("Trouble diagnostics toggle filter.buf=0")
    :with_noremap()
    :with_silent()
    :with_desc("Trouble: document diagnostics"),
  ["n|<leader>xq"] = map_cr("Trouble quickfix toggle")
    :with_noremap()
    :with_silent()
    :with_desc("Trouble: quickfix list"),
  ["n|<c-q>"] = map_cmd("<CMD>Trouble quickfix toggle<CR>")
    :with_noremap()
    :with_silent()
    :with_desc("Trouble: quickfix list"),
  ["n|<leader>xl"] = map_cr("Trouble loclist toggle")
    :with_noremap()
    :with_silent()
    :with_desc("Trouble: location list"),
  ["n|<leader>xt"] = map_cr("Trouble todo toggle"):with_noremap():with_silent():with_desc("Trouble: TODO"),
  ["n|<leader>xs"] = map_cr("Trouble symbols toggle win.position=right")
    :with_noremap()
    :with_silent()
    :with_desc("Trouble: Symbols"),
  ["n|<leader>xp"] = map_cr("Trouble lsp toggle win.position=right")
    :with_noremap()
    :with_silent()
    :with_desc("Trouble: LSP"),

  -- Plugin: actions-preview
  ["nv|<leader>ca"] = map_callback(function()
      require("actions-preview").code_actions()
    end)
    :with_noremap()
    :with_silent()
    :with_desc("Code Actions"),

  -- Plugin: snacks rename
  ["n|<leader>fR"] = map_callback(function()
      get_snacks().rename.rename_file()
    end)
    :with_noremap()
    :with_silent()
    :with_desc("Rename file"),

  -- Plugin: screenkey
  ["n|<leader>ckt"] = map_cr("Screenkey"):with_noremap():with_silent():with_desc("Screenkey: Toggle"),
  ["n|<leader>ckr"] = map_callback(function()
      require("screenkey").redraw()
    end)
    :with_noremap()
    :with_silent()
    :with_desc("Screenkey: Redraw"),
}

-- Defer loading of plugin keymaps
vim.defer_fn(function()
  bind.nvim_load_mapping(plug_map)
end, 20)

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

  -- Misc: toggle inlay hints
  ["n|<leader>oi"] = map_callback(function()
      local current_state = vim.lsp.inlay_hint.is_enabled()
      local icon = current_state and " " or " "
      local message = current_state and "Inlay hints disabled" or "Inlay hints enabled"
      vim.lsp.inlay_hint.enable(not current_state)
      print(icon .. " " .. message)
    end)
    :with_noremap()
    :with_silent()
    :with_desc("Toggle inlay hints"),

  -- Removed HelpView keymap - plugin functionality not needed

  -- Plugin: dropbar
  ["n|<leader>;"] = map_callback(function()
      require("dropbar.api").pick()
    end)
    :with_noremap()
    :with_silent()
    :with_desc("Pick symbols in winbar"),
  ["n|[;"] = map_callback(function()
      require("dropbar.api").goto_context_start()
    end)
    :with_noremap()
    :with_silent()
    :with_desc("Go to start of current context"),
  ["n|];"] = map_callback(function()
      require("dropbar.api").select_next_context()
    end)
    :with_noremap()
    :with_silent()
    :with_desc("Select next context"),

  -- Folding controls
  ["n|<leader>z0"] = map_callback(function()
      require("utils.ui").toggle_fold_level(0)
    end)
    :with_noremap()
    :with_silent()
    :with_desc("Toggle level 0 folds"),
  ["n|<leader>z1"] = map_callback(function()
      require("utils.ui").toggle_fold_level(1)
    end)
    :with_noremap()
    :with_silent()
    :with_desc("Toggle level 1 folds"),
  ["n|<leader>z2"] = map_callback(function()
      require("utils.ui").toggle_fold_level(2)
    end)
    :with_noremap()
    :with_silent()
    :with_desc("Toggle level 2 folds"),

  -- Enhanced window management
  ["n|<leader>wm"] = map_callback(function()
      require("utils.ui").maximize_current_split()
    end)
    :with_noremap()
    :with_silent()
    :with_desc("Window: Toggle maximize"),

  -- Enhanced buffer management
  ["n|<C-PageDown>"] = map_cmd("<CMD>bn<CR>"):with_noremap():with_silent():with_desc("Buffer: Next"),
  ["n|<C-PageUp>"] = map_cmd("<CMD>bp<CR>"):with_noremap():with_silent():with_desc("Buffer: Previous"),
  ["n|<leader>bw"] = map_callback(function()
      -- Only delete buffer when not last
      if #vim.fn.getbufinfo({ buflisted = 1 }) > 1 then
        vim.cmd("bd")
      else
        require("utils.ui").notify_operation_status("Buffer close", "warning", "Cannot close last buffer")
      end
    end)
    :with_noremap()
    :with_silent()
    :with_desc("Buffer: Close (safe)"),
  ["n|<leader>bo"] = map_callback(function()
      -- Close all buffers except current
      vim.cmd("%bd|e#|bd#")
      require("utils.ui").notify_operation_status("Buffers", "success", "Closed all except current")
    end)
    :with_noremap()
    :with_silent()
    :with_desc("Buffer: Close all except current"),

  -- Profiling and diagnostics
  ["n|<leader>pp"] = map_cr("Profile")
    :with_noremap()
    :with_silent()
    :with_desc("Generate detailed profile report"),
  ["n|<leader>ps"] = map_cr("ProfileSummary"):with_noremap():with_silent():with_desc("Show profile summary"),
  ["n|<leader>pL"] = map_cr("ProfileLogs"):with_noremap():with_silent():with_desc("List profile logs"),
  ["n|<leader>pa"] = map_cr("ProfilePlugins")
    :with_noremap()
    :with_silent()
    :with_desc("Analyze plugin performance"),
  ["n|<leader>pc"] = map_cr("ProfileClean"):with_noremap():with_silent():with_desc("Clean up profile logs"),
}

-- Defer loading of miscellaneous keymaps
vim.defer_fn(function()
  bind.nvim_load_mapping(misc_map)
end, 30)

-- Lazy load which-key registrations
vim.defer_fn(function()
  -- Skip entirely in test mode
  if vim.g._disable_which_key then
    return
  end

  -- Use pcall to handle when which-key isn't available
  local status, wk = pcall(require, "which-key")
  if not status or not wk or type(wk.add) ~= "function" then
    vim.notify("which-key not available or missing add method", vim.log.levels.WARN)
    return
  end

  -- Register keymap descriptions with which-key in batches
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
end, 40)

-- Add icons to everything in which-key (deferred loading)
vim.defer_fn(function()
  -- Skip entirely in test mode
  if vim.g._disable_which_key then
    return
  end

  -- Use pcall to handle when which-key isn't available
  local status, wk = pcall(require, "which-key")
  if not status or not wk or type(wk.add) ~= "function" then
    vim.notify("which-key not available or missing add method for icon registration", vim.log.levels.WARN)
    return
  end

  wk.add({
    mode = "n",
    -- Claude Code keymaps are now handled by the plugin
    { "<leader>'", desc = "Tide: Open", icon = "󰁕" },
    { "<leader>e", desc = "Picker: Explorer", icon = "" },
    { "<leader>f/", desc = "Yazi: Current file", icon = "" },
    { "<leader>f-", desc = "Yazi: nvim working directory", icon = "󰘦" },
    { "<leader>f\\", desc = "Yazi: Resume first session", icon = "↺" },
    { "<leader>-", desc = "Scratch: New Scratchpad", icon = "📝" },
    { "<leader>_", desc = "Scratch: Open Existing", icon = "📂" },
    { "<leader>nn", desc = "Notification history", icon = "🔔" },
    { "<leader>nd", desc = "Dismiss notifications", icon = "🔕" },
    { "<leader>fp", desc = "Picker: Projects", icon = "📁" },
    { "<leader>gB", desc = "Git browse", icon = "🔍" },
    { "<leader>pl", desc = "✓ Lazy: Sync", icon = "󰒲" },
    { "<leader>pp", desc = "Profile: Generate report", icon = "📊" },
    { "<leader>ps", desc = "Profile: Show summary", icon = "📈" },
    { "<leader>pL", desc = "Profile: List logs", icon = "📋" },
    { "<leader>pa", desc = "Profile: Analyze plugins", icon = "🔍" },
    { "<leader>pc", desc = "Profile: Clean logs", icon = "🧹" },
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

  -- Register folding keymaps with which-key
  wk.add({
    mode = "n",
    { "<leader>z0", desc = "Toggle level 0 folds", icon = "󰈔" },
    { "<leader>z1", desc = "Toggle level 1 folds", icon = "󰈕" },
    { "<leader>z2", desc = "Toggle level 2 folds", icon = "󰈖" },
  })

  -- Register formatting keymaps with which-key
  wk.add({
    mode = "n",
    { "<leader>cf", desc = "Format buffer", icon = "󰁨" },
    { "<leader>cF", desc = "Format buffer (whitespace only)", icon = "󰗈" },
  })

  -- Register window/buffer management keymaps with which-key
  wk.add({
    mode = "n",
    { "<leader>wm", desc = "Toggle maximize window", icon = "󰆟" },
    { "<leader>bw", desc = "Close buffer (safe)", icon = "󰅖" },
    { "<leader>bo", desc = "Close all buffers except current", icon = "󰆐" },
  })

  -- Register IDE view toggle
  wk.add({
    mode = "n",
    { "<C-a>", desc = "Toggle IDE view", icon = "󰨞" },
  })

  -- Register dropbar
  wk.add({
    mode = "n",
    { "<leader>;", desc = "Pick symbols in winbar", icon = "󰓡" },
    { "[;", desc = "Go to start of current context", icon = "󰁍" },
    { "];", desc = "Select next context", icon = "󰁔" },
  })

  -- Register helpview
  wk.add({
    mode = "n",
    { "<leader>hh", desc = "Help: Toggle enhanced view", icon = "󰋖" },
  })

  -- Register Inlay hints toggle
  wk.add({
    mode = "n",
    { "<leader>oi", desc = "Toggle inlay hints", icon = "󰌵" },
  })
end, 50)

-- stylua: ignore start
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
      "- [fzf](https://github.comjunegunn/fzf)",
      "",
      "## Install Instructions",
      "",
      " > **REQUIRES NEOVIM 0.10+**. This configuration uses several Neovim 0.10+ exclusive features including:",
      " > - `vim.system()` for async operations",
      " > - `splitkeep` option for better window management",
      " > - Updated LSP handlers and APIs",
      " > - Modern UI capabilities",
      " >",
      " > Always review the code before installing a configuration.",
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
      "## Contributing",
      "",
      "Contributions are welcome! If you'd like to help improve this configuration:",
      "",
      "1. Check the [open issues](https://github.com/greggh/nvim/issues) or create a new one to discuss your idea",
      "2. Fork the repository",
      "3. Create a new branch for your feature",
      "4. Make your changes",
      "5. Run the tests (`make test`) and ensure they pass",
      "6. Submit a pull request",
      "",
      "Please read [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines on how to contribute and [DEVELOPMENT.md](DEVELOPMENT.md) for development setup instructions.",
      "",
      "## Development",
      "",
      "This configuration includes a testing framework and development tools:",
      "",
      "- **Testing**: Run `make test` to execute all tests",
      "- **Linting**: Run `make lint` to check code quality",
      "- **Formatting**: Run `make format` to format Lua code",
      "- **Git Hooks**: Run `./scripts/setup-hooks.sh` to set up pre-commit hooks",
      "",
      "For a complete development environment setup, see [DEVELOPMENT.md](DEVELOPMENT.md).",
      "",
      "## 💤 Plugin manager",
      "",
      "- [lazy.nvim](https://github.com/folke/lazy.nvim)",
      "",
      "## 🔌 Plugins",
      "",
-- stylua: ignore end
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
    :with_desc("Generate README.md"),
}

-- Load with small delay after the core keymaps
vim.defer_fn(function()
  bind.nvim_load_mapping(readme_map)
end, 60)
