-- Keybindings configuration

local map = require("utils.functions").map

-- File Tree for Nvim
map("n", "<C-t>", ":NvimTreeToggle<cr>")

-- Hop navigation
map("n", "<leader>j", "<cmd>lua require'hop'.hint_words()<cr>")
map("n", "<leader>l", "<cmd>lua require'hop'.hint_lines()<cr>")
map("v", "<leader>j", "<cmd>lua require'hop'.hint_words()<cr>")
map("v", "<leader>l", "<cmd>lua require'hop'.hint_lines()<cr>")

-- LSP Diagnostics
map("n", "<leader>ce", '<cmd>lua vim.diagnostic.open_float()<CR>')
map("n", "<leader>cn", '<cmd>lua vim.diagnostic.goto_next()<CR>')
map("n", "<C-q>", '<Plug>(toggle-lsp-diag-vtext)')

-- Debugging
map("n", "<leader>dp", "oimport pudb; pudb.set_trace()  # fmt: skip<Esc>")

-- LazyGit
map("n", "<leader>gs", ":LazyGit<CR>")

-- Copy and Paste from Clipboard
map("v", "<C-c", ":w !pbcopy<CR><CR>")
map("n", "<C-v", ":r !pbpaste<CR><CR>")

-- Completion maps (not cmp)
-- line completion - use more!
map("i", "<c-l>", "<c-x><c-l>")
-- Vim command-line completion
map("i", "<c-v>", "<c-x><c-v>")

-- Quick new file
map("n", "<Leader>n", "<cmd>enew<CR>")

-- Easy select all of file
map("n", "<Leader>sa", "ggVG<c-$>")

-- Make visual yanks place the cursor back where started
map("v", "y", "ygv<Esc>")

-- Easier file save
map("n", "<leader>w", "<cmd>:w<CR>")

-- Tab to switch buffers in Normal mode
map("n", "<Tab>", ":bnext<CR>")
map("n", "<S-Tab>", ":bprevious<CR>")

-- Line bubbling
map("n", "<c-j>", "<cmd>m .+1<CR>")
map("n", "<c-k>", "<cmd>m .-2<CR>")
map("i", "<c-j> <Esc>", "<cmd>m .+1<CR>==gi")
map("i", "<c-k> <Esc>", "<cmd>m .-2<CR>==gi")
map("v", "<c-j>", "<cmd>m +1<CR>gv=gv")
map("v", "<c-k>", "<cmd>m -2<CR>gv=gv")

-- Auto close tags
map("i", ",/", "</<C-X><C-O>")

-- After searching, pressing escape stops the highlight
map("n", "<esc>", ":noh<cr><esc>")

-- Telescope File Pickers
map("n", "<leader>fs", "<cmd>lua require('telescope.builtin').find_files()<cr>")
map("n", "<leader>fc", "<cmd>lua require('telescope.builtin').spell_suggest()<cr>")
map("n", "<leader>fg", "<cmd>lua require('telescope.builtin').live_grep()<cr>")
map("n", "<leader>fr", "<cmd>lua require('telescope.builtin').grep_string()<cr>")
map("n", "<leader>ff", "<cmd>lua require('telescope.builtin').file_browser({ hidden = true })<cr>")
map("n", "<leader>ft", ":lua require'telescope'.extensions.zoxide.list{}<CR>")

-- Telescope Vim Pickers
map("n", "<leader>vr", "<cmd>lua require('telescope.builtin').registers()<cr>")
map("n", "<leader>vm", "<cmd>lua require('telescope.builtin').marks()<cr>")
map("n", "<leader>vb", "<cmd>lua require('telescope.builtin').buffers()<cr>")

-- Telescope LSP Pickers
map("n", "<leader>rr", "<cmd>lua require('telescope.builtin').lsp_references()<cr>")