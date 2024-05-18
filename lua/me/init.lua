require("me.remap")
require("me.lazyvim")
require("lazy").setup("me.plugins")

-- function GoImports()
--     local output = vim.fn.systemlist('goimports', vim.fn.getline(1, '$'))
--     vim.print(output)
--     vim.fn.setline(1, output)
-- end
--
-- vim.cmd([[autocmd BufWritePre *.go lua GoImports()]])



-- vim.cmd([[autocmd BufWritePre *.go :silent! execute ':!goimports' | edit!]])
-- vim.cmd([[autocmd BufWritePre *.* :normal number=false]])

vim.cmd([[autocmd BufWritePre *.tsx,*.ts Prettier]])

local g = vim.g
local opt = vim.opt
local cmd = vim.cmd

opt.clipboard = 'unnamedplus'
opt.termguicolors = true

opt.compatible = false
opt.swapfile = false
opt.hidden = true
opt.history = 100

opt.number = true
opt.wrap = false
opt.signcolumn = 'yes'
opt.showmatch = true
opt.showmode = false
opt.foldmethod = 'marker'
opt.splitright = true
opt.splitbelow = true
opt.conceallevel = 0
-- opt.colorcolumn = '80'
opt.cursorline = true
opt.scrolloff = 10
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true
opt.shortmess:append {c = true}
opt.number = true
opt.autowrite = true
