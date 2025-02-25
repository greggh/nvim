# CLAUDE.md - Neovim Configuration Guidelines

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