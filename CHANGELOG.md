# Changelog

All notable changes to this Neovim configuration will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.4.2] - 2025-03-03

### Fixed
- Added "TelescopePrompt" and "TelescopeResults" to ignored filetypes to prevent autocompletion
- Added "artisan-output" to ignored filetypes for Laravel Helper integration
- Consolidated duplicate filetype ignore lists into a single global list
- Fixed test runner not properly exiting after tests
- Improved handling of which-key in test environment

## [0.4.1] - 2025-03-03

### Changed
- Improved GitHub workflows with dedicated documentation checks
- Enhanced release workflow with more reliable changelog generation
- Updated GitHub Actions dependencies to latest versions
- Improved test and linting infrastructure for CI/CD pipeline

### Fixed
- Fixed deprecated changelog generator in release workflow
- Added proper Markdown documentation validation
- Improved error handling in GitHub workflows
- Fixed inconsistencies in workflow trigger conditions

## [0.4.0] - 2025-03-02

### Added
- GitHub Discussions integration
- Release automation workflow
- Acknowledgements section in README
- Enhanced badges and Table of Contents in README
- Comprehensive test suite with plugin management tests
- UI component tests for colorscheme and status line
- Keybinding tests for leader key and mappings
- Pre-commit hooks for running tests and linting

### Changed
- Improved README organization and structure
- Standardized GitHub workflow naming conventions
- Enhanced test infrastructure for different config structures

### Fixed
- Pre-commit hook path references for test initialization files
- Test execution in pre-commit hooks using custom test runner
- Standardized test initialization file naming across all projects

## [0.3.0] - 2025-03-01

### Added
- Version tracking with semantic versioning
- Comprehensive test framework using BDD-style syntax
- GitHub Actions workflow for CI/CD
- Linting and formatting with luacheck and StyLua
- Development guide with cross-platform tool installation instructions
- GitHub Sponsors and Ko-fi funding links

### Changed
- Improved module loading approach for better performance
- Enhanced error handling throughout configuration
- Updated contributing guidelines with references to development guide

### Fixed
- Snacks module loading issues
- Deprecated Neovim API calls in profile.lua
- Snacks image module configuration errors
- Non-existent commands in profile keymaps

## [0.2.0] - 2025-02-01

### Added
- Claude Code integration
- Laravel Helper integration
- Enhanced PHP development environment
- Improved folding and window management

## [0.1.0] - 2024-12-15

### Added
- Initial configuration setup
- Core plugin ecosystem
- Basic keybindings and settings
- Modular organization
