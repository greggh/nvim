.PHONY: test lint format help

# Configuration
LUA_PATH ?= lua/
TEST_PATH ?= tests/spec/

# Test command
test:
	@echo "Running tests..."
	@./tests/scripts/run_tests.sh

# Test with verbose output
test-verbose:
	@echo "Running tests with verbose output..."
	@NVIM_TEST_VERBOSE=1 ./tests/scripts/run_tests.sh

# Individual test commands
test-basic:
	@echo "Running basic tests..."
	@nvim --headless --noplugin -u test/minimal.vim -c "source test/basic_test.vim" -c "qa!"

test-config:
	@echo "Running configuration tests..."
	@nvim --headless --noplugin -u test/minimal.vim -c "source test/config_test.vim" -c "qa!"

# Lint Lua files with luacheck
lint:
	@echo "Linting Lua files..."
	@if command -v luacheck > /dev/null 2>&1; then \
		luacheck $(LUA_PATH) --config=.luacheckrc; \
	else \
		echo "Error: luacheck not installed. Please install it to lint Lua files."; \
		exit 1; \
	fi

# Format Lua files with stylua
format:
	@echo "Formatting Lua files..."
	@if command -v stylua > /dev/null 2>&1; then \
		stylua $(LUA_PATH); \
	else \
		echo "Error: stylua not installed. Please install it to format Lua files."; \
		exit 1; \
	fi

# Install git hooks
hooks:
	@echo "Installing git hooks..."
	@mkdir -p .githooks
	@cp scripts/hooks/* .githooks/ 2>/dev/null || true
	@chmod +x .githooks/*
	@git config core.hooksPath .githooks
	@echo "Git hooks installed successfully"

# Default target
all: lint format test

help:
	@echo "Neovim Configuration development commands:"
	@echo "  make test          - Run all tests"
	@echo "  make test-verbose  - Run all tests with verbose output"
	@echo "  make test-basic    - Run only basic tests"
	@echo "  make test-config   - Run only configuration tests"
	@echo "  make lint          - Lint Lua files with luacheck"
	@echo "  make format        - Format Lua files with stylua"
	@echo "  make hooks         - Install git hooks"
	@echo "  make all           - Run lint, format, and test"