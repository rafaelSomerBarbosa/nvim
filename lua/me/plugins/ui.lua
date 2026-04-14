return {
    {
        "rcarriga/nvim-notify",
        config = function()
          require("notify").setup({
            background_colour = "#fff",
            render = "compact", -- avoids the broken default renderer
          })
          vim.notify = require("notify")
        end,
      },
	{
		"stevearc/dressing.nvim",
		event = "VeryLazy"
	}
}
