return {
  "neovim/nvim-lspconfig",
  dependencies = {
    {
      "williamboman/mason.nvim",
      opts = {
        ui = {
          icons = {
            package_installed = "",
            package_pending = "",
            package_uninstalled = "",
          },
        },
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
        fileeypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "php" },
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
      intelephense = {
        init_options = {
          licenceKey = nil, -- Set your license key here if you have one
          globalStoragePath = vim.env.HOME .. "/.local/share/intelephense",
        },
        settings = {
          intelephense = {
            files = {
              maxSize = 1000000, -- Increased for larger files
            },
            environment = {
              includePaths = {},
            },
            format = {
              enable = false, -- We'll use a dedicated formatter for PHP
            },
            stubs = {
              "apache",
              "bcmath",
              "bz2",
              "calendar",
              "com_dotnet",
              "Core",
              "ctype",
              "curl",
              "date",
              "dba",
              "dom",
              "enchant",
              "exif",
              "FFI",
              "fileinfo",
              "filter",
              "fpm",
              "ftp",
              "gd",
              "gettext",
              "gmp",
              "hash",
              "iconv",
              "imap",
              "intl",
              "json",
              "ldap",
              "libxml",
              "mbstring",
              "meta",
              "mysqli",
              "oci8",
              "odbc",
              "openssl",
              "pcntl",
              "pcre",
              "PDO",
              "pdo_ibm",
              "pdo_mysql",
              "pdo_pgsql",
              "pdo_sqlite",
              "pgsql",
              "Phar",
              "posix",
              "pspell",
              "readline",
              "Reflection",
              "session",
              "shmop",
              "SimpleXML",
              "snmp",
              "soap",
              "sockets",
              "sodium",
              "SPL",
              "sqlite3",
              "standard",
              "superglobals",
              "sysvmsg",
              "sysvsem",
              "sysvshm",
              "tidy",
              "tokenizer",
              "xml",
              "xmlreader",
              "xmlrpc",
              "xmlwriter",
              "xsl",
              "zip",
              "zlib",
              "wordpress",
              "phpunit",
              "laravel",
              "wordpress-globals",
              "woocommerce",
            },
            completion = {
              maxItems = 100,
              insertUseDeclaration = true,
              fullyQualifyGlobalConstantsAndFunctions = false,
              triggerParameterHints = true,
            },
            phpdoc = {
              returnVoid = false, -- Don't add @return void
              useFullyQualifiedNames = false,
            },
          },
        },
      },
      jsonls = {},
      lua_ls = {
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim", "Snacks" },
            },
            completion = {
              callSnippet = "Replace",
            },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false,
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
      "phpcs", -- PHP CodeSniffer for PHP linting
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

    -- Load blink.cmp capabilities safely
    local has_blink, blink = pcall(require, "blink.cmp")
    if has_blink then
      capabilities = vim.tbl_deep_extend("force", capabilities, blink.get_lsp_capabilities())
    end

    -- Add folding range capability
    capabilities.textDocument.foldingRange = {
      dynamicRegistration = false,
      lineFoldingOnly = true,
    }

    ---------------------
    -- memory limiting for LSP servers
    ---------------------
    -- local function get_memory_limit_mb()
    --   -- Adapt based on available system memory
    --   return 1024 -- 1GB limit for LSP servers
    -- end

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
    -- require("mason-lspconfig").setup_handlers({
    --   function(server_name)
    --     local server = servers[server_name] or {}
    --     server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})

    --     -- Add memory limits for heavy LSP servers
    --     local heavy_servers = {
    --       "vtsls",
    --       "lua_ls",
    --       "pyright",
    --       "rust_analyzer",
    --       "gopls",
    --       "clangd",
    --       "tailwindcss",
    --       "jdtls",
    --       "yamlls",
    --       "intelephense", -- PHP LSP can be memory hungry
    --     }
    --     if vim.tbl_contains(heavy_servers, server_name) then
    --       server.settings = server.settings or {}
    --       server.settings.memory = {
    --         limitMb = get_memory_limit_mb(),
    --       }
    --     end

    --     -- Add offsetEncoding capability for clangd
    --     if server_name == "clangd" then
    --       server.capabilities.offsetEncoding = { "utf-16" }
    --     end

    --     --       server.on_attach = function(client, bufnr) -- Attach to every buffer
    --     -- Populate Workspace-Diagnostics plugin information
    --     --          require("workspace-diagnostics").populate_workspace_diagnostics(client, bufnr)
    --     --        end
    --     require("lspconfig")[server_name].setup(server)
    --   end,
    -- })

    ---------------------
    -- keybinds
    ---------------------
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {}),
      callback = function(event)
        local opts = { buffer = event.buf, silent = true }
        local bind = require("utils.keymap-bind")
        local map_cr = bind.map_cr
        local map_callback = bind.map_callback
        local Snacks = require("snacks")
        local lsp_map = {
          ["n|gr"] = map_callback(function()
              Snacks.picker.lsp_references()
            end)
            :with_noremap()
            :with_silent()
            :with_desc("Show LSP references"),
          ["n|gD"] = map_callback(function()
              vim.lsp.buf.declaration()
            end)
            :with_noremap()
            :with_silent()
            :with_desc("Go to declaration"),
          ["n|gd"] = map_callback(function()
              Snacks.picker.lsp_definitions()
            end)
            :with_noremap()
            :with_silent()
            :with_desc("Show LSP definitions"),
          ["n|gi"] = map_callback(function()
              Snacks.picker.lsp_implementations()
            end)
            :with_noremap()
            :with_silent()
            :with_desc("Show LSP implementations"),
          ["n|gt"] = map_callback(function()
              Snacks.picker.lsp_type_definitions()
            end)
            :with_noremap()
            :with_silent()
            :with_desc("Show LSP type definitions"),
          ["n|gb"] = map_callback(function()
              Snacks.picker.diagnostics_buffer()
            end)
            :with_noremap()
            :with_silent()
            :with_desc("Show buffer diagnostics"),
          ["n|gl"] = map_callback(function()
              vim.diagnostic.open_float()
            end)
            :with_noremap()
            :with_silent()
            :with_desc("Show line diagnostics"),
          ["n|gp"] = map_callback(function()
              vim.diagnostic.goto_prev()
            end)
            :with_noremap()
            :with_silent()
            :with_desc("Go to previous diagnostic"),
          ["n|gn"] = map_callback(function()
              vim.diagnostic.goto_next()
            end)
            :with_noremap()
            :with_silent()
            :with_desc("Go to next diagnostic"),

          ["n|<leader>lr"] = map_callback(function()
              Snacks.picker.lsp_references()
            end)
            :with_noremap()
            :with_silent()
            :with_desc("Show LSP references"),
          ["n|<leader>lk"] = map_callback(function()
              vim.lsp.buf.declaration()
            end)
            :with_noremap()
            :with_silent()
            :with_desc("Go to declaration"),
          ["n|<leader>ld"] = map_callback(function()
              Snacks.picker.lsp_definitions()
            end)
            :with_noremap()
            :with_silent()
            :with_desc("Show LSP definitions"),
          ["n|<leader>li"] = map_callback(function()
              Snacks.picker.lsp_implementations()
            end)
            :with_noremap()
            :with_silent()
            :with_desc("Show LSP implementations"),
          ["n|<leader>lt"] = map_callback(function()
              Snacks.picker.lsp_type_definitions()
            end)
            :with_noremap()
            :with_silent()
            :with_desc("Show LSP type definitions"),
          ["n|<leader>lb"] = map_callback(function()
              Snacks.picker.diagnostics_buffer()
            end)
            :with_noremap()
            :with_silent()
            :with_desc("Show buffer diagnostics"),
          ["n|<leader>ll"] = map_callback(function()
              vim.diagnostic.open_float()
            end)
            :with_noremap()
            :with_silent()
            :with_desc("Show line diagnostics"),
          ["n|<leader>l["] = map_callback(function()
              vim.diagnostic.goto_prev()
            end)
            :with_noremap()
            :with_silent()
            :with_desc("Go to previous diagnostic"),
          ["n|<leader>l]"] = map_callback(function()
              vim.diagnostic.goto_next()
            end)
            :with_noremap()
            :with_silent()
            :with_desc("Go to next diagnostic"),
          ["n|<leader>lz"] = map_cr("LspRestart"):with_noremap():with_silent():with_desc("Restart LSP"),
        }

        bind.nvim_load_mapping(lsp_map)

        opts.desc = "Smart rename"
        vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, opts)
      end,
    })

    ---------------------
    -- diagnostic signs
    ---------------------
    local signs = { ERROR = " ", WARN = " ", HINT = "󰠠 ", INFO = " " }
    local diagnostic_signs = {}
    for type, icon in pairs(signs) do
      diagnostic_signs[vim.diagnostic.severity[type]] = icon
    end
    vim.diagnostic.config({ signs = { text = diagnostic_signs } })

    ---------------------
    -- error lens
    ---------------------
    vim.diagnostic.config({
      float = {
        border = "rounded",
        max_width = 100,
        max_height = 20,
        focusable = false,
        close_events = { "CursorMoved", "BufHidden", "InsertLeave" },
      },
      severity_sort = true,
      underline = true,
      update_in_insert = false,
      virtual_text = {
        spacing = 4,
        source = "if_many",
        prefix = "●",
        format = function(diagnostic)
          -- Trim long diagnostics
          if #diagnostic.message > 80 then
            return diagnostic.message:sub(1, 77) .. "..."
          end
          return diagnostic.message
        end,
      },
    })

    ---------------------
    -- signature help handler
    ---------------------
    vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
      border = "rounded",
      close_events = { "CursorMoved", "BufHidden", "InsertLeave" },
      focusable = false,
      relative = "cursor",
      max_height = 20,
      max_width = 120,
    })

    ---------------------
    -- inlay hints
    ---------------------
    -- vim.lsp.inlay_hint.enable() -- enabled by default
    -- Keymap is defined in lua/config/keymaps.lua
  end,
}
