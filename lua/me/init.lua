---@diagnostic disable: undefined-global
local vim = vim

require("me.remap")
require("me.lazyvim")
require("lazy").setup("me.plugins")
require("me.dap")
require("me.diagnostic")

local lsp = require("me.lsp")

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspAttach", { clear = true }),
  callback = function(ev)
    vim.lsp.completion.enable(true, ev.data.client_id, ev.buf)
    vim.keymap.set("n", "<leader>gr", lsp.lsp_references, { buffer = ev.buf, desc = "References (no tests)" })
    vim.keymap.set("n", "<leader>grt", lsp.lsp_references_with_tests, { buffer = ev.buf, desc = "References (with tests)" })
  end,
})

vim.lsp.enable({ "ts_ls", "gopls", "lua_ls", "terraformls", "pyright", "rust_analyzer" })

-- function GoImports()
--     local output = vim.fn.systemlist('goimports', vim.fn.getline(1, '$'))
--     vim.print(output)
--     vim.fn.setline(1, output)
-- end
--
-- vim.cmd([[autocmd BufWritePre *.go lua GoImports()]])

-- vim.cmd([[autocmd BufWritePre *.go :silent! execute ':!goimports' | edit!]])
-- vim.cmd([[autocmd BufWritePre *.* :normal number=false]])

-- vim.cmd([[autocmd BufWritePre *.tsx,*.ts Prettier]])

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

augroup("__formatter__", { clear = true })
autocmd("BufWritePost", {
  group = "__formatter__",
  command = ":FormatWrite",
})

local g = vim.g
local opt = vim.opt
local cmd = vim.cmd

opt.clipboard = "unnamedplus"
opt.termguicolors = true

opt.compatible = false
opt.swapfile = false
opt.hidden = true
opt.history = 100

opt.number = true
opt.relativenumber = true
opt.wrap = true
opt.signcolumn = "yes"
opt.showmatch = true
opt.showmode = false
opt.foldmethod = "marker"
opt.splitright = true
opt.splitbelow = true
opt.conceallevel = 0
-- opt.colorcolumn = "80"
opt.cursorline = true
opt.scrolloff = 10
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true
opt.shortmess:append({ c = true })
opt.autowrite = true
opt.timeoutlen = 300
