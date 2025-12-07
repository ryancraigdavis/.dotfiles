-- Treesitter configuration

return {
  -- Treesitter for NeoVim
  {
    "nvim-treesitter/nvim-treesitter",
    config = function()
      local ts = require("nvim-treesitter.configs")
      ts.setup({ 
        ensure_installed = {"python", "rust"}, 
        highlight = { enable = true } 
      })
    end,
  },
}