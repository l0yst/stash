-- First, initialize the plugin
require("move").setup({})

-- Then, set your mappings
local opts = { noremap = true, silent = true }

-- Normal-mode commands
vim.keymap.set('n', '<A-Down>', ':MoveLine(1)<CR>', opts)
vim.keymap.set('n', '<A-Up>', ':MoveLine(-1)<CR>', opts)
vim.keymap.set('n', '<leader>wf', ':MoveWord(1)<CR>', opts)
vim.keymap.set('n', '<leader>wb', ':MoveWord(-1)<CR>', opts)

-- Visual-mode commands
vim.keymap.set('v', '<A-Down>', ':MoveBlock(1)<CR>', opts)
vim.keymap.set('v', '<A-Up>', ':MoveBlock(-1)<CR>', opts)

-- Duplicate line (the :t. command)
vim.keymap.set('n', '<A-S-Down>', ':t.<CR>', opts)
vim.keymap.set('v', '<A-S-Down>', ":t'<-1<CR>gv", opts) -- Fixed visual duplication
