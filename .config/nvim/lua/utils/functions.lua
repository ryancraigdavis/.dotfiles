-- Utility functions for Neovim configuration

local M = {}

-- Key mapping helper function
function M.map(mode, lhs, rhs)
  vim.keymap.set(mode, lhs, rhs)
end

-- Check if words exist before cursor
function M.has_words_before()
  if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then 
    return false 
  end
  local line, col = table.unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_text(0, line-1, 0, line-1, col, {})[1]:match("^%s*$") == nil
end

-- Lua 5.1 compatibility
table.unpack = table.unpack or unpack

return M