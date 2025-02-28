# Contributing to Gregg's Neovim Configuration

Thank you for considering contributing to this Neovim configuration! Your contributions help make this configuration better for everyone.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
  - [Reporting Bugs](#reporting-bugs)
  - [Suggesting Enhancements](#suggesting-enhancements)
  - [Pull Requests](#pull-requests)
- [Style Guides](#style-guides)
  - [Lua Style Guide](#lua-style-guide)
  - [Git Commit Messages](#git-commit-messages)
- [Development Workflow](#development-workflow)
  - [Setting Up Development Environment](#setting-up-development-environment)
  - [Testing Your Changes](#testing-your-changes)
- [Additional Resources](#additional-resources)

## Code of Conduct

This project aims to be an open and welcoming space. By participating, you are expected to:

- Be respectful and considerate of others
- Provide constructive feedback
- Accept constructive criticism gracefully
- Focus on what's best for the community

## How Can I Contribute?

### Reporting Bugs

Before submitting a bug report, please check the existing issues to see if someone already reported it. When submitting a bug report, include:

- A clear and descriptive title
- Steps to reproduce the issue
- Expected behavior and what actually happened
- Neovim version (`nvim --version`)
- Operating system and version
- Screenshots if applicable

### Suggesting Enhancements

Enhancement suggestions are welcome! When suggesting an enhancement:

- Use a clear and descriptive title
- Provide a step-by-step description of the enhancement
- Explain why this enhancement would be useful
- Include code examples or screenshots if applicable

### Pull Requests

When submitting a pull request:

1. Fork the repository and create your branch from `main`
2. If you've added code that should be tested, add tests
3. Make sure your code follows the [style guides](#style-guides)
4. Issue that pull request!

For significant changes, please open an issue first to discuss the proposed changes.

## Style Guides

### Lua Style Guide

- Use 2 spaces for indentation
- Follow the [Neovim Lua style guide](https://github.com/neovim/neovim/wiki/Lua-guide)
- Use Lua idioms when possible
- Keep lines under 100 characters when possible
- Use local variables when possible to improve performance
- Use clear, descriptive variable and function names

This configuration uses [stylua](https://github.com/JohnnyMorganz/StyLua) for code formatting. Add a `.stylua.toml` file to your project with the appropriate settings.

### Git Commit Messages

- Use the present tense ("Add feature" not "Added feature")
- Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit the first line to 72 characters or less
- Reference issues and pull requests after the first line
- Consider following the [Conventional Commits](https://www.conventionalcommits.org/) specification

## Development Workflow

### Setting Up Development Environment

1. Clone the repository:
   ```bash
   git clone https://github.com/greggh/nvim ~/.config/nvim-dev
   ```

2. Create a script to launch Neovim with this configuration:
   ```bash
   NVIM_APPNAME=nvim-dev nvim
   ```

3. Make your changes and test them thoroughly

### Testing Your Changes

Before submitting a PR, please ensure:

- Your changes don't break existing functionality
- New features are well-documented
- The configuration starts without errors
- Plugin dependencies are properly specified

## Additional Resources

- [Neovim Documentation](https://neovim.io/doc/)
- [Lua Reference Manual](https://www.lua.org/manual/5.1/)
- [Awesome Neovim](https://github.com/rockerBOO/awesome-neovim)
- [Neovim Lua Guide](https://github.com/nanotee/nvim-lua-guide)