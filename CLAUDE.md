# Neovim Configuration Guidelines

## Requirements
- Neovim 0.10+ (required for vim.system(), splitkeep, modern LSP features)
- Nerd Font for icons
- External dependencies: ripgrep, fd, fzf, lazygit

## Configuration Notes
- Laravel Helper functionality has been moved to a standalone plugin
- The file lua/utils/php.lua can be safely removed as its functionality is now in the plugin

## Commands and Keybindings
- Leader key is <Space>
- Save: <C-s> or <leader>qs
- Quit: <C-q> or <leader>qq
- Force quit: <leader>qz
- File explorer: <leader>e
- LazyGit: <leader>gg
- Search and replace: <leader>r
- Toggle LSP outline: <leader>lo
- Find in workspace: <leader>xw
- Code actions: <leader>ca
- Run tests: <leader>tr (nearest), <leader>tt (file)
- Claude Code: <leader>ac (toggle in normal mode), <C-o> (toggle in terminal mode)
- Folding: <leader>z0 (toggle level 0), <leader>z1 (toggle level 1), <leader>z2 (toggle level 2)
- Window management: <leader>wm (toggle maximize window)
- Buffer management: <leader>bw (close buffer safely), <leader>bo (close all buffers except current)
- Treesitter text objects: af/if (function), ac/ic (class), aa/ia (parameter)
- Treesitter navigation: [f/]f (prev/next function), [c/]c (prev/next class), [a/]a (prev/next parameter)

## Code Style Guidelines
- Use 2 spaces for indentation (tabstop=2, shiftwidth=2)
- Plugin declarations use return table format with dependencies
- Keymap definitions use utils.keymap-bind utilities
- Group related functionality in subdirectories (e.g., plugins/ai/, plugins/debugger/)
- Use diagnostic disable comments when needed
- Comments use dashes for section separators (---------------------)

## Plugin Development
- Define plugins in lua/plugins/ directory
- Organize complex plugins in subdirectories
- Use lazy.nvim format: return { "author/plugin", config = function() ... end }
- Add new keybindings through bind.nvim_load_mapping()
- Register keybinding groups in which-key.lua

## Claude Code Settings
- Toggles: <leader>ac (normal mode), <C-o> (terminal mode)
- Window settings: 50% height at bottom of screen
- Git integration: Automatically uses git project root as CWD when available

## Git Commands
- `git -C /home/gregg/.config/nvim status` - Check current status
- `git -C /home/gregg/.config/nvim add .` - Stage all changes
- `git -C /home/gregg/.config/nvim commit -m "message"` - Commit changes
- `git -C /home/gregg/.config/nvim push` - Push changes

## Version Management
- Current version: v0.4.2
- Version file: `lua/config/version.lua`