#!/bin/bash

# Script to set up Git hooks for Neovim config

# Make sure we're in the project root
cd "$(dirname "$0")/.." || exit 1

# Ensure the hooks directory exists
mkdir -p .githooks

# Copy all hooks from scripts/hooks to .githooks
cp scripts/hooks/* .githooks/ 2>/dev/null || true

# Make all hooks executable
chmod +x .githooks/*

# Set up Git hooks directory
git config core.hooksPath .githooks

echo "Git hooks have been set up successfully."
echo "Pre-commit hook will now automatically format Lua files using StyLua, run linting with luacheck, and run basic tests."