-- UI plugins configuration

local colors = require("utils.constants").colors

return {
  -- Theme
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      -- Load the colorscheme after plugin is loaded
      vim.cmd([[colorscheme tokyonight]])
    end,
  },

  -- Status Line
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require("lualine").setup({
        options = {
          icons_enabled = true,
          theme = "tokyonight",
          component_separators = { "∙", "∙" },
          section_separators = { "", "" },
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
              symbols = { error = " ", warn = " ", info = " " },
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
              icon = "",
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
    end,
  },

  -- Buffer tabs
  "romgrk/barbar.nvim",

  -- File Tree
  {
    "kyazdani42/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({})
    end,
  },

  -- Web devicons
  "nvim-tree/nvim-web-devicons",
}