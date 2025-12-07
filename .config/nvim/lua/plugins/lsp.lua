-- LSP and language server configuration

local signs = require("utils.constants").diagnostic_signs
local lsp_servers = require("utils.constants").lsp_servers

-- LSP Prevents inline buffer annotations
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

vim.diagnostic.open_float(nil, {
    source = 'always'
})

-- LSP capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities.textDocument.completion.completionItem.resolveSupport = {
  properties = {
    "documentation",
    "detail",
    "additionalTextEdits",
  },
}

-- LSP on_attach function
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
  vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
  vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
  vim.keymap.set('n', '<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, opts)
  vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
  vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format { async = true } end, opts)
end

return {
  -- Mason pkg manager
  "williamboman/mason.nvim",
  config = function()
    require("mason").setup()
  end,

  -- Nvim LSP Server
  "neovim/nvim-lspconfig",
  "williamboman/mason-lspconfig.nvim",

  -- Additional Linting
  "mfussenegger/nvim-lint",

  -- LSP Diagnostics Config
  "WhoIsSethDaniel/toggle-lsp-diagnostics.nvim",

  -- LSP Server configurations
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- Pyright
      require("lspconfig").pyright.setup({
        cmd = { "pyright-langserver", "--stdio" },
        filetypes = { "python" },
        capabilities = capabilities,
        settings = {
          python = {
            analysis = {
              autoSearchPaths = true,
              diagnosticMode = "workspace",
              useLibraryCodeForTypes = true,
            },
          },
        },
      })

      -- Rust Analyzer
      require("lspconfig").rust_analyzer.setup({})

      -- Clangd (C/C++)
      require'lspconfig'.clangd.setup{}

      -- Lua LS
      require("lspconfig").lua_ls.setup({
        settings = {
          Lua = {
            diagnostics = {
              globals = {"vim"},
            }
          }
        }
      })

      -- CSS LS
      require("lspconfig").cssls.setup({
        cmd = { "vscode-css-language-server", "--stdio" },
        capabilities = capabilities,
        settings = {
          scss = {
            lint = {
              idSelector = "warning",
              zeroUnits = "warning",
              duplicateProperties = "warning",
            },
            completion = {
              completePropertyWithSemicolon = true,
              triggerPropertyValueCompletion = true,
            },
          },
        },
      })

      -- EFM (ESLint, Dockerfile, YAML, Shell)
      local eslint = {
        lintCommand = "eslint_d -f unix --stdin --stdin-filename ${INPUT}",
        lintStdin = true,
        lintFormats = {
          "%f:%l:%c: %m",
        },
        lintIgnoreExitCode = true,
      }

      local hadolint = {
        lintSource = "hadolint",
        lintCommand = "hadolint --no-color -",
        lintStdin = true,
        lintIgnoreExitCode = true,
        lintFormats = {
          "%f:%l %m",
        },
      }

      local yamllint = {
        lintSource = "yamllint",
        lintCommand = "yamllint -f parsable -",
        lintStdin = true,
      }

      local shellcheck = {
        lintSource = "shellcheck",
        lintCommand = "shellcheck -f gcc -x",
        lintStdin = true,
        lintFormats = {
          "%f:%l:%c: %trror: %m",
          "%f:%l:%c: %tarning: %m",
          "%f:%l:%c: %tote: %m",
        },
      }

      require("lspconfig")["efm"].setup({
        on_attach = function(client)
          client.server_capabilities.document_formatting = true
          client.server_capabilities.goto_definition = false
        end,

        settings = {
          languages = {
            javascript = { eslint },
            javascriptreact = { eslint },
            ["javascript.jsx"] = { eslint },
            typescript = { eslint },
            ["typescript.tsx"] = { eslint },
            typescriptreact = { eslint },
            dockerfile = { hadolint },
            yaml = { yamllint },
            sh = { shellcheck },
          },
        },
        filetypes = {
          "javascript",
          "javascriptreact",
          "javascript.jsx",
          "typescript",
          "typescript.tsx",
          "typescriptreact",
          "dockerfile",
          "yaml",
          "sh",
        },
      })

      -- Use a loop to conveniently call 'setup' on multiple servers
      local nvim_lsp = require('lspconfig')
      for _, lsp in ipairs(lsp_servers) do
        nvim_lsp[lsp].setup {
          on_attach = on_attach,
          flags = {
            debounce_text_changes = 150,
          }
        }
      end
    end,
  },
}