-- Git-related plugins configuration

return {
  -- Git integration
  {
    "kdheepak/lazygit.nvim",
    lazy = true,
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
    keys = {
      { "<leader>gs", "<cmd>LazyGit<cr>", desc = "LazyGit" },
    },
    config = function()
      -- Set up environment so lazygit uses nvr to open files in current nvim
      vim.g.lazygit_floating_window_scaling_factor = 0.9
      vim.g.lazygit_use_neovim_remote = 1
    end,
  },

  -- GitDiff
  "sindrets/diffview.nvim",

  -- Auto-generate commit messages with CopilotChat
  {
    "ryancraigdavis/AutoCommitMessage.nvim",
    dependencies = { "CopilotC-Nvim/CopilotChat.nvim" },
    ft = "gitcommit",
    opts = {},
  },
}