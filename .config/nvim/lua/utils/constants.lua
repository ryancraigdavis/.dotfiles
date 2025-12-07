-- Constants and color palette for Neovim configuration

local M = {}

-- Color palette
M.colors = {
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

-- Diagnostic signs
M.diagnostic_signs = { 
  Error = " ", 
  Warn = " ", 
  Hint = " ", 
  Info = " " 
}

-- LSP servers to configure
M.lsp_servers = { 'pyright', 'rust_analyzer' }

return M