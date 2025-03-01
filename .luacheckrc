-- .luacheckrc for Neovim configuration
-- Global objects defined by Neovim
globals = {
  "vim",
  "describe",
  "it",
  "before_each",
  "after_each",
  "pending",
  "teardown",
}

-- Don't report unused self arguments of methods
self = false

-- Ignore warnings about unused arguments in test fixtures and mocks
ignore = {
  "212/self", -- Unused argument 'self' in test functions is fine
  "212/_.*", -- Unused arguments prefixed with underscore are fine (e.g., _config)
  "213", -- Unused loop variables
}

-- Exclusions for test files
files["tests/minimal-init.lua"] = {
  -- Allow unused arguments in mock functions
  ignore = {"212"},
}

-- Ignore long lines in README generation
files["lua/config/keymaps.lua"] = {
  -- Allow long lines in the README generation section
  ignore = {"631"}, -- Ignore "line is too long" warnings
}

files["tests/run_tests.lua"] = {
  -- Allow unused arguments in test framework
  ignore = {"212"},
}

files["tests/**/spec/**"] = {
  -- Allow even more relaxed rules in test specs
  ignore = {"212", "142"}, -- Ignore unused vars and setting undefined fields
}

-- File patterns to exclude
exclude_files = {
  "lua/lazy/*",
  ".luarocks/*",
}

-- Allowed global functions in tests
files["tests/**"] = {
  globals = {
    "describe",
    "it", 
    "before_each",
    "after_each",
    "setup",
    "teardown",
    "assert",
    "spy",
    "stub",
    "mock",
    "dofile",
    "load",
    "package",
  }
}

-- Set the max line length to 120
max_line_length = 120

-- Settings for third-party libraries
files["**/lazy.lua"] = {
  -- Lazy.nvim uses its own globals
  globals = {"vim", "require"},
}

-- Run in parallel when possible
jobs = 4