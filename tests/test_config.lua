-- Test configuration
return {
  -- List of modules to test
  modules = {
    "config.options",
    "config.keymaps",
    "config.autocmd",
  },

  -- Mock configuration
  mock = {
    -- Mock plugin availability
    plugins = {
      "nvim-treesitter",
      "telescope.nvim",
      "lazy.nvim",
    },

    -- Mock system functions
    system = {
      -- Return true for executable checks
      executable = function(cmd)
        return true
      end,
    },
  },
}
