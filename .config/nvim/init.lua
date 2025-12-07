-- Neovim Configuration
-- Modular setup with Lazy.nvim plugin manager

-- Load core configuration
require("config.options")
require("config.colors")
require("config.keymaps")
require("config.autocmds")

-- Load plugin manager and all plugins
require("plugins.init")