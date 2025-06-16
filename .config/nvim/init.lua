

-- Dependencies
-- Plugins require Packer, a Lua package manager, installation found https://github.com/wbthomason/packer.nvim
-- LSP servers, debuggers, linters, and formatters are managed with Mason

-- Lua variables for setting various commands, functions, etc.
local cmd = vim.cmd -- to execute Vim commands e.g. cmd('pwd')
local fn = vim.fn -- to call Vim functions e.g. fn.bufnr()
local g = vim.g -- a table to access global variables
local opt = vim.opt -- to set options
local function map(mode, lhs, rhs)
  vim.keymap.set(mode, lhs, rhs)
end

local colors = {
  bg = "#202328",
  fg = "#bbc2cf",
  yellow = "#ECBE7B",
  cyan = "#008080",
  darkblue = "#081633",
  green = "#98be65",
  orange = "#FF8800",
  violet = "#a9a1e1",
  magenta = "#c678dd",
  blue = "#51afef",
  red = "#ec5f67",
}

-- Map leader to space
g.mapleader = " "

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)-- Plugins

require("lazy").setup({

  -- Theme
  "folke/tokyonight.nvim",
  "kdheepak/lazygit.nvim",

  -- Mason pkg manager
    "williamboman/mason.nvim",

  -- Nvim LSP Server
   "neovim/nvim-lspconfig" ,
   "williamboman/mason-lspconfig.nvim" ,

  -- Additional Linting
   "mfussenegger/nvim-lint" ,
  -- Github Copilot
{
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    build = ":Copilot auth",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        panel = {
          enabled = true,
          auto_refresh = true,
          keymap = {
            accept = "<CR>",
            jump_prev = "[[",
            jump_next = "]]",
            open = "<leader>cv",
          },
        },
        suggestion = {
          enabled = true,
          auto_trigger = true,
          keymap = {
            accept = "<leader>x",
            prev = "<M-[>",
            next = "<M-]>",
            dismiss = "<C-]>",
          },
        },
      })
      -- hide copilot suggestions when cmp menu is open
      -- to prevent odd behavior/garbled up suggestions
      local cmp_status_ok, cmp = pcall(require, "cmp")
      if cmp_status_ok then
        cmp.event:on("menu_opened", function()
          vim.b.copilot_suggestion_hidden = true
        end)

        cmp.event:on("menu_closed", function()
          vim.b.copilot_suggestion_hidden = false
        end)
      end

    end,
  },
  -- Which Keywords
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>c", group = "ai", mode = { "n", "v" } },
        { "gm", group = "+Copilot chat" },
        { "gmh", desc = "Show help" },
        { "gmd", desc = "Show diff" },
        { "gmp", desc = "Show system prompt" },
        { "gms", desc = "Show selection" },
        { "gmy", desc = "Yank diff" },
      },
    },
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    opts = {
      debug = false, -- Enable or disable debug mode, the log file will be in ~/.local/state/nvim/CopilotChat.nvim.log
      disable_extra_info = 'yes', -- Disable extra information (e.g: system prompt) in the response.
      question_header = "## User ",
      answer_header = "## Copilot ",
      error_header = "## Error ",
      prompts = {
        Explain = "Please explain how the following code works.",
        Review = "Please review the following code and provide suggestions for improvement.",
        Tests = "Please explain how the selected code works, then generate unit tests for it. At the following path /Users/ryandavis/.config/nvim/unit_tests_llm.py is a file that contains rules, guidance, and examples I want you to use when generating unit tests. First follow the basic guidelines in the docstring at the top of the file, and then use the examples and subsequent tests for those examples to help guide you in creating a unit test for the inputted code. If the examples in the file don't cover something in the code you are currently being asked to generate a test for, use your discretion, however, make a note at the top detailing all of the decisions you made that were not in the included unit_tests_llm.py file so that I may review them.",
        Refactor = "Please refactor the following code to improve its clarity and readability.",
        FixCode = "Please fix the following code to make it work as intended.",
        FixError = "Please explain the error in the following text and provide a solution.",
        BetterNamings = "Please provide better names for the following variables and functions.",
        Documentation = "Please provide documentation for the following code.",
        -- Text related prompts
        Summarize = "Please summarize the following text.",
        Spelling = "Please correct any grammar and spelling errors in the following text.",
        Wording = "Please improve the grammar and wording of the following text.",
        Concise = "Please rewrite the following text to make it more concise.",
      },
      model = "claude-3.7-sonnet",
      auto_follow_cursor = false, -- Don't follow the cursor after getting response
      show_help = false, -- Show help in virtual text, set to true if that's 1st time using Copilot Chat
      mappings = {
        -- Use tab for completion
        complete = {
          detail = "Use @<Tab> or /<Tab> for options.",
          insert = "<Tab>",
        },
        -- Close the chat
        close = {
          normal = "q",
          insert = "<C-c>",
        },
        -- Reset the chat buffer
        reset = {
          normal = "<C-x>",
          insert = "<C-x>",
        },
        -- Submit the prompt to Copilot
        submit_prompt = {
          normal = "<CR>",
          insert = "<C-CR>",
        },
        -- Accept the diff
        accept_diff = {
          normal = "<C-y>",
          insert = "<C-y>",
        },
        -- Yank the diff in the response to register
        yank_diff = {
          normal = "gmy",
        },
        -- Show the diff
        show_diff = {
          normal = "gmd",
        },
        -- Show the prompt
        show_system_prompt = {
          normal = "gmp",
        },
        -- Show the user selection
        show_user_selection = {
          normal = "gms",
        },
        -- Show help
        show_help = {
          normal = "gmh",
        },
      },
    },
    config = function(_, opts)
      local chat = require("CopilotChat")
      local select = require("CopilotChat.select")
      -- Use unnamed register for the selection
      opts.selection = select.unnamed

      local hostname = io.popen("hostname"):read("*a"):gsub("%s+", "")
      local user = hostname or vim.env.USER or "User"
      opts.question_header = "  " .. user .. " "
      opts.answer_header = "  Copilot "
      -- Override the git prompts message
      opts.prompts.Commit = {
        prompt = 'Write commit message with commitizen convention. Write clear, informative commit messages that explain the "what" and "why" behind changes, not just the "how".',
        selection = select.gitdiff,
      }
      opts.prompts.CommitStaged = {
        prompt = 'Write commit message for the change with commitizen convention. Write clear, informative commit messages that explain the "what" and "why" behind changes, not just the "how".',
        selection = function(source)
          return select.gitdiff(source, true)
        end,
      }

      chat.setup(opts)
      -- Setup CMP integration
      require("CopilotChat.integrations.cmp").setup()

      vim.api.nvim_create_user_command("CopilotChatVisual", function(args)
        chat.ask(args.args, { selection = select.visual })
      end, { nargs = "*", range = true })

      -- Inline chat with Copilot
      vim.api.nvim_create_user_command("CopilotChatInline", function(args)
        chat.ask(args.args, {
          selection = select.visual,
          window = {
            layout = "float",
            relative = "cursor",
            width = 1,
            height = 0.4,
            row = 1,
          },
        })
      end, { nargs = "*", range = true })

      -- Restore CopilotChatBuffer
      vim.api.nvim_create_user_command("CopilotChatBuffer", function(args)
        chat.ask(args.args, { selection = select.buffer })
      end, { nargs = "*", range = true })

      -- Custom buffer for CopilotChat
      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "copilot-*",
        callback = function()
          vim.opt_local.relativenumber = true
          vim.opt_local.number = true

          -- Get current filetype and set it to markdown if the current filetype is copilot-chat
          local ft = vim.bo.filetype
          if ft == "copilot-chat" then
            vim.bo.filetype = "markdown"
          end
        end,
      })
    end,
    build = function()
      vim.notify("Please update the remote plugins by running ':UpdateRemotePlugins', then restart Neovim.")
    end,
    event = "VeryLazy",
    keys = {
      -- Show help actions
      {
        "<leader>cah",
        function()
          local actions = require("CopilotChat.actions")
          require("CopilotChat.integrations.fzflua").pick(actions.help_actions())
        end,
        desc = "CopilotChat - Help actions",
      },
      -- Show prompts actions
      {
        "<leader>cap",
        function()
          local actions = require("CopilotChat.actions")
          require("CopilotChat.integrations.fzflua").pick(actions.prompt_actions())
        end,
        desc = "CopilotChat - Prompt actions",
      },
      {
        "<leader>cap",
        ":lua require('CopilotChat.integrations.fzflua').pick(require('CopilotChat.actions').prompt_actions({selection = require('CopilotChat.select').visual}))<CR>",
        mode = "x",
        desc = "CopilotChat - Prompt actions",
      },
      -- Code related commands
      { "<leader>cae", "<cmd>CopilotChatExplain<cr>", desc = "CopilotChat - Explain code" },
      { "<leader>cat", "<cmd>CopilotChatTests<cr>", desc = "CopilotChat - Generate tests" },
      { "<leader>car", "<cmd>CopilotChatReview<cr>", desc = "CopilotChat - Review code" },
      { "<leader>caR", "<cmd>CopilotChatRefactor<cr>", desc = "CopilotChat - Refactor code" },
      { "<leader>can", "<cmd>CopilotChatBetterNamings<cr>", desc = "CopilotChat - Better Naming" },
      -- Chat with Copilot in visual mode
      {
        "<leader>cav",
        ":CopilotChatVisual",
        mode = "x",
        desc = "CopilotChat - Open in vertical split",
      },
      {
        "<leader>cax",
        ":CopilotChatInline<cr>",
        mode = "x",
        desc = "CopilotChat - Inline chat",
      },
      -- Custom input for CopilotChat
      {
        "<leader>cai",
        function()
          local input = vim.fn.input("Ask Copilot: ")
          if input ~= "" then
            vim.cmd("CopilotChat " .. input)
          end
        end,
        desc = "CopilotChat - Ask input",
      },
      -- Generate commit message based on the git diff
      {
        "<leader>cam",
        "<cmd>CopilotChatCommit<cr>",
        desc = "CopilotChat - Generate commit message for all changes",
      },
      {
        "<leader>caM",
        "<cmd>CopilotChatCommitStaged<cr>",
        desc = "CopilotChat - Generate commit message for staged changes",
      },
      -- Quick chat with Copilot
      {
        "<leader>caq",
        function()
          local input = vim.fn.input("Quick Chat: ")
          if input ~= "" then
            vim.cmd("CopilotChatBuffer " .. input)
          end
        end,
        desc = "CopilotChat - Quick chat",
      },
      -- Debug
      { "<leader>cad", "<cmd>CopilotChatDebugInfo<cr>", desc = "CopilotChat - Debug Info" },
      -- Fix the issue with diagnostic
      { "<leader>caf", "<cmd>CopilotChatFixDiagnostic<cr>", desc = "CopilotChat - Fix Diagnostic" },
      -- Clear buffer and chat history
      { "<leader>cal", "<cmd>CopilotChatReset<cr>", desc = "CopilotChat - Clear buffer and chat history" },
      -- Toggle Copilot Chat Vsplit
      { "<leader>cav", "<cmd>CopilotChatToggle<cr>", desc = "CopilotChat - Toggle" },
      -- Copilot Chat Models
      { "<leader>ca?", "<cmd>CopilotChatModels<cr>", desc = "CopilotChat - Select Models" },
    },
  },
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>gm", group = "Copilot Chat" },
      },
    },
  },

  -- Status Line and Buffer Line in Lua
   {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' }
   },
   "romgrk/barbar.nvim" ,

  -- GitDiff
   "sindrets/diffview.nvim",

  -- File Tree
   "kyazdani42/nvim-tree.lua" ,
   "nvim-tree/nvim-web-devicons" ,

  -- LSP Diagnostics Config
   "WhoIsSethDaniel/toggle-lsp-diagnostics.nvim" ,


  -- Auto pairs and bracket surroundings
   "jiangmiao/auto-pairs" ,
   {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
        require("nvim-surround").setup({
            -- Configuration here, or leave empty to use defaults
        })
    end
    },

  -- Commenting
   "b3nj5m1n/kommentary" ,


  -- "Hop" navigation
   "phaazon/hop.nvim" ,

  -- Camelcase Movement
   "chaoren/vim-wordmotion" ,
   "bkad/CamelCaseMotion" ,

  -- HTML Tag completion
  -- https://docs.emmet.io/abbreviations/syntax/
   "mattn/emmet-vim" ,

  -- Autocompletion plugin
   "hrsh7th/cmp-nvim-lsp" ,
   "hrsh7th/cmp-buffer" ,
   "hrsh7th/cmp-path" ,
   "hrsh7th/cmp-cmdline" ,
   "hrsh7th/nvim-cmp" ,
   "f3fora/cmp-spell" ,
   "ray-x/cmp-treesitter" ,
   "hrsh7th/cmp-nvim-lua" ,
   "windwp/nvim-autopairs" ,

  -- VSCode Snippet Feature in Nvim
   "hrsh7th/cmp-vsnip" ,
   "hrsh7th/vim-vsnip" ,
   "onsails/lspkind-nvim" ,

  -- Formatter
   "mhartington/formatter.nvim" ,


  -- Telescope Finder
   "nvim-lua/plenary.nvim" ,
   "nvim-lua/popup.nvim" ,
   "nvim-telescope/telescope.nvim" ,
   "jvgrootveld/telescope-zoxide" ,

  -- Treesitter for NeoVim
   "nvim-treesitter/nvim-treesitter" }

  )


