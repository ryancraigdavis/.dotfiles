-- Autocompletion configuration

local has_words_before = require("utils.functions").has_words_before

return {
  -- Autocompletion plugin
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/cmp-buffer",
  "hrsh7th/cmp-path",
  "hrsh7th/cmp-cmdline",
  "hrsh7th/nvim-cmp",
  "f3fora/cmp-spell",
  "ray-x/cmp-treesitter",
  "hrsh7th/cmp-nvim-lua",
  "windwp/nvim-autopairs",

  -- VSCode Snippet Feature in Nvim
  "hrsh7th/cmp-vsnip",
  "hrsh7th/vim-vsnip",
  "onsails/lspkind-nvim",

  -- Main completion setup
  {
    "hrsh7th/nvim-cmp",
    config = function()
      local cmp = require("cmp")
      local lspkind = require("lspkind")

      lspkind.init({
        mode = 'symbol_text',
        symbol_map = {
          Text = "",
          Method = "ƒ",
          Copilot = "",
          Function = "",
          Constructor = "",
          Variable = "",
          Class = "",
          Interface = "",
          Module = "",
          Property = "",
          Unit = "",
          Value = "",
          Enum = "了",
          Keyword = "",
          Snippet = "",
          Color = "",
          File = "",
          Folder = "",
          EnumMember = "",
          Constant = "",
          Struct = "",
        },
      })

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
          ["<S-Tab>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "s" }),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<Up>"] = cmp.mapping(cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }), { "i" }),
          ["<Down>"] = cmp.mapping(cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }), { "i" }),
        },
        experimental = {
          ghost_text = true,
        },
        sources = {
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
        formatting = {
          format = function(entry, vim_item)
            vim_item.kind = string.format("%s %s", lspkind.presets.default[vim_item.kind], vim_item.kind)
            vim_item.menu = ({
              nvim_lsp = "",
              nvim_lua = "",
              treesitter = "",
              path = "",
              buffer = "",
              vsnip = "",
              spell = "",
            })[entry.source.name]

            return vim_item
          end,
        },
      })

      -- Tab completion with word detection
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
    end,
  },
}