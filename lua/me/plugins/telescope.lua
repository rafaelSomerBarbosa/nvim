return {
  "nvim-telescope/telescope.nvim",
  tag = "0.1.6",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local telescope_builtin = require("telescope.builtin")
    vim.keymap.set("n", "<leader>ff", telescope_builtin.find_files, {})
    vim.keymap.set("n", "<leader>fg", telescope_builtin.live_grep, {})
    vim.keymap.set("n", "<leader>fb", telescope_builtin.buffers, {})

    local actions = require("telescope.actions")
    local open_with_trouble = require("trouble.sources.telescope").open

    -- Use this to add more results without clearing the trouble list
    local add_to_trouble = require("trouble.sources.telescope").add

    local telescope = require("telescope")

    telescope.setup({
      defaults = {
        mappings = {
          i = { ["<c-t>"] = open_with_trouble },
          n = { ["<c-t>"] = open_with_trouble },
        },
      },
    })
  end,
}
