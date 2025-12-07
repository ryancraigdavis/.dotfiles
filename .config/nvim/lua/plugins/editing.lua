-- Editing plugins configuration

return {
  -- Auto pairs and bracket surroundings
  "jiangmiao/auto-pairs",
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
  "b3nj5m1n/kommentary",

  -- Camelcase Movement
  "chaoren/vim-wordmotion",
  "bkad/CamelCaseMotion",

  -- HTML Tag completion
  -- https://docs.emmet.io/abbreviations/syntax/
  "mattn/emmet-vim",
}