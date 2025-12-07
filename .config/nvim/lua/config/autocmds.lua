-- Autocommands configuration

-- Use spelling for markdown files ']s' to find next, '[s' for previous, 'z=' for suggestions when on one.
-- Source: http:--thejakeharding.com/tutorial/2012/06/13/using-spell-check-in-vim.html
vim.api.nvim_exec(
  [[
augroup markdownSpell
    autocmd!
    autocmd FileType markdown,md,txt setlocal spell
    autocmd BufRead,BufNewFile *.md,*.txt,*.markdown setlocal spell
augroup END
]],
  false
)

-- Runs Formatter on save
vim.api.nvim_exec(
  [[
augroup FormatAutogroup
  autocmd!
  autocmd BufWritePost *.js,*.ts,*.css,*.scss,*.md,*.html,*.rs,*.py,*.sh: FormatWrite
augroup END
]],
  true
)

-- Highlight on yank
vim.cmd("au TextYankPost * lua vim.highlight.on_yank {on_visual = true}") -- disabled in visual mode