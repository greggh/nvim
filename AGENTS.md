# AGENTS.md

This document provides essential information for AI agents working on nvim config.

## Configuration Overview

- **Config**: Coding-focused Neovim configuration
- **Path**: `~/.config/nvim`
- **Neovim Version**: 0.10+
- **Plugin Manager**: lazy.nvim
- **Keymap System**: utils/keymap-bind.lua with which-key integration

## Keymap Patterns

Always use `map_cr` for command-based keymaps instead of `map_cmd`:

```lua
-- ✅ CORRECT
["n|<leader>k"] = map_cr("nohlsearch")

-- ❌ INCORRECT (verbose)
["n|<leader>k"] = map_cmd(":nohlsearch<CR>")
```

## Plugin Architecture

The configuration is modular with plugins in `lua/plugins/` directory. Each plugin
has its own file. Snacks plugins are organized in `lua/plugins/snacks/` subdirectory.

## Recent Session Context

### Session: Keymap Refactoring & Plugin Cleanup (2025-01-XX)

**Major Changes Made:**
1. Refactored 30+ keymaps from `map_cmd` to `map_cr`
   - Terminal navigation (t|<C-w>h, etc.)
   - Tab management (wtn, wth, wtl, wtc)
   - Gitsigns (gb, gs, gu, etc.)
   - Yazi (f/, f-, f\)
   - Tide, Outline, Screenkey, Suda
   - Profiling keymaps
2. Fixed scratch system bugs in `lua/utils/snacks/scratch.lua`
   - Removed `filetypes` parameter from `new_scratch()`
   - Removed entire filetype picker code (simplified to plaintext)
   - Changed delete key from `<c-x>` to `<c-d>` (align with nvim-writer)
   - Fixed delete action to remove file directly instead of looping
3. Simplified `lua/plugins/snacks/scratch.lua` to opts configuration only
   - Aligned with nvim-writer implementation
   - Removed keymap definitions (moved to keymaps.lua)
   - Set default filetype to `plaintext`
4. Verified snacks terminal module exists with good configuration
   - Found in `lua/plugins/snacks/terminal.lua`
   - Already has proper keymaps and opts configuration
5. Removed mini.icons plugin
   - File marked as deleted in `lua/plugins/mini-icons.lua`
   - Updated lualine dependency from mini.icons to nvim-web-devicons
6. Added which-key entries for snacks plugins
   - Scratch: New (`-`), Open Existing (`_`)
   - Notifications: History (`nn`), Dismiss (`nd`)
   - Picker: Projects (`fp`)
   - Git browse (`gB`)

**Files Modified:**
- `lua/config/keymaps.lua` - Refactored 25+ keymaps to use map_cr
- `lua/utils/snacks/scratch.lua` - Fixed bugs, simplified, changed delete key
- `lua/plugins/snacks/scratch.lua` - Simplified to opts configuration
- `lua/plugins/lualine.lua` - Changed dependency to nvim-web-devicons
- `lua/plugins/mini-icons.lua` - Marked as deleted (replaced by nvim-web-devicons)

**Files Verified (No Changes Needed):**
- `lua/plugins/snacks/terminal.lua` - Already exists with great configuration
- `lua/plugins/mini-files.lua` - Does not exist (already removed previously)

**Key Learning:**
- Always use `map_cr` for command-based keymaps - cleaner syntax
- Scratch system simplified from nvim-writer removes complexity
- Both `<leader>xq` and `<c-q>` keymaps serve different purposes (which-key vs quick access)
- Single icon library (nvim-web-devicons) is sufficient
- All plugins verified as actively used (neotest, treewalker, etc.)

**Decisions Made:**
- Removed filetype picker for scratch buffers (user preference for simpler approach)
- Changed scratch delete key from `<c-x>` to `<c-d>` (user preference)
- Kept both `<leader>xq` and `<c-q>` Trouble keymaps (they serve different purposes)
- Did NOT add LTeX LSP (not needed in coding config)

**Testing Checklist:**
- [ ] Test refactored keymaps (q:, terminal navigation, tabs, gitsigns, yazi)
- [ ] Test scratch system (new scratch: `-`, open existing: `_`, delete with `<c-d>`)
- [ ] Test snacks terminal toggle (`<C-T>`)
- [ ] Verify which-key displays correctly with new icons
- [ ] Run `:Lazy clean` to remove unused mini.icons
- [ ] Run `:Lazy sync` to update dependencies
- [ ] Test lualine works with nvim-web-devicons
