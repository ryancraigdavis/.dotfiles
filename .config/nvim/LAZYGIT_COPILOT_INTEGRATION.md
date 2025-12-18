# LazyGit + CopilotChat Commit Message Integration

This document describes a Neovim integration that automatically generates commit messages using CopilotChat when opening a commit in LazyGit.

## Overview

When you press `C` (uppercase) in LazyGit to create a commit, this integration:
1. Opens the commit buffer (COMMIT_EDITMSG) in your parent Neovim instance
2. Detects the `gitcommit` filetype
3. Calls CopilotChat with the staged diff
4. Inserts the AI-generated commit message directly into the commit buffer

## Dependencies

### Required
- **Neovim** (tested with 0.9+)
- **LazyGit** - terminal UI for git
- **lazygit.nvim** (`kdheepak/lazygit.nvim`) - Neovim plugin to run LazyGit in a floating terminal
- **CopilotChat.nvim** (`CopilotC-Nvim/CopilotChat.nvim`) - chat interface for GitHub Copilot
- **copilot.lua** (`zbirenbaum/copilot.lua`) - GitHub Copilot integration
- **neovim-remote** (`nvr`) - allows opening files in a parent Neovim instance from nested terminals
- **Treesitter parsers** - `markdown` and `markdown_inline` (required by CopilotChat)

### Install neovim-remote
```bash
pip install neovim-remote
```

Verify installation:
```bash
which nvr
nvr --version
```

### Install Treesitter parsers
In Neovim:
```vim
:TSInstall markdown markdown_inline
```

Or add to treesitter config:
```lua
ensure_installed = { "markdown", "markdown_inline", ... }
```

## Configuration

### 1. LazyGit Configuration

**File:** `~/.config/lazygit/config.yml`

```yaml
os:
  edit: '/path/to/nvr --servername $NVIM --remote-wait-silent {{filename}}'
  editAtLine: '/path/to/nvr --servername $NVIM --remote-wait-silent +{{line}} {{filename}}'
  editAtLineAndWait: '/path/to/nvr --servername $NVIM --remote-wait-silent +{{line}} {{filename}}'
  editInTerminal: false
```

Replace `/path/to/nvr` with the actual path (find it with `which nvr`).

**How it works:**
- `$NVIM` environment variable contains the socket path of the parent Neovim instance
- `--servername $NVIM` tells nvr which Neovim instance to connect to
- `--remote-wait-silent` opens the file and waits for it to be closed before returning control to LazyGit
- `editInTerminal: false` ensures LazyGit doesn't try to open the editor in the terminal

### 2. lazygit.nvim Plugin Configuration

```lua
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
    vim.g.lazygit_floating_window_scaling_factor = 0.9
    vim.g.lazygit_use_neovim_remote = 1
  end,
}
```

### 3. Autocmd for Commit Message Generation

**File:** `lua/config/autocmds.lua` (or wherever you keep autocmds)

```lua
-- Auto-generate commit message with CopilotChat when opening git commit buffer
vim.api.nvim_create_autocmd("FileType", {
  pattern = "gitcommit",
  callback = function()
    vim.defer_fn(function()
      local commit_bufnr = vim.api.nvim_get_current_buf()
      local lines = vim.api.nvim_buf_get_lines(commit_bufnr, 0, 1, false)

      -- Only auto-generate if the commit message is empty (first line is empty or just whitespace)
      if lines[1] and lines[1]:match("^%s*$") then
        local ok, chat = pcall(require, "CopilotChat")
        if ok then
          local select = require("CopilotChat.select")

          -- Store the commit buffer number for later use
          local target_bufnr = commit_bufnr

          chat.ask(
            'Write commit message for the change with commitizen convention. Write clear, informative commit messages that explain the "what" and "why" behind changes, not just the "how". Return ONLY the commit message, no explanation or markdown formatting.',
            {
              selection = function(source)
                return select.gitdiff(source, true) -- true = staged only
              end,
              callback = function(response, source)
                if response and response.content and response.content ~= "" then
                  -- Clean up the response (remove markdown code blocks if present)
                  local cleaned = response.content:gsub("^```[^\n]*\n", ""):gsub("\n```%s*$", "")
                  cleaned = cleaned:gsub("^%s+", ""):gsub("%s+$", "")

                  -- Insert at the beginning of the commit buffer
                  if vim.api.nvim_buf_is_valid(target_bufnr) then
                    local response_lines = vim.split(cleaned, "\n")
                    vim.api.nvim_buf_set_lines(target_bufnr, 0, 0, false, response_lines)
                    -- Move cursor to the commit buffer
                    local wins = vim.fn.win_findbuf(target_bufnr)
                    if #wins > 0 then
                      vim.api.nvim_set_current_win(wins[1])
                    end
                    vim.notify("Commit message inserted", vim.log.levels.INFO)
                  end
                end
              end,
            }
          )
        end
      end
    end, 100)
  end,
})
```

## How It Works

### Flow Diagram

