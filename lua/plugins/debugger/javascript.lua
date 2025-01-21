return {
  "nvim-dap",
  opts = function()
    local dap = require("dap")
    local git = require("utils.git")
    local debug_adapter_path = vim.env.MASON .. "/packages/js-debug-adapter/js-debug/src/dapDebugServer.js"
    local cwd = vim.fs.root(0, "package.json") or git.get_git_root() or "${workspaceFolder}"

    local adapters = {
      "bun",
      "node",
      "node-terminal",
      "pwa-node",
    }
    local browser_adapters = {
      "brave",
      "chrome",
      "pwa-brave",
      "pwa-chrome",
      "pwa-extensionHost",
      "pwa-msedge",
    }

    for _, adapter in ipairs(adapters) do
      dap.adapters[adapter] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = "node",
          args = {
            debug_adapter_path,
            "${port}",
          },
        },
      }
    end

    for _, adapter in ipairs(browser_adapters) do
      dap.adapters[adapter] = {
        type = "executable",
        command = "node",
        args = { debug_adapter_path },
      }
    end

    local js_filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact" }

    local vscode = require("dap.ext.vscode")
    local all_adapters = vim.tbl_extend("force", adapters, browser_adapters)
    for _, adapter in ipairs(all_adapters) do
      vscode.type_to_filetypes[adapter] = js_filetypes
    end

    for _, language in ipairs(js_filetypes) do
      dap.configurations[language] = dap.configurations[language] or {}
      for _, adapter in ipairs(adapters) do
        table.insert(dap.configurations[language], {
          name = "Launch file [" .. adapter .. "]",
          type = adapter,
          request = "launch",
          program = "${file}",
          cwd = cwd,
        })
        table.insert(dap.configurations[language], {
          name = "Attach [" .. adapter .. "]",
          type = adapter,
          request = "attach",
          processId = require("dap.utils").pick_process,
          cwd = cwd,
        })
      end
      for _, adapter in ipairs(browser_adapters) do
        table.insert(dap.configurations[language], {
          name = "Browser [" .. adapter .. "]",
          type = adapter,
          request = "launch",
          protocol = "inspector",
          url = function()
            local co = coroutine.running()
            return coroutine.create(function()
              vim.ui.input({
                prompt = "Enter URL: ",
                default = "http://localhost:4321",
              }, function(url)
                if url == nil or url == "" then
                  return
                else
                  coroutine.resume(co, url)
                end
              end)
            end)
          end,
          sourceMaps = true,
          userDataDir = false,
          webRoot = cwd,
        })
      end
    end
  end,
}
