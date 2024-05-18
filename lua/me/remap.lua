vim.g.mapleader = " "

vim.opt.clipboard = 'unnamedplus'

local map = vim.api.nvim_set_keymap

local opts = { silent = true }

map("n", "<leader>w", [[<cmd>w<CR>]], opts)
map("n", "<leader>c", [[<cmd>lua require('bufdelete').bufdelete(0)<CR>]], opts)
map("n", "<leader>q", [[<cmd>qa<CR>]], opts)

map("n", "=", [[<cmd>vertical resize +5<cr>]], opts)
map("n", "-", [[<cmd>vertical resize -5<cr>]], opts)
map("n", "+", [[<cmd>horizontal resize +2<cr>]], opts)
map("n", "_", [[<cmd>horizontal resize -2<cr>]], opts)

map("n", "<C-h>", [[<C-w>h]], opts)
map("n", "<C-l>", [[<C-w>l]], opts)
map("n", "<C-j>", [[<C-w>j]], opts)
map("n", "<C-k>", [[<C-w>k]], opts)

map('n', '<A-,>', [[<Cmd>BufferLineCyclePrev<CR>]], opts)
map('n', '<A-.>', [[<Cmd>BufferLineCycleNext<CR>]], opts)
