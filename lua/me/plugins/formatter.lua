return {
  "mhartington/formatter.nvim",
  config = function()
    local util = require("formatter.util")
    require("formatter").setup({
      logging = true,
      log_level = vim.log.levels.WARN,
      filetype = {
        lua = {
          require("formatter.filetypes.lua").stylua,

          function()
            return {
              exe = "stylua",
              args = {
                "--search-parent-directories",
                "--stdin-filepath",
                util.escape_path(util.get_current_buffer_file_path()),
                "--",
                "-",
              },
              stdin = true,
            }
          end,
        },
        go = {
          require("formatter.filetypes.go").gofmt,
          require("formatter.filetypes.go").goimports,
        },
        javascript = {
          require("formatter.filetypes.javascript").prettier,
        },
        typescript = {
          require("formatter.filetypes.typescript").prettier,
        },
        javascriptreact = {
          require("formatter.filetypes.javascriptreact").prettier,
        },
        typescriptreact = {
          require("formatter.filetypes.typescriptreact").prettier,
        },
        terraform = {
          require("formatter.filetypes.terraform").terraformfmt,
        },
        yaml = {
          require("formatter.filetypes.yaml").yamlfmt,
        },
        sql = {
          function()
            return {
              exe = "sqlfluff",
              args = {
                "format",
                "--disable-progress-bar",
                "--nocolor",
                "--dialect postgres",
                util.escape_path(util.get_current_buffer_file_path()),
              },
              stdin = false,
              ignore_exitcode = true,
            }
          end,
        },
        ["*"] = {
          require("formatter.filetypes.any").remove_trailing_whitespace,
        },
      },
    })
  end,
}