-- Theme Config
g.tokyonight_style = "night"
g.tokyonight_italic_comments = true

opt.termguicolors = true -- You will have bad experience for diagnostic messages when it's default 4000.

-- Load the colorscheme
vim.cmd([[colorscheme tokyonight]])

-- Lualine Config
require("lualine").setup({
  options = {
    icons_enabled = true,
    theme = "tokyonight",
    component_separators = { "∙", "∙" },
    section_separators = { "", "" },
    disabled_filetypes = {},
  },
  sections = {
    lualine_a = { "mode", "paste" },
    lualine_b = { "branch", "diff" },
    lualine_c = {
      { "filename", file_status = true, full_path = true },
      {
        "diagnostics",
        sources = { "nvim_diagnostic" },
        symbols = { error = " ", warn = " ", info = " " },
        color_error = colors.red,
        color_warn = colors.yellow,
        color_info = colors.cyan,
      },
    },
    lualine_x = { "filetype" },
    lualine_y = {
      {
        "progress",
      },
    },
    lualine_z = {
      {
        "location",
        icon = "",
      },
    },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { "filename" },
    lualine_x = { "location" },
    lualine_y = {},
    lualine_z = {},
  },
  tabline = {},
  extensions = {},
})

-- File Tree for Nvim
map("n", "<C-t>", ":NvimTreeToggle<cr>")
require("nvim-tree").setup({})

