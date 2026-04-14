return {
  "nvim-telescope/telescope.nvim",
  tag = "0.1.8",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local telescope_builtin = require("telescope.builtin")

    local telescope_ignore_patterns = {
      "[^a-z]test[^a-z]",
      "[^a-z]mock[^a-z]",
      "[^a-z]stub[^a-z]",
      "Test[^a-z]",
      "Mock[^a-z]",
      "Stub[^a-z]",
    }

    local config = require("telescope")
    require("telescope").setup({
      defaults = {
        file_ignore_patterns = { "node_modules", ".git" },
        -- Include hidden files like .env
      },
      pickers = {
        find_files = {
          hidden = true,
          no_ignore = true,
        },
      },
    })
    vim.keymap.set("n", "<leader>ff", function()
      telescope_builtin.find_files()
    end, {})
    vim.keymap.set("n", "<leader>fg", telescope_builtin.live_grep, {})
    vim.keymap.set("n", "<leader>b", telescope_builtin.buffers, {})
    vim.keymap.set("n", "<leader>gr", telescope_builtin.lsp_references, {})

    -- local actions = require("telescope.actions")
    -- local open_with_trouble = require("trouble.sources.telescope").open
    --
    -- -- Use this to add more results without clearing the trouble list
    -- local add_to_trouble = require("trouble.sources.telescope").add
    --
    -- local telescope = require("telescope")
    --
    -- telescope.setup({
    --   defaults = {
    --     mappings = {
    --       i = { ["<c-t>"] = open_with_trouble },
    --       n = { ["<c-t>"] = open_with_trouble },
    --     },
    --   },
    -- })
  end,
}
