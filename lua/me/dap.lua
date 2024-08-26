_G.last_dap = { path = nil, file = nil, args = "" }

vim.api.nvim_create_user_command("DapPulverized", function(opts)
  local dap = require("dap")

  local path = vim.fn.expand("%:p:h")
  local file = vim.fn.expand("%:p")

  if _G.last_dap.path == nil and _G.last_dap.file == nil then
    _G.last_dap.path = path
    _G.last_dap.file = file
  end

  if string.find(path, "tests") and string.find(file, "_test") then
    if _G.last_dap.path ~= path or _G.last_dap.file ~= file then
      _G.last_dap.path = path
      _G.last_dap.file = file
      _G.last_dap.args = nil
    end
  end

  local config = {
    type = "go",
    name = "testname",
    request = "launch",
    mode = "test",
    program = "yololo",
    args = {},
    cwd = _G.last_dap.path,
    buildFlags = { _G.last_dap.path .. "/main_test.go", _G.last_dap.file },
  }

  local cursor_word = vim.fn.expand("<cword>")

  if opts.args ~= "" then
    cursor_word = opts.args
  end

  if string.find(cursor_word, "Test") then
    _G.last_dap.args = cursor_word
  end

  if string.find(_G.last_dap.args, "Test") then
    table.insert(config.args, "-test.run=" .. _G.last_dap.args)
  end

  dap.run(config)
end, { nargs = "?" })

local map = vim.api.nvim_set_keymap
map("n", "<leader>5", [[<cmd>DapPulverized<CR>]], {})