-- Hop
require("hop").setup()
map("n", "<leader>j", "<cmd>lua require'hop'.hint_words()<cr>")
map("n", "<leader>l", "<cmd>lua require'hop'.hint_lines()<cr>")
map("v", "<leader>j", "<cmd>lua require'hop'.hint_words()<cr>")
map("v", "<leader>l", "<cmd>lua require'hop'.hint_lines()<cr>")

-- Surround
-- require("surround").setup({})

-- Copilot

-- LSP this is needed for LSP completions in CSS along with the snippets plugin
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities.textDocument.completion.completionItem.resolveSupport = {
  properties = {
    "documentation",
    "detail",
    "additionalTextEdits",
  },
}
-- Mason setup
require("mason").setup()

-- LSP Server config
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

require("lspconfig").rust_analyzer.setup({})

-- C++, Swift, and C
-- require'lspconfig'.sourcekit.setup{}
require'lspconfig'.clangd.setup{}

require("lspconfig").lua_ls.setup({
  settings = {
    Lua = {
      diagnostics = {
        globals = {"vim"},
      }
    }
  }
})

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

-- ESLint config for the EFM server
local eslint = {
  lintCommand = "eslint_d -f unix --stdin --stdin-filename ${INPUT}",
  lintStdin = true,
  lintFormats = {
    "%f:%l:%c: %m",
  },
  lintIgnoreExitCode = true,
}

