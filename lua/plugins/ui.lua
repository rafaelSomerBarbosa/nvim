return {
	{
		'rcarriga/nvim-notify',
		config = function ()
			require("notify").setup({
				background_colour = "#FFF",
			})

			vim.notify = require("notify")
		end
	},
	{
		"stevearc/dressing.nvim",
		event = "VeryLazy"
	},
	{
		'akinsho/bufferline.nvim',
		dependencies = 'nvim-tree/nvim-web-devicons',
	}
}

