return {
	'romgrk/barbar.nvim',
	dependencies = {
		'lewis6991/gitsigns.nvim', -- OPTIONAL: for git status
		'nvim-tree/nvim-web-devicons', -- OPTIONAL: for file icons
	},
	version = '^1.0.0',
	config = function ()
		local map = vim.api.nvim_set_keymap
		local opts = { noremap = true, silent = true }

		map('n', '<A-,>', '<Cmd>BufferPrevious<CR>', opts)
		map('n', '<A-.>', '<Cmd>BufferNext<CR>', opts)
	end
}