-- Dockerfile EFM
local hadolint = {
  lintSource = "hadolint",
  lintCommand = "hadolint --no-color -",
  lintStdin = true,
  lintIgnoreExitCode = true,
  lintFormats = {
    "%f:%l %m",
  },
}

-- Yaml EFM
local yamllint = {
  lintSource = "yamllint",
  lintCommand = "yamllint -f parsable -",
  lintStdin = true,
}

-- Shell EFM (WIP)
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
    client.resolved_capabilities.document_formatting = true
    client.resolved_capabilities.goto_definition = false
    -- set_lsp_config(client)
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

-- LSP Prevents inline buffer annotations

local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

vim.diagnostic.open_float(nil, {
    source = 'always'
})
local nvim_lsp = require('lspconfig')
-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
local servers = { 'pyright', 'rust_analyzer'}
for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup {
    on_attach = on_attach,
    flags = {
      debounce_text_changes = 150,
    }
  }
end

-- Copilot

map("n", "<leader>ce", '<cmd>lua vim.diagnostic.open_float()<CR>')
map("n", "<leader>cn", '<cmd>lua vim.diagnostic.goto_next()<CR>')
map("n", "<C-q>", '<Plug>(toggle-lsp-diag-vtext)')

-- Setup treesitter
local ts = require("nvim-treesitter.configs")
ts.setup({ ensure_installed = {"python", "rust"}, highlight = { enable = true } })

