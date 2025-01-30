return {
  "mfussenegger/nvim-dap-python",
  dependencies = "mfussenegger/nvim-dap",
  config = function()
    -- fix: E5108: Error executing lua .../Local/nvim-data/lazy/nvim-dap-ui/lua/dapui/controls.lua:14: attempt to index local 'element' (a nil value)
    -- see: https://github.com/rcarriga/nvim-dap-ui/issues/279#issuecomment-1596258077
    require("dapui").setup()
    -- uses the debugypy installation by mason
    local debugpyPythonPath = require("mason-registry").get_package("debugpy"):get_install_path() .. "/venv/bin/python3"
    require("dap-python").setup(debugpyPythonPath, {}) ---@diagnostic disable-line: missing-fields
  end,
}
