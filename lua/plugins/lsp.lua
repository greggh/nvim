return {
  "neovim/nvim-lspconfig",
  dependencies = {
    {
      "williamboman/mason.nvim",
      opts = {
        ui = {
          icons = {
            package_installed = "",
            package_pending = "",
            package_uninstalled = "",
          },
        },
      },
      keys = {
        { mode = "n", "<leader>,", "<CMD>Mason<CR>", desc = "Open mason" },
      },
    },
    { "williamboman/mason-lspconfig.nvim" },
    { "WhoIsSethDaniel/mason-tool-installer.nvim" },
  },
  config = function()
    ---------------------
    -- lsp servers
    ---------------------
    local servers = {
      astro = {},
      bashls = {},
      cssls = {},
      docker_compose_language_service = {},
      dockerls = {},
      emmet_language_server = {
        filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss" },
      },
      eslint = {
        root_dir = vim.fs.root(0, { "package.json", ".eslintrc.json", ".eslintrc.js", ".git" }),
        filetypes = { "javascript", "typescript", "typescriptreact", "javascriptreact" },
        flags = os.getenv("DEBOUNCE_ESLINT") and {
          allow_incremental_sync = true,
          debounce_text_changes = 1000,
        } or nil,
        on_attach = function(_, bufnr)
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            command = "EslintFixAll",
          })
        end,
      },
      eslint_d = {
        root_dir = vim.fs.root(0, { "package.json", ".eslintrc.json", ".eslintrc.js", ".git" }),
        filetypes = { "javascript", "typescript", "typescriptreact", "javascriptreact" },
        flags = os.getenv("DEBOUNCE_ESLINT") and {
          allow_incremental_sync = true,
          debounce_text_changes = 1000,
        } or nil,
        on_attach = function(_, bufnr)
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            command = "EslintFixAll",
          })
        end,
      },
      gopls = {},
      html = {},
      jsonls = {},
      lua_ls = {
        settings = {
          Lua = {
            completion = {
              callSnippet = "Replace",
            },
          },
        },
      },
      --nil_ls = {},
      pyright = {},
      ruff = {
        on_attach = function(client)
          client.server_capabilities.hoverProvider = false
        end,
      },
      rust_analyzer = {},
      sqls = {},
      taplo = {
        filetypes = { "toml" },
        settings = {
          evenBetterToml = {
            formatter = {
              inlineTableExpand = false,
            },
          },
        },
      },
      ols = {},
      tailwindcss = {},
      vtsls = {
        root_dir = vim.fs.root(0, { "package.json", "tsconfig.json", "jsconfig.json", ".git" }),
        filetypes = {
          "javascript",
          "javascriptreact",
          "javascript.jsx",
          "typescript",
          "typescriptreact",
          "typescript.tsx",
        },
        settings = {
          complete_function_calls = true,
          vtsls = {
            enableMoveToFileCodeAction = true,
            autoUseWorkspaceTsdk = true,
            experimental = {
              maxInlayHintLength = 30,
              completion = {
                enableServerSideFuzzyMatch = true,
              },
            },
          },
          javascript = {
            updateImportsOnFileMove = { enabled = "always" },
            suggest = {
              completeFunctionCalls = true,
            },
          },
          typescript = {
            updateImportsOnFileMove = { enabled = "always" },
            suggest = {
              completeFunctionCalls = true,
            },
            inlayHints = {
              enumMemberValues = { enabled = true },
              functionLikeReturnTypes = { enabled = true },
              parameterNames = { enabled = "literals" },
              parameterTypes = { enabled = true },
              propertyDeclarationTypes = { enabled = true },
              variableTypes = { enabled = false },
            },
          },
        },
      },
      yamlls = {},
      zls = {},
    }

    ---------------------
    -- LSP tools
    ---------------------
    local LSP_TOOLS = {
      "goimports",
      "prettier",
      "shfmt",
      "sqlfluff",
      "sql-formatter",
      "stylelint",
      "stylua",
    }

    ---------------------
    -- capabilities
    ---------------------
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = vim.tbl_deep_extend("force", capabilities, require("blink.cmp").get_lsp_capabilities())

    ---------------------
    -- mason
    ---------------------
    local ensure_installed = vim.tbl_keys(servers or {})

    if vim.g.debugger then
      local DEBUGGERS = require("utils.debugger").DEBUGGERS
      vim.list_extend(ensure_installed, DEBUGGERS)
    end

    vim.list_extend(ensure_installed, LSP_TOOLS)

    require("mason-tool-installer").setup({ ensure_installed = ensure_installed })
    require("mason-lspconfig").setup_handlers({
      function(server_name)
        local server = servers[server_name] or {}
        server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
        server.on_attach = function(client, bufnr) -- Attach the following to every buffer.
          require("workspace-diagnostics").populate_workspace_diagnostics(client, bufnr) -- Populate Workspace-Diagnostics plugin information.
        end
        require("lspconfig")[server_name].setup(server)
      end,
    })

    ---------------------
    -- keybinds
    ---------------------
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {}),
      callback = function(event)
        local opts = { buffer = event.buf, silent = true }
        local bind = require("utils.keymap-bind")
        local map_cr = bind.map_cr
        local map_cu = bind.map_cu
        local map_cmd = bind.map_cmd
        local map_callback = bind.map_callback
        local lsp_map = {
          ["n|<leader>lr"] = map_callback(function()
              require("mason").toggle()
            end)
            :with_noremap()
            :with_silent()
            :with_desc("Show LSP references"),
          ["n|<leader>lk"] = map_callback(function()
              require("mason").toggle()
            end)
            :with_noremap()
            :with_silent()
            :with_desc("Go to declaration"),
          ["n|<leader>ld"] = map_callback(function()
              require("mason").toggle()
            end)
            :with_noremap()
            :with_silent()
            :with_desc("Show LSP definitions"),
          ["n|<leader>li"] = map_callback(function()
              require("mason").toggle()
            end)
            :with_noremap()
            :with_silent()
            :with_desc("Show LSP implementations"),
          ["n|<leader>lt"] = map_callback(function()
              require("mason").toggle()
            end)
            :with_noremap()
            :with_silent()
            :with_desc("Show LSP type definitions"),
          ["n|<leader>lb"] = map_callback(function()
              require("mason").toggle()
            end)
            :with_noremap()
            :with_silent()
            :with_desc("Show buffer diagnostics"),
          ["n|<leader>ll"] = map_callback(function()
              require("mason").toggle()
            end)
            :with_noremap()
            :with_silent()
            :with_desc("Show line diagnostics"),
          ["n|<leader>l["] = map_callback(function()
              require("mason").toggle()
            end)
            :with_noremap()
            :with_silent()
            :with_desc("Go to previous diagnostic"),
          ["n|<leader>l]"] = map_callback(function()
              require("mason").toggle()
            end)
            :with_noremap()
            :with_silent()
            :with_desc("Go to next diagnostic"),
          ["n|<leader>lz"] = map_callback(function()
              require("mason").toggle()
            end)
            :with_noremap()
            :with_silent()
            :with_desc("Restart LSP"),
        }

        bind.nvim_load_mapping(lsp_map)

        opts.desc = "See available code actions"
        vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

        opts.desc = "Smart rename"
        vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, opts)
      end,
    })

    ---------------------
    -- diagnostic signs
    ---------------------
    local signs = { ERROR = " ", WARN = " ", HINT = "󰠠 ", INFO = " " }
    local diagnostic_signs = {}
    for type, icon in pairs(signs) do
      diagnostic_signs[vim.diagnostic.severity[type]] = icon
    end
    vim.diagnostic.config({ signs = { text = diagnostic_signs } })

    ---------------------
    -- error lens
    ---------------------
    vim.diagnostic.config({
      float = { border = "rounded" },
      severity_sort = true,
      underline = true,
      update_in_insert = false,
      virtual_text = {
        spacing = 4,
        source = "if_many",
        prefix = "●",
      },
    })

    ---------------------
    -- inlay hints
    ---------------------
    -- vim.lsp.inlay_hint.enable() -- enabled by default
    vim.keymap.set("n", "<leader>&", function()
      local current_state = vim.lsp.inlay_hint.is_enabled()
      local icon = current_state and " " or " "
      local message = current_state and "Inlay hints disabled" or "Inlay hints enabled"
      vim.lsp.inlay_hint.enable(not current_state)
      print(icon .. " " .. message)
    end, { noremap = true, silent = false, desc = "Toggle inlay hints" })
  end,
}
