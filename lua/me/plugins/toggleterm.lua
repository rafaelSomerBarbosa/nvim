return {
  "akinsho/toggleterm.nvim",
  config = function()
    require("toggleterm").setup({
      open_mapping = [[<c-\><c-\>]],
      insert_mappings = true,
      terminal_mappings = true,
      size = function(term)
        if term.direction == "vertical" then
          return math.floor(vim.o.columns * 0.25)
        end
        return 15
      end,
    })

    function _G.set_terminal_keymaps()
      local opts = { buffer = 0 }
      vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
      vim.keymap.set("t", "jk", [[<C-\><C-n>]], opts)
      vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
      vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
      vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
      vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
      vim.keymap.set("t", "<C-w>", [[<C-\><C-n><C-w>]], opts)
    end

    vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")

    -- Claude Code integration
    local in_tmux = vim.env.TMUX ~= nil

    if in_tmux then
      -- tmux helpers
      local function tmux_open(cmd)
        return vim.fn.system(
          string.format("tmux split-window -h -p 25 -P -F '#{pane_id}' '%s'", cmd)
        ):gsub("%s+", "")
      end

      local function tmux_pane_alive(id)
        if not id or id == "" then return false end
        vim.fn.system(string.format("tmux list-panes -a -F '#{pane_id}' | grep -qF '%s'", id))
        return vim.v.shell_error == 0
      end

      local function tmux_send_enter(id, text)
        vim.fn.system(string.format("tmux send-keys -t %s %s Enter", id, vim.fn.shellescape(text)))
      end

      -- <leader>Co — toggle persistent Claude pane
      local tmux_main_pane = nil

      vim.keymap.set("n", "<leader>Co", function()
        if tmux_pane_alive(tmux_main_pane) then
          vim.fn.system("tmux kill-pane -t " .. tmux_main_pane)
          tmux_main_pane = nil
        else
          tmux_main_pane = tmux_open("claude")
        end
      end, { desc = "Claude: toggle" })

      -- <leader>Cr — resume a recent conversation
      vim.keymap.set("n", "<leader>Cr", function()
        tmux_open("claude --resume")
      end, { desc = "Claude: resume conversation" })

      -- <leader>Cc — new conversation, send current file:line as context
      local tmux_ctx_pane = nil

      vim.keymap.set("n", "<leader>Cc", function()
        local file = vim.api.nvim_buf_get_name(0)
        local line = vim.api.nvim_win_get_cursor(0)[1]
        local ctx = string.format("I'm working on %s:%d", file, line)
        local delay = 500

        if not tmux_pane_alive(tmux_ctx_pane) then
          tmux_ctx_pane = tmux_open("claude")
          delay = 1000
        end

        vim.defer_fn(function()
          tmux_send_enter(tmux_ctx_pane, ctx)
        end, delay)
      end, { desc = "Claude: new with context" })

    else
      -- toggleterm fallback (no tmux)
      local Terminal = require("toggleterm.terminal").Terminal

      local claude_main = Terminal:new({
        cmd = "claude",
        direction = "vertical",
        close_on_exit = false,
        hidden = true,
      })

      vim.keymap.set("n", "<leader>Co", function()
        claude_main:toggle()
      end, { desc = "Claude: toggle" })

      vim.keymap.set("n", "<leader>Cr", function()
        local resume = Terminal:new({
          cmd = "claude --resume",
          direction = "vertical",
          hidden = false,
        })
        resume:open()
      end, { desc = "Claude: resume conversation" })

      local claude_ctx = nil

      vim.keymap.set("n", "<leader>Cc", function()
        local file = vim.api.nvim_buf_get_name(0)
        local line = vim.api.nvim_win_get_cursor(0)[1]

        if claude_ctx == nil then
          claude_ctx = Terminal:new({
            cmd = "claude",
            direction = "vertical",
            close_on_exit = false,
            hidden = false,
          })
          claude_ctx:open()

          vim.defer_fn(function()
            claude_ctx:send(string.format("I'm working on %s:%d", file, line))
          end, 1000)
        else
          if not claude_ctx:is_open() then
            claude_ctx:open()
          end
          vim.defer_fn(function()
            claude_ctx:send(string.format("I'm working on %s:%d", file, line))
          end, 500)
        end
      end, { desc = "Claude: new with context" })
    end
  end,
}
