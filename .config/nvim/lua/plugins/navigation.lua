-- Navigation plugins configuration

return {
  -- "Hop" navigation
  {
    "phaazon/hop.nvim",
    config = function()
      require("hop").setup()
    end,
  },

  -- Telescope Finder
  "nvim-lua/plenary.nvim",
  "nvim-lua/popup.nvim",
  {
    "nvim-telescope/telescope.nvim",
    config = function()
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
    end,
  },
  "jvgrootveld/telescope-zoxide",
}