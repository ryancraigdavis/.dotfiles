-- Plugin manager setup (Lazy.nvim)

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
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- Import all plugin configurations
  { import = "plugins.ui" },
  { import = "plugins.ai" },
  { import = "plugins.lsp" },
  { import = "plugins.completion" },
  { import = "plugins.editing" },
  { import = "plugins.navigation" },
  { import = "plugins.git" },
  { import = "plugins.formatting" },
  { import = "plugins.treesitter" },
  { import = "plugins.debug" },
})