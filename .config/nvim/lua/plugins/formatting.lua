-- Formatter configuration (conform.nvim)

return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>f",
        function()
          require("conform").format({ async = true })
        end,
        mode = "",
        desc = "Format buffer",
      },
    },
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          c = { "clang-format" },
          cpp = { "clang-format" },
          javascript = { "prettier" },
          typescript = { "prettier" },
          html = { "prettier" },
          css = { "prettier" },
          scss = { "prettier" },
          markdown = { "prettier" },
          rust = { "rustfmt" },
          python = { "ruff_format" },
          sh = { "shfmt" },
        },
        formatters = {
          shfmt = {
            prepend_args = { "-ci", "-s", "-bn" },
          },
          prettier = {
            prepend_args = { "--double-quote" },
          },
        },
      })
    end,
  },
}