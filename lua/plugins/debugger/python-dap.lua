return {
  "mfussenegger/nvim-dap-python",
  dependencies = "mfussenegger/nvim-dap",
  config = function()
    -- fix: E5108: Error executing lua - attempt to index local 'element' (a nil value)
    -- see: nvim-dap-ui issue #279
    require("dapui").setup()
    -- uses the debugypy installation by mason
    local debugpyPythonPath = require("mason-registry").get_package("debugpy"):get_install_path() .. "/venv/bin/python3"
    require("dap-python").setup(debugpyPythonPath, {}) ---@diagnostic disable-line: missing-fields
  end,
}
