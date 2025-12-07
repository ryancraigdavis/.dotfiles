-- Formatter configuration

return {
  -- Formatter
  {
    "mhartington/formatter.nvim",
    config = function()
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

      -- Ruff
      local ruff = function()
        return {
          exe = "ruff",
          args = { "format", "-" },
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
          python = { ruff },
          sh = { shfmt },
        },
      })
    end,
  },
}