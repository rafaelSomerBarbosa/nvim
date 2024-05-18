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
	}
}

