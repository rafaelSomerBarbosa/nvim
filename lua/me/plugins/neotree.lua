return {
  "nvim-neo-tree/neo-tree.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
    "MunifTanjim/nui.nvim",
    "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
  },
  config = function()
    vim.api.nvim_create_user_command("Neotreefocusing", function()
      local manager = require("neo-tree.sources.manager")
      local renderer = require("neo-tree.ui.renderer")

      local state = manager.get_state("filesystem")
      local window_exists = renderer.window_exists(state)

      if window_exists then
        vim.cmd("Neotree focus")
      else
        vim.cmd("Neotree reveal")
      end
    end, { nargs = "?" })

    local map = vim.api.nvim_set_keymap
    map("n", "<leader>e", [[<cmd>Neotreefocusing<CR>]], { silent = true })
    map("n", "<leader>ee", [[<cmd>Neotree toggle<CR>]], { silent = true })

    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    require("neo-tree").setup({
      open_files_do_not_replace_types = { "terminal", "trouble", "qf" },
      actions = {
        open_file = {
          window_picker = { enable = false },
        },
      },
      git = {
        ignore = false,
      },
      window = {
        position = "left",
        width = 40,
        mapping_options = {
          noremap = true,
          nowait = true,
        },
      },
      filesystem = {
        follow_current_file = {
          enabled = true,
          leave_dirs_open = false,
        },
      },
    })
  end,
}