```
User presses <leader>gs
        │
        ▼
LazyGit opens in floating terminal
        │
        ▼
User stages files and presses 'C' (uppercase)
        │
        ▼
LazyGit invokes: nvr --servername $NVIM --remote-wait-silent COMMIT_EDITMSG
        │
        ▼
COMMIT_EDITMSG opens in parent Neovim (new buffer)
        │
        ▼
Neovim detects filetype = "gitcommit"
        │
        ▼
Autocmd fires, checks if first line is empty
        │
        ▼
CopilotChat.ask() called with staged diff
        │
        ▼
Copilot generates commit message
        │
        ▼
Callback inserts message into COMMIT_EDITMSG buffer
        │
        ▼
User edits if needed, then :wq
        │
        ▼
nvr returns control to LazyGit
        │
        ▼
LazyGit completes the commit
```

### Key Technical Details

1. **neovim-remote (nvr)**: When Neovim runs a terminal (`:terminal`), it sets the `$NVIM` environment variable to its socket path. `nvr` uses this to communicate with the parent Neovim instance.

2. **FileType autocmd**: Git automatically uses the `gitcommit` filetype for `COMMIT_EDITMSG` files. We hook into this to trigger our logic.

3. **vim.defer_fn**: Adds a small delay (100ms) to ensure the buffer is fully loaded before we interact with it.

4. **CopilotChat.select.gitdiff**: Built-in selector that retrieves the git diff. Passing `true` returns only staged changes.

5. **Callback signature**: `callback(response, source)` where `response.content` contains the generated text.

6. **Empty line check**: We only generate if the first line is empty to avoid overwriting existing commit messages (e.g., when amending).

## Usage

1. Open Neovim in a git repository
2. `<leader>gs` to open LazyGit
3. Stage your changes (select files, press `space`)
4. Press `C` (uppercase, Shift+C) to commit with editor
5. Wait for CopilotChat to generate the commit message
6. Edit the message if needed
7. Save and quit (`:wq`) to complete the commit

**Note:** Lowercase `c` in LazyGit opens a simple inline input - it won't trigger the editor or this integration.

## Future Plugin Considerations

When converting this to a standalone plugin:

### Configuration Options to Expose

```lua
require('lazygit-copilot-commit').setup({
  -- Enable/disable auto-generation
  enabled = true,

  -- Custom prompt for commit message generation
  prompt = 'Write commit message with commitizen convention...',

  -- Only generate for staged changes (vs all changes)
  staged_only = true,

  -- Delay before triggering (ms)
  defer_delay = 100,

  -- Show notification on success
  notify = true,

  -- Auto-close CopilotChat window after generation
  auto_close_chat = false,

  -- Keybinding to manually trigger generation
  keymap = '<leader>cg',
})
```

### Plugin Structure

```
lazygit-copilot-commit.nvim/
├── lua/
│   └── lazygit-copilot-commit/
│       ├── init.lua          -- Main module, setup function
│       ├── config.lua        -- Default config, merge user config
│       ├── autocmd.lua       -- Autocmd setup
│       └── health.lua        -- :checkhealth integration
├── plugin/
│   └── lazygit-copilot-commit.lua  -- Auto-load on startup
├── doc/
│   └── lazygit-copilot-commit.txt  -- Vim help documentation
├── README.md
└── LICENSE
```

### Health Check Implementation

```lua
-- lua/lazygit-copilot-commit/health.lua
local M = {}

M.check = function()
  vim.health.start('lazygit-copilot-commit')

  -- Check for nvr
  if vim.fn.executable('nvr') == 1 then
    vim.health.ok('neovim-remote (nvr) is installed')
  else
    vim.health.error('neovim-remote (nvr) not found', {
      'Install with: pip install neovim-remote'
    })
  end

  -- Check for CopilotChat
  local has_copilot_chat = pcall(require, 'CopilotChat')
  if has_copilot_chat then
    vim.health.ok('CopilotChat.nvim is installed')
  else
    vim.health.error('CopilotChat.nvim not found')
  end

  -- Check for treesitter markdown
  local has_ts_markdown = pcall(vim.treesitter.language.inspect, 'markdown')
  if has_ts_markdown then
    vim.health.ok('Treesitter markdown parser is installed')
  else
    vim.health.warn('Treesitter markdown parser not found', {
      'Install with: :TSInstall markdown markdown_inline'
    })
  end

  -- Check lazygit config
  local lazygit_config = vim.fn.expand('~/.config/lazygit/config.yml')
  if vim.fn.filereadable(lazygit_config) == 1 then
    vim.health.ok('LazyGit config file exists')
  else
    vim.health.warn('LazyGit config not found at ' .. lazygit_config)
  end
end

return M
```

### Additional Features to Consider

1. **Manual trigger keymap**: Allow users to press a key to regenerate the commit message
2. **Multiple prompt templates**: Support different commit styles (conventional, gitmoji, etc.)
3. **Diff preview**: Show the diff being sent to Copilot
4. **Token limit warning**: Warn if diff is too large
5. **Fallback behavior**: What to do if CopilotChat fails
6. **Integration with other git UIs**: Support for fugitive, neogit, etc.

## Troubleshooting

### Commit buffer doesn't open in Neovim
- Verify `nvr` is installed and in PATH
- Check LazyGit config uses correct nvr path
- Ensure `$NVIM` is set (run `echo $NVIM` in Neovim's terminal)

### CopilotChat errors about markdown parser
- Install treesitter parsers: `:TSInstall markdown markdown_inline`

### Message not inserted into buffer
- Check `:messages` for errors
- Verify CopilotChat is working with `:CopilotChatCommitStaged`

### LazyGit uses wrong editor
- Run `lazygit --print-config-dir` to verify config location
- Check config syntax in `config.yml`
