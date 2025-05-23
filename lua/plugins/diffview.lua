local function diffview_toggle()
  local lib = require("diffview.lib")
  local view = lib.get_current_view()
  if view then
    vim.cmd.DiffviewClose()
  else
    vim.cmd.DiffviewOpen()
  end
end

vim.api.nvim_create_user_command("Ns", function()
  vim.cmd([[
		execute 'vsplit | enew'
		setlocal buftype=nofile
		setlocal bufhidden=hide
		setlocal noswapfile
	]])
end, { nargs = 0 })

vim.api.nvim_create_user_command("ClipboardDiff", function()
  local ftype = vim.api.nvim_eval("&filetype")
  vim.cmd([[
		tabnew %
		Ns
		normal! P
		windo diffthis
	]])
  vim.cmd("set filetype=" .. ftype)
end, { nargs = 0 })

vim.api.nvim_create_user_command("ClipboardDiffSelection", function()
  vim.cmd([[
		normal! gv"zy
		execute 'tabnew | setlocal buftype=nofile bufhidden=hide noswapfile'
		normal! V"zp
		Ns
		normal! Vp
		windo diffthis
	]])
end, {
  nargs = 0,
  range = true,
})

return {
  "sindrets/diffview.nvim",
  event = { "BufReadPre", "BufNewFile" },
  cmd = { "DiffviewOpen", "DiffviewFileHistory" },
  opts = function()
    local actions = require("diffview.actions")

    return {
      enhanced_diff_hl = true,
      git = {
        signs = {
          fold_closed = "",
          fold_open = "",
          done = "✓",
        },
      },
      file_panel = {
        listing_style = "list", -- 'list', 'tree'
        tree_options = {
          flatten_dirs = true,
          folder_statuses = "only_folded", -- 'never', 'only_folded', 'always'.
        },
        win_config = {
          position = "left",
          width = 35,
          win_opts = {},
        },
      },
      hooks = {
        view_opened = function()
          local lib = require("diffview.lib")
          if lib.get_current_view() and lib.get_current_view().class:name() == "DiffView" then
            actions.toggle_files()
          end
        end,
      },
      --stylua: ignore
      keymaps = {
        disable_defaults = true,
        view = {
          { "n", "q", diffview_toggle, { desc = "Quit" } },
          { "n", "<Tab>", actions.select_next_entry, { desc = "Select next entry" } },
          { "n", "<S-Tab>", actions.select_prev_entry, { desc = "Select Previous entry" } },
          { "n", "<localleader>o", actions.goto_file_tab, { desc = "Open file" } },
          { "n", "<LocalLeader>e", actions.toggle_files, { desc = "Toggle Files" } },
        },
        file_panel = {
          { "n", "q", diffview_toggle, { desc = "Quit" } },
          { "n", "<cr>", actions.select_entry, { desc = "Select entry" } },
          { "n", "<right>", actions.select_entry, { desc = "Select entry" } },
          { "n", "l", actions.select_entry, { desc = "Select entry" } },
          { "n", "<tab>", actions.next_entry, { desc = "Select next entry" } },
          { "n", "<down>", actions.next_entry, { desc = "Select next entry" } },
          { "n", "j", actions.next_entry, { desc = "Select next entry" } },
          { "n", "<s-tab>", actions.prev_entry, { desc = "Select previous entry" } },
          { "n", "<up>", actions.prev_entry, { desc = "Select previous entry" } },
          { "n", "<k>", actions.prev_entry, { desc = "Select previous entry" } },
          { "n", "<localleader><localleader>", actions.toggle_stage_entry, { desc = "Stage entry" } },
          { "n", "<localleader>s", actions.stage_all, { desc = "Stage all" } },
          { "n", "<localleader>u", actions.unstage_all, { desc = "Unstage all" } },
          { "n", "<localleader>x", actions.restore_entry, { desc = "Restore entry to the state on the left side" } },
          { "n", "<localleader>o", actions.goto_file_tab, { desc = "Open file" } },
          { "n", "<localleader>r", actions.refresh_files, { desc = "Refresh" } },
          { "n", "<LocalLeader>e", actions.toggle_files, { desc = "Select Previous entry" } },
          { "n", "g?", actions.help("file_panel"), { desc = "Open the help panel" } },
        },
        file_history_panel = {
          { "n", "q", diffview_toggle, { desc = "Quit" } },
          { "n", "<cr>", actions.select_entry, { desc = "Select entry" } },
          { "n", "<right>", actions.select_entry, { desc = "Select entry" } },
          { "n", "l", actions.select_entry, { desc = "Select entry" } },
          { "n", "<tab>", actions.next_entry, { desc = "Select next entry" } },
          { "n", "<down>", actions.next_entry, { desc = "Select next entry" } },
          { "n", "j", actions.next_entry, { desc = "Select next entry" } },
          { "n", "<s-tab>", actions.prev_entry, { desc = "Select previous entry" } },
          { "n", "<up>", actions.prev_entry, { desc = "Select previous entry" } },
          { "n", "<k>", actions.prev_entry, { desc = "Select previous entry" } },
          { "n", "<localleader>o", actions.goto_file_tab, { desc = "Open file" } },
          { "n", "X", actions.restore_entry, { desc = "Restore file to the state from the selected entry" } },
          { "n", "g!", actions.options, { desc = "Open the option panel" } },
          { "n", "g?", actions.help("file_history_panel"), { desc = "Open the help panel" } },
        },
        help_panel = {
          { "n", "q", actions.close, { desc = "Close help menu" } },
          { "n", "<esc>", actions.close, { desc = "Close help menu" } },
        },
      },
    }
  end,
}