-- Various options
opt.number = true
opt.backspace = { "indent", "eol", "start" }
opt.clipboard = "unnamedplus"
opt.completeopt = "menuone,noselect"
opt.cursorline = true
opt.encoding = "utf-8" -- Set default encoding to UTF-8
opt.expandtab = true -- Use spaces instead of tabs
opt.foldenable = false
opt.foldmethod = "indent"
opt.formatoptions = "l"
opt.hidden = true -- Enable background buffers
opt.hlsearch = true -- Highlight found searches
opt.ignorecase = true -- Ignore case
opt.inccommand = "split" -- Get a preview of replacements
opt.incsearch = true -- Shows the match while typing
opt.joinspaces = false -- No double spaces with join
opt.linebreak = true -- Stop words being broken on wrap
opt.list = false -- Show some invisible characters
opt.numberwidth = 5 -- Make the gutter wider by default
opt.scrolloff = 4 -- Lines of context
opt.shiftround = true -- Round indent
opt.shiftwidth = 2 -- Size of an indent
opt.showmode = false -- Don't display mode
opt.sidescrolloff = 8 -- Columns of context
opt.signcolumn = "yes" -- always show signcolumns
opt.smartcase = true -- Do not ignore case with capitals
opt.smartindent = true -- Insert indents automatically
opt.spelllang = "en"
opt.splitbelow = true -- Put new windows below current
opt.splitright = true -- Put new windows right of current
opt.tabstop = 2 -- Number of spaces tabs count for
opt.updatetime = 250 -- don't give |ins-completion-menu| messages.
opt.wrap = true
opt.mouse =
-- opt.mousescroll = "ver:5,hor:2"

