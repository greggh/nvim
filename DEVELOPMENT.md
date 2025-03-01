# Development Guide for Neovim Configuration

This document outlines the development workflow, testing setup, and requirements for working with this Neovim configuration.

## Requirements

### Core Dependencies

- **Neovim**: Version 0.10.0 or higher
  - Required for `vim.system()`, splitkeep, and modern LSP features
- **Git**: For version control
- **Make**: For running development commands

### Development Tools

- **stylua**: Lua code formatter
- **luacheck**: Lua linter
- **ripgrep**: Used for searching (optional but recommended)
- **fd**: Used for finding files (optional but recommended)

## Installation Instructions

### Linux

#### Ubuntu/Debian

```bash
# Install Neovim (from PPA for latest version)
sudo add-apt-repository ppa:neovim-ppa/unstable
sudo apt-get update
sudo apt-get install neovim

# Install luarocks and other dependencies
sudo apt-get install luarocks ripgrep fd-find git make

# Install luacheck
sudo luarocks install luacheck

# Install stylua
curl -L -o stylua.zip $(curl -s https://api.github.com/repos/JohnnyMorganz/StyLua/releases/latest | grep -o "https://.*stylua-linux-x86_64.zip")
unzip stylua.zip
chmod +x stylua
sudo mv stylua /usr/local/bin/
```

#### Arch Linux

```bash
# Install dependencies
sudo pacman -S neovim luarocks ripgrep fd git make

# Install luacheck
sudo luarocks install luacheck

# Install stylua (from AUR)
yay -S stylua
```

#### Fedora

```bash
# Install dependencies
sudo dnf install neovim luarocks ripgrep fd-find git make

# Install luacheck
sudo luarocks install luacheck

# Install stylua
curl -L -o stylua.zip $(curl -s https://api.github.com/repos/JohnnyMorganz/StyLua/releases/latest | grep -o "https://.*stylua-linux-x86_64.zip")
unzip stylua.zip
chmod +x stylua
sudo mv stylua /usr/local/bin/
```

### macOS

```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install dependencies
brew install neovim luarocks ripgrep fd git make

# Install luacheck
luarocks install luacheck

# Install stylua
brew install stylua
```

### Windows

#### Using scoop

```powershell
# Install scoop if not already installed
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression

# Install dependencies
scoop install neovim git make ripgrep fd

# Install luarocks
scoop install luarocks

# Install luacheck
luarocks install luacheck

# Install stylua
scoop install stylua
```

#### Using chocolatey

```powershell
# Install chocolatey if not already installed
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install dependencies
choco install neovim git make ripgrep fd

# Install luarocks
choco install luarocks

# Install luacheck
luarocks install luacheck

# Install stylua (download from GitHub)
# Visit https://github.com/JohnnyMorganz/StyLua/releases
```

## Development Workflow

### Setting Up the Environment

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/neovim-config.git ~/.config/nvim
   ```

2. Install Git hooks:
   ```bash
   cd ~/.config/nvim
   ./scripts/setup-hooks.sh
   ```

### Common Development Tasks

- **Run tests**: `make test`
- **Run linting**: `make lint`
- **Format code**: `make format`
- **View available commands**: `make help`

### Pre-commit Hooks

The pre-commit hook automatically runs:
1. Code formatting with stylua
2. Linting with luacheck
3. Basic tests

If you need to bypass these checks, use:
```bash
git commit --no-verify
```

## Testing

### Running Tests

```bash
# Run all tests
make test

# Run with verbose output
make test-verbose

# Run specific test suites
make test-basic
make test-config
```

### Writing Tests

Tests are written in Lua using a simple BDD-style API:

```lua
local test = require("tests.run_tests")

test.describe("Feature name", function()
  test.it("should do something", function()
    -- Test code
    test.expect(result).to_be(expected)
  end)
end)
```

## Continuous Integration

This project uses GitHub Actions for CI:

- **Triggers**: Push to main branch, Pull Requests to main
- **Jobs**: Install dependencies, Run linting, Run tests
- **Platforms**: Ubuntu Linux (primary)

## Troubleshooting

### Common Issues

- **stylua not found**: Make sure it's installed and in your PATH
- **luacheck errors**: Run `make lint` to see specific issues
- **Test failures**: Use `make test-verbose` for detailed output

### Getting Help

If you encounter issues:
1. Check the error messages carefully
2. Verify all dependencies are correctly installed
3. Check that your Neovim version is 0.10.0 or higher