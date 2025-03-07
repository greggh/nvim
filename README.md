<h1 align="center">
  <img src="https://raw.githubusercontent.com/neovim/neovim.github.io/master/logos/neovim-logo-300x87.png" alt="Neovim">
</h1>

<div align="center">

[![GitHub License](https://img.shields.io/github/license/greggh/nvim?style=flat-square)](https://github.com/greggh/nvim/blob/main/LICENSE)
[![GitHub Stars](https://img.shields.io/github/stars/greggh/nvim?style=flat-square)](https://github.com/greggh/nvim/stargazers)
[![GitHub Issues](https://img.shields.io/github/issues/greggh/nvim?style=flat-square)](https://github.com/greggh/nvim/issues)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/greggh/nvim?style=flat-square)](https://github.com/greggh/nvim/commits/main)
[![Neovim Version](https://img.shields.io/badge/Neovim-0.10%2B-blueviolet?style=flat-square&logo=neovim)](https://github.com/neovim/neovim/releases/tag/v0.10.0)
[![Version](https://img.shields.io/badge/Version-0.4.2-blue?style=flat-square)](https://github.com/greggh/nvim/releases/tag/v0.4.2)
[![MIT License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](https://github.com/greggh/nvim/blob/main/LICENSE)
[![Dotfyle](https://dotfyle.com/greggh/nvim/badges/plugins?style=flat-square)](https://dotfyle.com/greggh/nvim)
[![Dotfyle](https://dotfyle.com/greggh/nvim/badges/leaderkey?style=flat-square)](https://dotfyle.com/greggh/nvim)
[![Dotfyle](https://dotfyle.com/greggh/nvim/badges/plugin-manager?style=flat-square)](https://dotfyle.com/greggh/nvim)

![Neovim Screenshot](assets/readme/neovim.png)

*A modern, feature-rich Neovim configuration with a focus on productivity and developer experience*

[Features](#features) • 
[Requirements](#requirements) • 
[Installation](#installation) • 
[Key Bindings](#key-bindings) • 
[Screenshots](#screenshots) • 
[Plugins](#plugins) • 
[Contributing](#contributing) • 
[License](#license) • 
[Discussions](https://github.com/greggh/nvim/discussions)

</div>

## Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Key Bindings](#key-bindings)
- [Screenshots](#screenshots)
- [Plugins](#plugins)
- [Contributing](#contributing)
- [Development](#development)
- [License](#license)
- [Community](#community)
- [Acknowledgements](#acknowledgements)

## Features

- Modern and elegant UI with Catppuccin theme
- Powerful LSP integration for dozens of languages
- Treesitter-based syntax highlighting and text objects
- Fuzzy finding with Telescope and FZF
- Git integration with Gitsigns and Diffview
- Extensive debugging support via DAP
- Testing frameworks for multiple languages
- AI integration with Claude Code and Copilot
- Integrated terminal experience
- Comprehensive plugin ecosystem
- Advanced autocompletion and snippets
- Fast startup and responsive editing experience

## Requirements

- **[Neovim 0.10+](https://github.com/neovim/neovim/releases)** - Required for `vim.system()`, `splitkeep`, and modern LSP features
- **[Nerd Font](https://www.nerdfonts.com/)** - Required for icons
- External dependencies:
  - [lazygit](https://github.com/jesseduffield/lazygit) - Git TUI
  - [ripgrep](https://github.com/BurntSushi/ripgrep) - Fast grep
  - [fd](https://github.com/sharkdp/fd) - Fast find
  - [fzf](https://github.com/junegunn/fzf) - Fuzzy finder

## Installation

> ⚠️ **WARNING**: Always review the code before installing a configuration.

Clone the repository and install the plugins:

```sh
git clone git@github.com:greggh/nvim ~/.config/greggh/nvim
```

Open Neovim with this config:

```sh
NVIM_APPNAME=greggh/nvim/ nvim
```

Or set it as your default by copying to the standard location:

```sh
git clone git@github.com:greggh/nvim ~/.config/nvim
```

## Key Bindings

> 💡 Press `<Space>` to see available key bindings via which-key

| Category | Key Binding | Description |
|----------|-------------|-------------|
| **General** | `<C-s>` or `<leader>qs` | Save file |
| | `<C-q>` or `<leader>qq` | Quit |
| | `<leader>qz` | Force quit |
| **Navigation** | `<leader>e` | File explorer |
| | `<leader>ff` | Find files |
| | `<leader>fg` | Live grep |
| **Git** | `<leader>gg` | LazyGit |
| | `<leader>gl` | View git log |
| | `<leader>gb` | View git blame |
| **LSP** | `<leader>lo` | Toggle LSP outline |
| | `<leader>xw` | Find in workspace |
| | `<leader>ca` | Code actions |
| **Testing** | `<leader>tr` | Run nearest test |
| | `<leader>tt` | Run file tests |
| **AI** | `<leader>ac` | Toggle Claude Code (normal mode) |
| | `<C-o>` | Toggle Claude Code (terminal mode) |
| **Folding** | `<leader>z0` | Toggle level 0 |
| | `<leader>z1` | Toggle level 1 |
| | `<leader>z2` | Toggle level 2 |
| **Windows** | `<leader>wm` | Toggle maximize window |
| **Buffers** | `<leader>bw` | Close buffer safely |
| | `<leader>bo` | Close other buffers |
| **Treesitter** | `af/if` | Function text object |
| | `ac/ic` | Class text object |
| | `aa/ia` | Parameter text object |
| | `[f/]f` | Navigate between functions |
| | `[c/]c` | Navigate between classes |
| | `[a/]a` | Navigate between parameters |

For a complete list of keybindings, press `<Space>` to see the which-key popup menu.

## Screenshots

![Editor with Telescope](assets/readme/neovim.png)

*Main editor with Telescope file finder*

![Code with LSP](assets/readme/code-with-lsp.png)

*Code editing with LSP diagnostics*

![Terminal Integration](assets/readme/terminal.png)

*Integrated terminal experience*

## Plugins

This configuration uses [lazy.nvim](https://github.com/folke/lazy.nvim) as its plugin manager and includes many powerful plugins:

<details>
<summary>Click to expand plugin list</summary>

- [actions-preview.nvim](https://github.com/aznhe21/actions-preview.nvim)
- [auto-save.nvim](https://github.com/okuuva/auto-save.nvim)
- [avante.nvim](https://github.com/yetone/avante.nvim)
- [blink-ripgrep.nvim](https://github.com/mikavilpas/blink-ripgrep.nvim)
- [blink.cmp](https://github.com/saghen/blink.cmp)
- [blink.compat](https://github.com/saghen/blink.compat)
- [boole.nvim](https://github.com/nat-418/boole.nvim)
- [catppuccin](https://github.com/catppuccin/nvim)
- [ccc](https://github.com/uga-rosa/ccc.nvim)
- [claude-code.nvim](https://github.com/greggh/claude-code.nvim)
- [cmp-cmdline-history](https://github.com/dmitmel/cmp-cmdline-history)
- [Comment.nvim](https://github.com/numToStr/Comment.nvim)
- [conform.nvim](https://github.com/stevearc/conform.nvim)
- [copilot.lua](https://github.com/zbirenbaum/copilot.lua)
- [depsync.nvim](https://github.com/robertazzopardi/depsync.nvim)
- [diffview.nvim](https://github.com/sindrets/diffview.nvim)
- [dressing.nvim](https://github.com/stevearc/dressing.nvim)
- [dropbar.nvim](https://github.com/Bekaboo/dropbar.nvim)
- [edgy.nvim](https://github.com/folke/edgy.nvim)
- [flash.nvim](https://github.com/folke/flash.nvim)
- [friendly-snippets](https://github.com/rafamadriz/friendly-snippets)
- [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim)
- [grug-far.nvim](https://github.com/MagicDuck/grug-far.nvim)
- [hardtime.nvim](https://github.com/m4xshen/hardtime.nvim)
- [helpview.nvim](https://github.com/OXY2DEV/helpview.nvim)
- [highlight-undo.nvim](https://github.com/tzachar/highlight-undo.nvim)
- [img-clip.nvim](https://github.com/HakonHarnes/img-clip.nvim)
- [incline.nvim](https://github.com/b0o/incline.nvim)
- [iron.nvim](https://github.com/Vigemus/iron.nvim)
- [laravel-helper.nvim](https://github.com/greggh/laravel-helper.nvim)
- [lazy.nvim](https://github.com/folke/lazy.nvim)
- [lazydev.nvim](https://github.com/folke/lazydev.nvim)
- [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim)
- [LuaSnip](https://github.com/L3MON4D3/LuaSnip)
- [markview.nvim](https://github.com/OXY2DEV/markview.nvim)
- [mason-lspconfig.nvim](https://github.com/williamboman/mason-lspconfig.nvim)
- [mason-tool-installer.nvim](https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim)
- [mason.nvim](https://github.com/williamboman/mason.nvim)
- [mini.icons](https://github.com/echasnovski/mini.icons)
- [mini.sessions](https://github.com/echasnovski/mini.sessions)
- [mini.surround](https://github.com/echasnovski/mini.surround)
- [neotest-golang](https://github.com/fredrikaverpil/neotest-golang)
- [neotest-jest](https://github.com/nvim-neotest/neotest-jest)
- [neotest-pest](https://github.com/V13Axel/neotest-pest)
- [neotest-plenary](https://github.com/nvim-neotest/neotest-plenary)
- [neotest-python](https://github.com/nvim-neotest/neotest-python)
- [neotest-rust](https://github.com/rouge8/neotest-rust)
- [neotest-vitest](https://github.com/marilari88/neotest-vitest)
- [neotest](https://github.com/nvim-neotest/neotest)
- [noice.nvim](https://github.com/folke/noice.nvim)
- [nui.nvim](https://github.com/MunifTanjim/nui.nvim)
- [nvim-autopairs](https://github.com/windwp/nvim-autopairs)
- [nvim-dap-python](https://github.com/mfussenegger/nvim-dap-python)
- [nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui)
- [nvim-dap-virtual-text](https://github.com/theHamsta/nvim-dap-virtual-text)
- [nvim-dap](https://github.com/mfussenegger/nvim-dap)
- [nvim-lightbulb](https://github.com/kosayoda/nvim-lightbulb)
- [nvim-lint](https://github.com/mfussenegger/nvim-lint)
- [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)
- [nvim-nio](https://github.com/nvim-neotest/nvim-nio)
- [nvim-notify](https://github.com/rcarriga/nvim-notify)
- [nvim-treesitter-context](https://github.com/nvim-treesitter/nvim-treesitter-context)
- [nvim-treesitter-textobjects](https://github.com/nvim-treesitter/nvim-treesitter-textobjects)
- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
- [nvim-ts-autotag](https://github.com/windwp/nvim-ts-autotag)
- [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons)
- [one-small-step-for-vimkind](https://github.com/jbyuki/one-small-step-for-vimkind)
- [outline.nvim](https://github.com/hedyhli/outline.nvim)
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
- [quicker.nvim](https://github.com/stevearc/quicker.nvim)
- [rainbow-delimiters.nvim](https://github.com/HiPhish/rainbow-delimiters.nvim)
- [screenkey.nvim](https://github.com/NStefan002/screenkey.nvim)
- [smart-splits.nvim](https://github.com/mrjones2014/smart-splits.nvim)
- [snacks.nvim](https://github.com/folke/snacks.nvim)
- [suda](https://github.com/lambdalisue/suda.vim)
- [symbol-usage.nvim](https://github.com/Wansmer/symbol-usage.nvim)
- [tide.nvim](https://github.com/jackMort/tide.nvim)
- [tiny-inline-diagnostic.nvim](https://github.com/rachartier/tiny-inline-diagnostic.nvim)
- [todo-comments.nvim](https://github.com/folke/todo-comments.nvim)
- [treewalker.nvim](https://github.com/aaronik/treewalker.nvim)
- [trouble.nvim](https://github.com/folke/trouble.nvim)
- [which-key.nvim](https://github.com/folke/which-key.nvim)
- [workspace-diagnostics.nvim](https://github.com/artemave/workspace-diagnostics.nvim)
- [yazi.nvim](https://github.com/mikavilpas/yazi.nvim)

</details>

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines on how to contribute.

To get started:

1. Check the [open issues](https://github.com/greggh/nvim/issues) or create a new one
2. Fork the repository
3. Create a new branch for your feature
4. Make your changes
5. Run the tests (`make test`) and ensure they pass
6. Submit a pull request

## Development

This configuration includes a comprehensive testing framework and development tools:

- **Testing**: Run `make test` to execute all tests
- **Linting**: Run `make lint` to check code quality
- **Formatting**: Run `make format` to format Lua code
- **Git Hooks**: Run `./scripts/setup-hooks.sh` to set up pre-commit hooks
- **Automation**: 
  - Automated releases via the GitHub Actions workflow
  - Weekly dependency updates check via GitHub Actions
  - Comprehensive CI pipeline for testing all changes

For a complete development environment setup, see [DEVELOPMENT.md](DEVELOPMENT.md).

## License

[MIT License](LICENSE)

## Community

- [GitHub Discussions](https://github.com/greggh/nvim/discussions) - Get help, share ideas, and connect with other users
- [GitHub Issues](https://github.com/greggh/nvim/issues) - Report bugs or suggest features
- [GitHub Pull Requests](https://github.com/greggh/nvim/pulls) - Contribute to the project

## Acknowledgements

- [Neovim](https://neovim.io/) - The core editor this configuration enhances
- [lazy.nvim](https://github.com/folke/lazy.nvim) - Plugin manager that simplifies dependency management
- [which-key.nvim](https://github.com/folke/which-key.nvim) - Keybinding discovery tool
- [Treesitter](https://tree-sitter.github.io/tree-sitter/) - Parsing system for syntax highlighting and code navigation
- [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) - LSP configuration framework
- [Catppuccin](https://github.com/catppuccin/nvim) - The beautiful color scheme used in screenshots
- [Nerd Fonts](https://www.nerdfonts.com/) - Iconic fonts used throughout the UI
- [Semantic Versioning](https://semver.org/) - Versioning standard used in this project
- [Contributor Covenant](https://www.contributor-covenant.org/) - Code of Conduct standard
- [Keep a Changelog](https://keepachangelog.com/) - Changelog format
- [LuaCATS](https://luals.github.io/wiki/annotations/) - Type annotations for better IDE support
- [StyLua](https://github.com/JohnnyMorganz/StyLua) - Lua code formatter
- [Luacheck](https://github.com/lunarmodules/luacheck) - Lua static analyzer and linter
- [Dotfyle](https://dotfyle.com) - Neovim config discovery platform

---

<div align="center">
  <p>Made with ❤️ by <a href="https://github.com/greggh">Gregg Housh</a></p>
</div>