-- Use spelling for markdown files ‘]s’ to find next, ‘[s’ for previous, 'z=‘ for suggestions when on one.
-- Source: http:--thejakeharding.com/tutorial/2012/06/13/using-spell-check-in-vim.html
vim.api.nvim_exec(
  [[
augroup markdownSpell
    autocmd!
    autocmd FileType markdown,md,txt setlocal spell
    autocmd BufRead,BufNewFile *.md,*.txt,*.markdown setlocal spell
augroup END
]],
  false
)

-- HTML Tag completion
g.user_emmet_leader_key = "<C-w>"

map("n", "<leader>dp", "oimport pudb; pudb.set_trace()  # fmt: skip<Esc>")
-- Camelcase Movement
g.camelcasemotion_key = "<leader>"

-- LazyGit
map("n", "<leader>gs", ":LazyGit<CR>")

-- Copy and Paste from Clipboard
map("v", "<C-c", ":w !pbcopy<CR><CR>")
map("n", "<C-v", ":r !pbpaste<CR><CR>")

-- Config from https://github.com/whatsthatsmell/dots/blob/master/public%20dots/vim-nvim/lua/joel/completion/init.lua
-- completion maps (not cmp) --
-- line completion - use more!
map("i", "<c-l>", "<c-x><c-l>")
-- Vim command-line completion
map("i", "<c-v>", "<c-x><c-v>")
-- end non-cmp completion maps --

-- Setup nvim-cmp
local cmp = require("cmp")

-- lspkind
local lspkind = require("lspkind")
lspkind.init({
  mode = 'symbol_text',
  symbol_map = {
    Text = "",
    Method = "ƒ",
    Copilot = "",
    Function = "ﬦ",
    Constructor = "",
    Variable = "",
    Class = "",
    Interface = "ﰮ",
    Module = "",
    Property = "",
    Unit = "",
    Value = "",
    Enum = "了",
    Keyword = "",
    Snippet = "﬌",
    Color = "",
    File = "",
    Folder = "",
    EnumMember = "",
    Constant = "",
    Struct = "",
  },
})
table.unpack = table.unpack or unpack -- 5.1 compatibility
local has_words_before = function()
  if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then return false end
  local line, col = table.unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_text(0, line-1, 0, line-1, col, {})[1]:match("^%s*$") == nil
end

cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = {
    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<CR>"] = cmp.mapping({
      i = cmp.mapping.confirm({ select = true }),
    }),
    ["<Right>"] = cmp.mapping({
      i = cmp.mapping.confirm({ select = true }),
    }),
    ["<Tab>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "s" }),
    --[[ ["<Tab>"] = vim.schedule_wrap(function(fallback)
      if cmp.visible() and has_words_before() then
        cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
      else
        fallback()
      end
    end), ]]
    ["<S-Tab>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "s" }),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<Up>"] = cmp.mapping(cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }), { "i" }),
    ["<Down>"] = cmp.mapping(cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }), { "i" }),
  },
  experimental = {
    ghost_text = true,
  },
  sources = {
    -- 'crates' is lazy loaded
    -- { name = "copilot" },
    { name = "nvim_lsp" },
    { name = "treesitter" },
    { name = "vsnip" },
    { name = "path" },
    {
      name = "buffer",
      option = {
        get_bufnrs = function()
          return vim.api.nvim_list_bufs()
        end,
      },
    },
    { name = "spell" },
  },
  --[[ sorting = {
    priority_weight = 2,
    comparators = {
      require("copilot_cmp.comparators").prioritize,

      -- Below is the default comparitor list and order for nvim-cmp
      cmp.config.compare.offset,
      -- cmp.config.compare.scopes, --this is commented in nvim-cmp too
      cmp.config.compare.exact,
      cmp.config.compare.score,
      cmp.config.compare.recently_used,
      cmp.config.compare.locality,
      cmp.config.compare.kind,
      cmp.config.compare.sort_text,
      cmp.config.compare.length,
      cmp.config.compare.order,
    },
  }, ]]
  formatting = {
    format = function(entry, vim_item)
      vim_item.kind = string.format("%s %s", lspkind.presets.default[vim_item.kind], vim_item.kind)
      vim_item.menu = ({
        nvim_lsp = "ﲳ",
        nvim_lua = "",
        treesitter = "",
        path = "ﱮ",
        buffer = "﬘",
        vsnip = "",
        spell = "暈",
        -- Copilot = ""
      })[entry.source.name]

      return vim_item
    end,
  },
})

local has_words_before = function()
  if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then return false end
  local line, col = table.unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_text(0, line-1, 0, line-1, col, {})[1]:match("^%s*$") == nil
end
cmp.setup({
  mapping = {
    ["<Tab>"] = vim.schedule_wrap(function(fallback)
      if cmp.visible() and has_words_before() then
        cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
      else
        fallback()
      end
    end),
  },
})

-- insert `(` after select function or method item
local cmp_autopairs = require("nvim-autopairs.completion.cmp")
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done({ map_char = { tex = "" } }))

-- Highlight on yank
cmd("au TextYankPost * lua vim.highlight.on_yank {on_visual = true}") -- disabled in visual mode

-- Quick new file
map("n", "<Leader>n", "<cmd>enew<CR>")

-- Easy select all of file
map("n", "<Leader>sa", "ggVG<c-$>")

-- Make visual yanks place the cursor back where started
map("v", "y", "ygv<Esc>")

-- Easier file save
map("n", "<leader>w", "<cmd>:w<CR>")

-- Tab to switch buffers in Normal mode
map("n", "<Tab>", ":bnext<CR>")
map("n", "<S-Tab>", ":bprevious<CR>")

-- Line bubbling
-- Use these two if you don't have prettier
--map('n'), '<c-j>', '<cmd>m .+1<CR>==')
--map('n,) <c-k>', '<cmd>m .-2<CR>==')
map("n", "<c-j>", "<cmd>m .+1<CR>")
map("n", "<c-k>", "<cmd>m .-2<CR>")
map("i", "<c-j> <Esc>", "<cmd>m .+1<CR>==gi")
map("i", "<c-k> <Esc>", "<cmd>m .-2<CR>==gi")
map("v", "<c-j>", "<cmd>m +1<CR>gv=gv")
map("v", "<c-k>", "<cmd>m -2<CR>gv=gv")

--Auto close tags
map("i", ",/", "</<C-X><C-O>")

--After searching, pressing escape stops the highlight
map("n", "<esc>", ":noh<cr><esc>")

-- Telescope Global remapping
local actions = require("telescope.actions")
require("telescope").setup({
  defaults = {
    sorting_strategy = "descending",
    layout_strategy = "horizontal",
    mappings = {
      i = {
        ["<esc>"] = actions.close,
      },
    },
  },
  pickers = {
    buffers = {
      sort_lastused = true,
      mappings = {
        i = {
          ["<C-w>"] = "delete_buffer",
        },
        n = {
          ["<C-w>"] = "delete_buffer",
        },
      },
    },
  },
})
require'telescope'.load_extension('zoxide')
-- Telescope File Pickers
map("n", "<leader>fs", "<cmd>lua require('telescope.builtin').find_files()<cr>")
map("n", "<leader>fc", "<cmd>lua require('telescope.builtin').spell_suggest()<cr>")
map("n", "<leader>fg", "<cmd>lua require('telescope.builtin').live_grep()<cr>")
map("n", "<leader>fr", "<cmd>lua require('telescope.builtin').grep_string()<cr>")
map("n", "<leader>ff", "<cmd>lua require('telescope.builtin').file_browser({ hidden = true })<cr>")
map("n", "<leader>ft", ":lua require'telescope'.extensions.zoxide.list{}<CR>")

-- Telescope Vim Pickers
map("n", "<leader>vr", "<cmd>lua require('telescope.builtin').registers()<cr>")
map("n", "<leader>vm", "<cmd>lua require('telescope.builtin').marks()<cr>")
map("n", "<leader>vb", "<cmd>lua require('telescope.builtin').buffers()<cr>")
-- Telescope LSP Pickers
map("n", "<leader>rr", "<cmd>lua require('telescope.builtin').lsp_references()<cr>")

-- Formatter
-- Prettier
local prettier = function()
  return {
    exe = "prettier",
    args = { "--stdin-filepath", vim.api.nvim_buf_get_name(0), "--double-quote" },
    stdin = true,
  }
end

-- Rustfmt
local rustfmt = function()
  return {
    exe = "rustfmt",
    args = { "--emit=stdout" },
    stdin = true,
  }
end

-- ShFmt
local shfmt = function()
  return {
    exe = "shfmt",
    args = { "-ci", "-s", "-bn" },
    stdin = true,
  }
end

--C++
local clang_format = function()
  return {
    exe = "clang-format",
    args = { "-i", vim.api.nvim_buf_get_name(0) },
    stdin = true,
  }
end

-- Black
local black = function()
  return {
    exe = "black",
    args = { "--quiet", "-" },
    stdin = true,
  }
end

require("formatter").setup({
  logging = false,
  filetype = {
    javascript = { prettier },
    typescript = { prettier },
    html = { prettier },
    css = { prettier },
    scss = { prettier },
    cpp = { clang_format },
    markdown = { prettier },
    rust = { rustfmt },
    python = { black },
    sh = { shfmt },
  },
})

-- Runs Formatter on save
vim.api.nvim_exec(
  [[
augroup FormatAutogroup
  autocmd!
  autocmd BufWritePost *.js,*.ts,*.css,*.scss,*.md,*.html,*.rs,*.py,*.sh: FormatWrite
augroup END
]],
  true
)
